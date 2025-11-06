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
        action := flag.String("action", "", "upload, download, offload, or object-create")
        configPath := flag.String("config", "", "path to anytype-cli config.json")
        grpcAddr := flag.String("grpc-addr", "127.0.0.1:31010", "official client gRPC address")
        spaceID := flag.String("space-id", "", "space id for upload/object-create")
        objectID := flag.String("object-id", "", "object id for download")
        filePath := flag.String("file", "", "source file path")
        name := flag.String("name", "New Object", "name for object-create")
        downloadDir := flag.String("download-dir", "", "directory to write downloads into")
        timeout := flag.Duration("timeout", 30*time.Second, "RPC timeout")
        flag.Parse()

        if *action != "upload" && *action != "download" && *action != "offload" && *action != "object-create" {
                return errors.New("--action must be upload, download, offload, or object-create")
        }
        if *configPath == "" {
                return errors.New("--config is required")
        }

        token, err := loadSessionToken(*configPath)
        if err != nil {
                return err
        }

        conn, err := grpc.NewClient(*grpcAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
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
        default:
                return fmt.Errorf("unsupported action %q", *action)
        }
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

        response, err := client.ObjectCreate(ctx, &pb.ObjectCreateRequest{
                SpaceId: spaceID,
                Name:    name,
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
