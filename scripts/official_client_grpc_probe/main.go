package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/anyproto/anytype-heart/pb"
	servicepb "github.com/anyproto/anytype-heart/pb/service"
	model "github.com/anyproto/anytype-heart/pkg/lib/pb/model"
	types "github.com/gogo/protobuf/types"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

type configFile struct {
	SessionToken string `json:"sessionToken"`
}

type result struct {
	Action           string `json:"action"`
	ErrorCode        string `json:"error_code,omitempty"`
	ErrorDescription string `json:"error_description,omitempty"`
	ObjectID         string `json:"object_id,omitempty"`
	BlockID          string `json:"block_id,omitempty"`
	Text             string `json:"text,omitempty"`
	DownloadPath     string `json:"download_path,omitempty"`
	BytesOffloaded   uint64 `json:"bytes_offloaded,omitempty"`
	Match            bool   `json:"match,omitempty"`
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "official_client_grpc_probe: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	action := flag.String("action", "", "upload, download, offload, object-create, object-show-text, or object-edit-text")
	configPath := flag.String("config", "", "path to anytype-cli config.json")
	grpcAddr := flag.String("grpc-addr", "127.0.0.1:31010", "official client gRPC address")
	spaceID := flag.String("space-id", "", "space id for upload/object-create")
	objectID := flag.String("object-id", "", "object id for download")
	filePath := flag.String("file", "", "source file path")
	name := flag.String("name", "New Object", "name for object-create")
	text := flag.String("text", "", "text value for object-edit-text")
	downloadDir := flag.String("download-dir", "", "directory to write downloads into")
	timeout := flag.Duration("timeout", 30*time.Second, "RPC timeout")
	flag.Parse()

	if *action != "upload" && *action != "download" && *action != "offload" &&
		*action != "object-create" && *action != "object-show-text" && *action != "object-edit-text" {
		return errors.New("--action must be upload, download, offload, object-create, object-show-text, or object-edit-text")
	}
	if *configPath == "" {
		return errors.New("--config is required")
	}

	token, err := loadSessionToken(*configPath)
	if err != nil {
		return err
	}

	conn, err := grpc.Dial(*grpcAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return fmt.Errorf("connect gRPC: %w", err)
	}
	defer conn.Close()

	client := servicepb.NewClientCommandsClient(conn)

	switch *action {
	case "upload":
		return runUpload(client, token, *spaceID, *filePath, *timeout)
	case "download":
		return runDownload(client, token, *objectID, *filePath, *downloadDir, *timeout)
	case "offload":
		return runOffload(conn, token, *objectID, *timeout)
	case "object-create":
		return runObjectCreate(client, token, *spaceID, *name, *timeout)
	case "object-show-text":
		return runObjectShowText(client, token, *objectID, *spaceID, *timeout)
	case "object-edit-text":
		return runObjectEditText(client, token, *objectID, *spaceID, *text, *timeout)
	default:
		return fmt.Errorf("unsupported action %q", *action)
	}
}

type textBlock struct {
	id   string
	text string
}

func listTextBlocks(view *model.ObjectView) []textBlock {
	if view == nil {
		return nil
	}
	var blocks []textBlock
	for _, block := range view.Blocks {
		if block == nil || block.Id == "" {
			continue
		}
		content := block.GetText()
		if content == nil {
			continue
		}
		blocks = append(blocks, textBlock{id: block.Id, text: content.Text})
	}
	return blocks
}

func pickTextBlock(blocks []textBlock, preferNonTitle bool, requireNonEmpty bool) (blockID string, text string) {
	if preferNonTitle {
		for _, block := range blocks {
			if block.id == "title" {
				continue
			}
			if requireNonEmpty && block.text == "" {
				continue
			}
			return block.id, block.text
		}
	}
	for _, block := range blocks {
		if requireNonEmpty && block.text == "" {
			continue
		}
		return block.id, block.text
	}
	for _, block := range blocks {
		return block.id, block.text
	}
	return "", ""
}

func runObjectShowText(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-show-text")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	// For many client commands, contextId is treated as the stable object context.
	// Using objectID avoids relying on a client-generated session identifier.
	contextID := objectID
	_, _ = client.ObjectRefresh(ctx, &pb.RpcObjectRefreshRequest{
		ObjectId: objectID,
		SpaceId:  spaceID,
	})
	response, err := client.ObjectShow(ctx, &pb.RpcObjectShowRequest{
		ContextId: contextID,
		ObjectId:  objectID,
		SpaceId:   spaceID,
	})
	if err != nil {
		return fmt.Errorf("ObjectShow RPC failed: %w", err)
	}

	textBlocks := listTextBlocks(response.ObjectView)
	blockID, text := pickTextBlock(textBlocks, true, true)
	output := result{
		Action:   "object-show-text",
		ObjectID: objectID,
		BlockID:  blockID,
		Text:     text,
	}
	if response.Error != nil {
		output.ErrorCode = response.Error.Code.String()
		output.ErrorDescription = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectEditText(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	newText string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-edit-text")
	}
	if newText == "" {
		return errors.New("--text is required for object-edit-text")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	// For many client commands, contextId is treated as the stable object context.
	// Using objectID avoids relying on a client-generated session identifier.
	contextID := objectID
	openResponse, err := client.ObjectOpen(ctx, &pb.RpcObjectOpenRequest{
		ContextId: contextID,
		ObjectId:  objectID,
		SpaceId:   spaceID,
	})
	if err != nil {
		return fmt.Errorf("ObjectOpen RPC failed: %w", err)
	}

	textBlocks := listTextBlocks(openResponse.ObjectView)
	blockID, _ := pickTextBlock(textBlocks, true, false)
	if blockID == "" {
		return fmt.Errorf("no text block found in object %s", objectID)
	}

	editResponse, err := client.BlockTextSetText(ctx, &pb.RpcBlockTextSetTextRequest{
		ContextId: contextID,
		BlockId:   blockID,
		Text:      newText,
	})
	if err != nil {
		return fmt.Errorf("BlockTextSetText RPC failed: %w", err)
	}

	_, _ = client.ObjectRefresh(ctx, &pb.RpcObjectRefreshRequest{
		ObjectId: objectID,
		SpaceId:  spaceID,
	})
	showResponse, err := client.ObjectShow(ctx, &pb.RpcObjectShowRequest{
		ContextId: contextID,
		ObjectId:  objectID,
		SpaceId:   spaceID,
	})
	if err != nil {
		return fmt.Errorf("ObjectShow RPC failed after edit: %w", err)
	}

	afterBlocks := listTextBlocks(showResponse.ObjectView)
	matchID, matchText := pickTextBlock(afterBlocks, true, true)
	match := false
	if matchText == newText {
		match = true
	}
	for _, block := range afterBlocks {
		if block.text == newText {
			match = true
			matchID = block.id
			matchText = block.text
			break
		}
	}

	// Fallback: title/name updates are often represented as object details rather
	// than editable body blocks. If BlockTextSetText doesn't observe the change,
	// try setting the object's "name" detail.
	var setDetailsError *pb.RpcObjectSetDetailsResponseError
	if !match {
		setResponse, err := client.ObjectSetDetails(ctx, &pb.RpcObjectSetDetailsRequest{
			ContextId: contextID,
			Details: []*model.Detail{
				{
					Key:   "name",
					Value: &types.Value{Kind: &types.Value_StringValue{StringValue: newText}},
				},
			},
		})
		if err != nil {
			return fmt.Errorf("ObjectSetDetails RPC failed after BlockTextSetText: %w", err)
		}
		setDetailsError = setResponse.Error

		_, _ = client.ObjectRefresh(ctx, &pb.RpcObjectRefreshRequest{
			ObjectId: objectID,
			SpaceId:  spaceID,
		})
		showAfterSet, err := client.ObjectShow(ctx, &pb.RpcObjectShowRequest{
			ContextId: contextID,
			ObjectId:  objectID,
			SpaceId:   spaceID,
		})
		if err != nil {
			return fmt.Errorf("ObjectShow RPC failed after ObjectSetDetails: %w", err)
		}

		afterSetBlocks := listTextBlocks(showAfterSet.ObjectView)
		matchID, matchText = pickTextBlock(afterSetBlocks, false, true)
		for _, block := range afterSetBlocks {
			if block.text == newText {
				match = true
				matchID = block.id
				matchText = block.text
				break
			}
		}

		showResponse = showAfterSet
	}
	output := result{
		Action:   "object-edit-text",
		ObjectID: objectID,
		BlockID:  matchID,
		Text:     matchText,
		Match:    match,
	}

	if openResponse.Error != nil {
		output.ErrorCode = openResponse.Error.Code.String()
		output.ErrorDescription = openResponse.Error.Description
	}
	if editResponse.Error != nil {
		output.ErrorCode = editResponse.Error.Code.String()
		output.ErrorDescription = editResponse.Error.Description
	}
	if showResponse.Error != nil {
		output.ErrorCode = showResponse.Error.Code.String()
		output.ErrorDescription = showResponse.Error.Description
	}
	if setDetailsError != nil {
		output.ErrorCode = setDetailsError.Code.String()
		output.ErrorDescription = setDetailsError.Description
	}

	return writeJSON(output)
}

func runObjectCreate(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	name string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for object-create")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	details := &types.Struct{
		Fields: map[string]*types.Value{
			"name": {Kind: &types.Value_StringValue{StringValue: name}},
			"type": {Kind: &types.Value_StringValue{StringValue: "ot-page"}},
		},
	}
	response, err := client.ObjectCreate(ctx, &pb.RpcObjectCreateRequest{
		SpaceId:             spaceID,
		ObjectTypeUniqueKey: "ot-page",
		Details:             details,
		WithChat:            false,
	})
	if err != nil {
		return fmt.Errorf("ObjectCreate RPC failed: %w", err)
	}

	output := result{
		Action:   "object-create",
		ObjectID: response.ObjectId,
	}
	if response.Error != nil {
		output.ErrorCode = response.Error.Code.String()
		output.ErrorDescription = response.Error.Description
	}
	return writeJSON(output)
}
func loadSessionToken(configPath string) (string, error) {
	raw, err := os.ReadFile(configPath)
	if err != nil {
		return "", fmt.Errorf("read config %s: %w", configPath, err)
	}

	var cfg configFile
	if err := json.Unmarshal(raw, &cfg); err != nil {
		return "", fmt.Errorf("parse config %s: %w", configPath, err)
	}
	if cfg.SessionToken == "" {
		return "", fmt.Errorf("config %s does not contain sessionToken", configPath)
	}
	return cfg.SessionToken, nil
}

func authContext(token string, timeout time.Duration) (context.Context, context.CancelFunc) {
	ctx := metadata.NewOutgoingContext(context.Background(), metadata.Pairs("token", token))
	return context.WithTimeout(ctx, timeout)
}

func runUpload(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	filePath string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for upload")
	}
	if filePath == "" {
		return errors.New("--file is required for upload")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.FileUpload(ctx, &pb.RpcFileUploadRequest{
		SpaceId:   spaceID,
		LocalPath: filePath,
	})
	if err != nil {
		return fmt.Errorf("FileUpload RPC failed: %w", err)
	}

	output := result{
		Action:   "upload",
		ObjectID: response.ObjectId,
	}
	if response.Error != nil {
		output.ErrorCode = response.Error.Code.String()
		output.ErrorDescription = response.Error.Description
	}
	return writeJSON(output)
}

func runDownload(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	sourceFile string,
	downloadDir string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for download")
	}
	if sourceFile == "" {
		return errors.New("--file is required for download")
	}
	if downloadDir == "" {
		return errors.New("--download-dir is required for download")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.FileDownload(ctx, &pb.RpcFileDownloadRequest{
		ObjectId: objectID,
		Path:     downloadDir,
	})
	if err != nil {
		return fmt.Errorf("FileDownload RPC failed: %w", err)
	}

	output := result{
		Action:       "download",
		DownloadPath: response.LocalPath,
	}
	if response.Error != nil {
		output.ErrorCode = response.Error.Code.String()
		output.ErrorDescription = response.Error.Description
	}
	if response.LocalPath != "" {
		output.DownloadPath, _ = filepath.Abs(response.LocalPath)

		want, err := os.ReadFile(sourceFile)
		if err != nil {
			return fmt.Errorf("read source file %s: %w", sourceFile, err)
		}
		got, err := os.ReadFile(response.LocalPath)
		if err == nil {
			output.Match = bytes.Equal(want, got)
		} else if output.ErrorDescription == "" {
			output.ErrorDescription = fmt.Sprintf("read downloaded file %s: %v", response.LocalPath, err)
		}
	}

	return writeJSON(output)
}

func runOffload(conn *grpc.ClientConn, token string, objectID string, timeout time.Duration) error {
	if objectID == "" {
		return errors.New("--object-id is required for offload")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response := new(pb.RpcFileOffloadResponse)
	err := conn.Invoke(ctx, "/anytype.ClientCommands/FileOffload", &pb.RpcFileOffloadRequest{
		Id:               objectID,
		IncludeNotPinned: true,
	}, response)
	if err != nil {
		return fmt.Errorf("FileOffload RPC failed: %w", err)
	}

	output := result{
		Action:         "offload",
		BytesOffloaded: response.BytesOffloaded,
	}
	if response.Error != nil {
		output.ErrorCode = response.Error.Code.String()
		output.ErrorDescription = response.Error.Description
	}
	return writeJSON(output)
}

func writeJSON(value any) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	return encoder.Encode(value)
}
