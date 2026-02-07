package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
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

type textBlock struct {
	id      string
	text    string
	style   string
	checked bool
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "official_client_grpc_probe: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	action := flag.String("action", "", "probe action")
	configPath := flag.String("config", "", "path to anytype-cli config.json")
	grpcAddr := flag.String("grpc-addr", "127.0.0.1:31010", "official client gRPC address")
	spaceID := flag.String("space-id", "", "space id")
	objectID := flag.String("object-id", "", "object id")
	filePath := flag.String("file", "", "source file path")
	name := flag.String("name", "New Object", "object or relation name")
	text := flag.String("text", "", "text value")
	downloadDir := flag.String("download-dir", "", "directory to write downloads into")
	timeout := flag.Duration("timeout", 30*time.Second, "RPC timeout")
	inviteURL := flag.String("invite-url", "", "published invite url")
	networkID := flag.String("network-id", "", "network id for space-join")
	format := flag.String("format", "text", "relation format")
	color := flag.String("color", "default", "relation option color")
	relationKey := flag.String("relation-key", "", "relation key")
	relationKeysCSV := flag.String("relation-keys", "", "comma-separated relation keys")
	detailKey := flag.String("detail-key", "", "detail key for object-set-detail")
	detailKind := flag.String("detail-kind", "string", "detail kind: string, string-list, bool, number")
	detailValue := flag.String("detail-value", "", "detail value for object-set-detail")
	detailValuesCSV := flag.String("detail-values", "", "comma-separated detail values for string-list")
	searchQuery := flag.String("query", "", "full-text search query for object-search")
	isArchived := flag.Bool("archived", true, "archive state for object-set-is-archived")
	templateID := flag.String("template-id", "", "template id")
	objectTypeKey := flag.String("object-type-key", "", "object type unique key")
	afterID := flag.String("after-id", "", "collection insertion anchor id")
	idsCSV := flag.String("ids", "", "comma-separated object ids")
	flag.Parse()

	validActions := map[string]bool{
		"space-join":                    true,
		"upload":                        true,
		"download":                      true,
		"offload":                       true,
		"object-create":                 true,
		"object-show":                   true,
		"object-show-text":              true,
		"object-edit-text":              true,
		"object-search":                 true,
		"object-create-type":            true,
		"object-create-relation":        true,
		"object-create-relation-option": true,
		"object-add-relation":           true,
		"object-set-detail":             true,
		"object-set-is-archived":        true,
		"object-delete":                 true,
		"object-set-object-type":        true,
		"object-apply-template":         true,
		"object-to-collection":          true,
		"object-collection-add":         true,
		"object-collection-remove":      true,
		"object-collection-sort":        true,
		"template-create-from-object":   true,
		"template-clone":                true,
	}
	if !validActions[*action] {
		return fmt.Errorf("unsupported --action %q", *action)
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
	case "space-join":
		return runSpaceJoin(client, token, *inviteURL, *networkID, *spaceID, *timeout)
	case "upload":
		return runUpload(client, token, *spaceID, *filePath, *timeout)
	case "download":
		return runDownload(client, token, *objectID, *filePath, *downloadDir, *timeout)
	case "offload":
		return runOffload(conn, token, *objectID, *timeout)
	case "object-create":
		return runObjectCreate(client, token, *spaceID, *name, *timeout)
	case "object-show":
		return runObjectShow(client, token, *objectID, *spaceID, *timeout)
	case "object-show-text":
		return runObjectShowText(client, token, *objectID, *spaceID, *timeout)
	case "object-edit-text":
		return runObjectEditText(client, token, *objectID, *spaceID, *text, *timeout)
	case "object-search":
		return runObjectSearch(client, token, *spaceID, *searchQuery, *timeout)
	case "object-create-type":
		return runObjectCreateType(client, token, *spaceID, *name, *timeout)
	case "object-create-relation":
		return runObjectCreateRelation(client, token, *spaceID, *name, *format, *timeout)
	case "object-create-relation-option":
		return runObjectCreateRelationOption(client, token, *spaceID, *name, *relationKey, *color, *timeout)
	case "object-add-relation":
		return runObjectAddRelation(client, token, *objectID, *spaceID, splitCSV(*relationKeysCSV), *timeout)
	case "object-set-detail":
		return runObjectSetDetail(
			client,
			token,
			*objectID,
			*spaceID,
			*detailKey,
			*detailKind,
			*detailValue,
			splitCSV(*detailValuesCSV),
			*timeout,
		)
	case "object-set-is-archived":
		return runObjectSetIsArchived(client, token, *objectID, *spaceID, *isArchived, *timeout)
	case "object-delete":
		return runObjectDelete(client, token, *objectID, *spaceID, *timeout)
	case "object-set-object-type":
		return runObjectSetObjectType(client, token, *objectID, *spaceID, *objectTypeKey, *timeout)
	case "object-apply-template":
		return runObjectApplyTemplate(client, token, *objectID, *spaceID, *templateID, *timeout)
	case "object-to-collection":
		return runObjectToCollection(client, token, *objectID, *spaceID, *timeout)
	case "object-collection-add":
		return runObjectCollectionAdd(client, token, *objectID, *spaceID, *afterID, splitCSV(*idsCSV), *timeout)
	case "object-collection-remove":
		return runObjectCollectionRemove(client, token, *objectID, *spaceID, splitCSV(*idsCSV), *timeout)
	case "object-collection-sort":
		return runObjectCollectionSort(client, token, *objectID, *spaceID, splitCSV(*idsCSV), *timeout)
	case "template-create-from-object":
		return runTemplateCreateFromObject(client, token, *objectID, *spaceID, *timeout)
	case "template-clone":
		return runTemplateClone(client, token, *objectID, *spaceID, *timeout)
	default:
		return fmt.Errorf("unsupported action %q", *action)
	}
}

func runSpaceJoin(
	client servicepb.ClientCommandsClient,
	token string,
	inviteURL string,
	networkID string,
	spaceID string,
	timeout time.Duration,
) error {
	if inviteURL == "" {
		return errors.New("--invite-url is required for space-join")
	}
	if networkID == "" {
		return errors.New("--network-id is required for space-join")
	}
	if spaceID == "" {
		return errors.New("--space-id is required for space-join")
	}

	inviteCID, inviteFileKey, err := parseInviteURL(inviteURL)
	if err != nil {
		return err
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.SpaceJoin(ctx, &pb.RpcSpaceJoinRequest{
		NetworkId:     networkID,
		SpaceId:       spaceID,
		InviteCid:     inviteCID,
		InviteFileKey: inviteFileKey,
	})
	if err != nil {
		return fmt.Errorf("SpaceJoin RPC failed: %w", err)
	}

	output := map[string]any{
		"action":          "space-join",
		"invite_cid":      inviteCID,
		"invite_file_key": inviteFileKey,
		"network_id":      networkID,
		"space_id":        spaceID,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectShow(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-show")
	}

	response, err := showObjectResponse(client, token, objectID, spaceID, timeout, true)
	if err != nil {
		return err
	}

	output := inspectObjectView(objectID, response.ObjectView)
	output["action"] = "object-show"
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCreateType(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	name string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for object-create-type")
	}
	if strings.TrimSpace(name) == "" {
		return errors.New("--name is required for object-create-type")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCreateObjectType(ctx, &pb.RpcObjectCreateObjectTypeRequest{
		SpaceId: spaceID,
		Details: &types.Struct{
			Fields: map[string]*types.Value{
				"name": stringValue(name),
			},
		},
	})
	if err != nil {
		return fmt.Errorf("ObjectCreateObjectType RPC failed: %w", err)
	}

	output := map[string]any{
		"action":    "object-create-type",
		"object_id": response.ObjectId,
	}
	if response.Details != nil {
		output["details"] = structToMap(response.Details)
		if uniqueKey, ok := getStringField(response.Details, "uniqueKey"); ok {
			output["unique_key"] = uniqueKey
		}
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCreateRelation(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	name string,
	format string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for object-create-relation")
	}
	if strings.TrimSpace(name) == "" {
		return errors.New("--name is required for object-create-relation")
	}

	relationFormat, err := parseRelationFormat(format)
	if err != nil {
		return err
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCreateRelation(ctx, &pb.RpcObjectCreateRelationRequest{
		SpaceId: spaceID,
		Details: &types.Struct{
			Fields: map[string]*types.Value{
				"name":           stringValue(name),
				"uniqueKey":      stringValue(toUniqueKey(name)),
				"relationFormat": numberValue(float64(relationFormat)),
			},
		},
	})
	if err != nil {
		return fmt.Errorf("ObjectCreateRelation RPC failed: %w", err)
	}

	output := map[string]any{
		"action":       "object-create-relation",
		"object_id":    response.ObjectId,
		"relation_key": response.Key,
		"format":       relationFormat.String(),
	}
	if response.Details != nil {
		output["details"] = structToMap(response.Details)
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCreateRelationOption(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	name string,
	relationKey string,
	color string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for object-create-relation-option")
	}
	if strings.TrimSpace(name) == "" {
		return errors.New("--name is required for object-create-relation-option")
	}
	if strings.TrimSpace(relationKey) == "" {
		return errors.New("--relation-key is required for object-create-relation-option")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCreateRelationOption(ctx, &pb.RpcObjectCreateRelationOptionRequest{
		SpaceId: spaceID,
		Details: &types.Struct{
			Fields: map[string]*types.Value{
				"name":        stringValue(name),
				"relationKey": stringValue(relationKey),
				"color":       stringValue(color),
			},
		},
	})
	if err != nil {
		return fmt.Errorf("ObjectCreateRelationOption RPC failed: %w", err)
	}

	output := map[string]any{
		"action":       "object-create-relation-option",
		"object_id":    response.ObjectId,
		"relation_key": relationKey,
		"color":        color,
	}
	if response.Details != nil {
		output["details"] = structToMap(response.Details)
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectAddRelation(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	relationKeys []string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-add-relation")
	}
	if len(relationKeys) == 0 {
		return errors.New("--relation-keys is required for object-add-relation")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-add-relation",
			"object_id":         objectID,
			"relation_keys":     relationKeys,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectRelationAdd(ctx, &pb.RpcObjectRelationAddRequest{
		ContextId:    objectID,
		RelationKeys: relationKeys,
	})
	if err != nil {
		return fmt.Errorf("ObjectRelationAdd RPC failed: %w", err)
	}

	output := map[string]any{
		"action":        "object-add-relation",
		"object_id":     objectID,
		"relation_keys": relationKeys,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectSetDetail(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	detailKey string,
	detailKind string,
	detailValue string,
	detailValues []string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-set-detail")
	}
	if strings.TrimSpace(detailKey) == "" {
		return errors.New("--detail-key is required for object-set-detail")
	}

	value, outputValue, err := buildDetailValue(detailKind, detailValue, detailValues)
	if err != nil {
		return err
	}

	openResponse, response, err := objectSetDetail(
		client,
		token,
		objectID,
		spaceID,
		detailKey,
		value,
		timeout,
	)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-set-detail",
			"object_id":         objectID,
			"detail_key":        detailKey,
			"detail_kind":       detailKind,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	output := map[string]any{
		"action":       "object-set-detail",
		"object_id":    objectID,
		"detail_key":   detailKey,
		"detail_kind":  detailKind,
		"detail_value": outputValue,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func objectSetDetail(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	detailKey string,
	value *types.Value,
	timeout time.Duration,
) (*pb.RpcObjectOpenResponse, *pb.RpcObjectSetDetailsResponse, error) {
	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return nil, nil, err
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectSetDetails(ctx, &pb.RpcObjectSetDetailsRequest{
		ContextId: objectID,
		Details: []*model.Detail{
			{
				Key:   detailKey,
				Value: value,
			},
		},
	})
	if err != nil {
		return openResponse, nil, fmt.Errorf("ObjectSetDetails RPC failed: %w", err)
	}
	return openResponse, response, nil
}

func runObjectSetIsArchived(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	archived bool,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-set-is-archived")
	}

	openResponse, response, err := objectSetIsArchived(
		client,
		token,
		objectID,
		spaceID,
		archived,
		timeout,
	)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-set-is-archived",
			"object_id":         objectID,
			"is_archived":       archived,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	output := map[string]any{
		"action":      "object-set-is-archived",
		"object_id":   objectID,
		"is_archived": archived,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func objectSetIsArchived(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	archived bool,
	timeout time.Duration,
) (*pb.RpcObjectOpenResponse, *pb.RpcObjectSetIsArchivedResponse, error) {
	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return nil, nil, err
	}
	if openResponse.Error == nil || openResponse.Error.Code.String() == "NULL" {
		if err := ensureArchiveCollectionLoaded(client, token, spaceID, timeout); err != nil {
			return openResponse, nil, err
		}
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectSetIsArchived(ctx, &pb.RpcObjectSetIsArchivedRequest{
		ContextId:  objectID,
		IsArchived: archived,
	})
	if err != nil {
		return openResponse, nil, fmt.Errorf("ObjectSetIsArchived RPC failed: %w", err)
	}
	return openResponse, response, nil
}

func ensureArchiveCollectionLoaded(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	timeout time.Duration,
) error {
	if strings.TrimSpace(spaceID) == "" {
		return nil
	}

	workspaceResponse, err := openWorkspace(client, token, spaceID, timeout)
	if err != nil {
		return err
	}
	if workspaceResponse.Error != nil && workspaceResponse.Error.Code.String() != "NULL" {
		return fmt.Errorf(
			"WorkspaceOpen returned %s: %s",
			workspaceResponse.Error.Code.String(),
			workspaceResponse.Error.Description,
		)
	}
	if workspaceResponse.Info == nil || workspaceResponse.Info.ArchiveObjectId == "" {
		return nil
	}

	archiveShowResponse, err := showObjectResponse(
		client,
		token,
		workspaceResponse.Info.ArchiveObjectId,
		spaceID,
		timeout,
		false,
	)
	if err != nil {
		return err
	}
	if archiveShowResponse.Error != nil && archiveShowResponse.Error.Code.String() != "NULL" {
		return fmt.Errorf(
			"archive ObjectShow returned %s: %s",
			archiveShowResponse.Error.Code.String(),
			archiveShowResponse.Error.Description,
		)
	}
	return nil
}

func runObjectDelete(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-delete")
	}

	openResponse, archiveResponse, err := objectSetIsArchived(
		client,
		token,
		objectID,
		spaceID,
		true,
		timeout,
	)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-delete",
			"object_id":         objectID,
			"archive_attempted": true,
			"archived_first":    false,
			"delete_attempted":  false,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	archiveSucceeded := archiveResponse.Error == nil || archiveResponse.Error.Code.String() == "NULL"
	output := map[string]any{
		"action":            "object-delete",
		"object_id":         objectID,
		"archive_attempted": true,
	}
	if archiveSucceeded {
		output["archive_succeeded"] = true
	} else {
		output["archive_succeeded"] = false
		output["archive_error_code"] = archiveResponse.Error.Code.String()
		output["archive_error_description"] = archiveResponse.Error.Description
		if archiveResponse.Error.Code.String() != "UNKNOWN_ERROR" ||
			!strings.Contains(strings.ToLower(archiveResponse.Error.Description), "root block not found") {
			output["archived_first"] = false
			output["delete_attempted"] = false
			return writeJSON(output)
		}
		output["archive_fallback"] = true

		detailOpenResponse, detailResponse, err := objectSetDetail(
			client,
			token,
			objectID,
			spaceID,
			"isArchived",
			&types.Value{
				Kind: &types.Value_BoolValue{BoolValue: true},
			},
			timeout,
		)
		if err != nil {
			return err
		}
		output["archive_detail_fallback"] = true
		if detailOpenResponse.Error != nil && detailOpenResponse.Error.Code.String() != "NULL" {
			output["archived_first"] = false
			output["delete_attempted"] = false
			output["archive_detail_error_code"] = detailOpenResponse.Error.Code.String()
			output["archive_detail_error_description"] = detailOpenResponse.Error.Description
			return writeJSON(output)
		}
		if detailResponse.Error != nil && detailResponse.Error.Code.String() != "NULL" {
			output["archived_first"] = false
			output["delete_attempted"] = false
			output["archive_detail_error_code"] = detailResponse.Error.Code.String()
			output["archive_detail_error_description"] = detailResponse.Error.Description
			return writeJSON(output)
		}
		output["archive_detail_succeeded"] = true
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectListDelete(ctx, &pb.RpcObjectListDeleteRequest{
		ObjectIds: []string{objectID},
	})
	if err != nil {
		return fmt.Errorf("ObjectListDelete RPC failed: %w", err)
	}

	output["archived_first"] = archiveSucceeded
	output["delete_attempted"] = true
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectSetObjectType(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	objectTypeKey string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-set-object-type")
	}
	if strings.TrimSpace(objectTypeKey) == "" {
		return errors.New("--object-type-key is required for object-set-object-type")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-set-object-type",
			"object_id":         objectID,
			"object_type_key":   objectTypeKey,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectSetObjectType(ctx, &pb.RpcObjectSetObjectTypeRequest{
		ContextId:           objectID,
		ObjectTypeUniqueKey: objectTypeKey,
	})
	if err != nil {
		return fmt.Errorf("ObjectSetObjectType RPC failed: %w", err)
	}

	output := map[string]any{
		"action":          "object-set-object-type",
		"object_id":       objectID,
		"object_type_key": objectTypeKey,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectToCollection(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-to-collection")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-to-collection",
			"object_id":         objectID,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectToCollection(ctx, &pb.RpcObjectToCollectionRequest{
		ContextId: objectID,
	})
	if err != nil {
		return fmt.Errorf("ObjectToCollection RPC failed: %w", err)
	}

	output := map[string]any{
		"action":    "object-to-collection",
		"object_id": objectID,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCollectionAdd(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	afterID string,
	memberIDs []string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-collection-add")
	}
	if len(memberIDs) == 0 {
		return errors.New("--ids is required for object-collection-add")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-collection-add",
			"object_id":         objectID,
			"member_ids":        memberIDs,
			"after_id":          afterID,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCollectionAdd(ctx, &pb.RpcObjectCollectionAddRequest{
		ContextId: objectID,
		AfterId:   afterID,
		ObjectIds: memberIDs,
	})
	if err != nil {
		return fmt.Errorf("ObjectCollectionAdd RPC failed: %w", err)
	}

	output := map[string]any{
		"action":     "object-collection-add",
		"object_id":  objectID,
		"member_ids": memberIDs,
		"after_id":   afterID,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCollectionRemove(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	memberIDs []string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-collection-remove")
	}
	if len(memberIDs) == 0 {
		return errors.New("--ids is required for object-collection-remove")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-collection-remove",
			"object_id":         objectID,
			"member_ids":        memberIDs,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCollectionRemove(ctx, &pb.RpcObjectCollectionRemoveRequest{
		ContextId: objectID,
		ObjectIds: memberIDs,
	})
	if err != nil {
		return fmt.Errorf("ObjectCollectionRemove RPC failed: %w", err)
	}

	output := map[string]any{
		"action":     "object-collection-remove",
		"object_id":  objectID,
		"member_ids": memberIDs,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectCollectionSort(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	memberIDs []string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-collection-sort")
	}
	if len(memberIDs) == 0 {
		return errors.New("--ids is required for object-collection-sort")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "object-collection-sort",
			"object_id":         objectID,
			"member_ids":        memberIDs,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectCollectionSort(ctx, &pb.RpcObjectCollectionSortRequest{
		ContextId: objectID,
		ObjectIds: memberIDs,
	})
	if err != nil {
		return fmt.Errorf("ObjectCollectionSort RPC failed: %w", err)
	}

	output := map[string]any{
		"action":     "object-collection-sort",
		"object_id":  objectID,
		"member_ids": memberIDs,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runTemplateCreateFromObject(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for template-create-from-object")
	}

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "template-create-from-object",
			"object_id":         objectID,
			"error_code":        openResponse.Error.Code.String(),
			"error_description": openResponse.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.TemplateCreateFromObject(ctx, &pb.RpcTemplateCreateFromObjectRequest{
		ContextId: objectID,
	})
	if err != nil {
		return fmt.Errorf("TemplateCreateFromObject RPC failed: %w", err)
	}

	output := map[string]any{
		"action":      "template-create-from-object",
		"object_id":   objectID,
		"template_id": response.Id,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runTemplateClone(
	client servicepb.ClientCommandsClient,
	token string,
	templateID string,
	spaceID string,
	timeout time.Duration,
) error {
	if templateID == "" {
		return errors.New("--object-id is required for template-clone")
	}
	if spaceID == "" {
		return errors.New("--space-id is required for template-clone")
	}

	response, err := showObjectResponse(client, token, templateID, spaceID, timeout, true)
	if err != nil {
		return err
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		return writeJSON(map[string]any{
			"action":            "template-clone",
			"template_id":       templateID,
			"error_code":        response.Error.Code.String(),
			"error_description": response.Error.Description,
		})
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	cloneResponse, err := client.TemplateClone(ctx, &pb.RpcTemplateCloneRequest{
		ContextId: templateID,
		SpaceId:   spaceID,
	})
	if err != nil {
		return fmt.Errorf("TemplateClone RPC failed: %w", err)
	}

	output := map[string]any{
		"action":      "template-clone",
		"template_id": templateID,
		"object_id":   cloneResponse.Id,
	}
	if cloneResponse.Error != nil && cloneResponse.Error.Code.String() != "NULL" {
		output["error_code"] = cloneResponse.Error.Code.String()
		output["error_description"] = cloneResponse.Error.Description
	}
	return writeJSON(output)
}

func runObjectApplyTemplate(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	templateID string,
	timeout time.Duration,
) error {
	if objectID == "" {
		return errors.New("--object-id is required for object-apply-template")
	}
	if templateID == "" {
		return errors.New("--template-id is required for object-apply-template")
	}
	if spaceID == "" {
		return errors.New("--space-id is required for object-apply-template")
	}

	if _, err := openObjectContext(client, token, objectID, spaceID, timeout); err != nil {
		return err
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectApplyTemplate(ctx, &pb.RpcObjectApplyTemplateRequest{
		ContextId:  objectID,
		TemplateId: templateID,
	})
	if err != nil {
		return fmt.Errorf("ObjectApplyTemplate RPC failed: %w", err)
	}

	output := map[string]any{
		"action":      "object-apply-template",
		"object_id":   objectID,
		"template_id": templateID,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
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

	response, err := showObjectResponse(client, token, objectID, spaceID, timeout, false)
	if err != nil {
		return err
	}

	textBlocks := listTextBlocks(response.ObjectView)
	blockID, text := pickTextBlock(textBlocks, true, true)
	output := map[string]any{
		"action":    "object-show-text",
		"object_id": objectID,
		"block_id":  blockID,
		"text":      text,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func runObjectSearch(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	query string,
	timeout time.Duration,
) error {
	if spaceID == "" {
		return errors.New("--space-id is required for object-search")
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectSearch(ctx, &pb.RpcObjectSearchRequest{
		SpaceId:  spaceID,
		FullText: query,
		Limit:    200,
		Keys:     []string{"id", "name", "isArchived"},
	})
	if err != nil {
		return fmt.Errorf("ObjectSearch RPC failed: %w", err)
	}

	objectIDs := make([]string, 0, len(response.Records))
	names := make([]string, 0, len(response.Records))
	records := make([]map[string]any, 0, len(response.Records))
	for _, record := range response.Records {
		if record == nil {
			continue
		}
		objectID := structStringField(record, "id")
		name := structStringField(record, "name")
		archived := structBoolField(record, "isArchived")
		objectIDs = append(objectIDs, objectID)
		names = append(names, name)
		records = append(records, map[string]any{
			"id":          objectID,
			"name":        name,
			"is_archived": archived,
		})
	}

	output := map[string]any{
		"action":       "object-search",
		"space_id":     spaceID,
		"query":        query,
		"record_count": len(records),
		"object_ids":   objectIDs,
		"names":        names,
		"records":      records,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
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

	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return err
	}

	textBlocks := listTextBlocks(openResponse.ObjectView)
	blockID, _ := pickTextBlock(textBlocks, true, false)
	if blockID == "" {
		return fmt.Errorf("no text block found in object %s", objectID)
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	editResponse, err := client.BlockTextSetText(ctx, &pb.RpcBlockTextSetTextRequest{
		ContextId: objectID,
		BlockId:   blockID,
		Text:      newText,
	})
	if err != nil {
		return fmt.Errorf("BlockTextSetText RPC failed: %w", err)
	}

	showResponse, err := showObjectResponse(client, token, objectID, spaceID, timeout, false)
	if err != nil {
		return err
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

	var setDetailsError *pb.RpcObjectSetDetailsResponseError
	if !match {
		setResponse, err := client.ObjectSetDetails(ctx, &pb.RpcObjectSetDetailsRequest{
			ContextId: objectID,
			Details: []*model.Detail{
				{
					Key:   "name",
					Value: stringValue(newText),
				},
			},
		})
		if err != nil {
			return fmt.Errorf("ObjectSetDetails RPC failed after BlockTextSetText: %w", err)
		}
		setDetailsError = setResponse.Error

		showAfterSet, err := showObjectResponse(client, token, objectID, spaceID, timeout, false)
		if err != nil {
			return err
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

	output := map[string]any{
		"action":    "object-edit-text",
		"object_id": objectID,
		"block_id":  matchID,
		"text":      matchText,
		"match":     match,
	}
	if openResponse.Error != nil && openResponse.Error.Code.String() != "NULL" {
		output["error_code"] = openResponse.Error.Code.String()
		output["error_description"] = openResponse.Error.Description
	}
	if editResponse.Error != nil && editResponse.Error.Code.String() != "NULL" {
		output["error_code"] = editResponse.Error.Code.String()
		output["error_description"] = editResponse.Error.Description
	}
	if showResponse.Error != nil && showResponse.Error.Code.String() != "NULL" {
		output["error_code"] = showResponse.Error.Code.String()
		output["error_description"] = showResponse.Error.Description
	}
	if setDetailsError != nil && setDetailsError.Code.String() != "NULL" {
		output["error_code"] = setDetailsError.Code.String()
		output["error_description"] = setDetailsError.Description
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
			"name": stringValue(name),
			"type": stringValue("ot-page"),
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

	output := map[string]any{
		"action":    "object-create",
		"object_id": response.ObjectId,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func showObjectResponse(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
	includeRelations bool,
) (*pb.RpcObjectShowResponse, error) {
	if err := ensureWorkspaceLoaded(client, token, spaceID, timeout); err != nil {
		return nil, err
	}

	// Official object content is only populated reliably after the object
	// context has been opened at least once in the current session.
	openResponse, err := openObjectContext(client, token, objectID, spaceID, timeout)
	if err != nil {
		return nil, err
	}

	ctx, cancel := authContext(token, timeout)
	defer cancel()

	contextID := objectID
	_, _ = client.ObjectRefresh(ctx, &pb.RpcObjectRefreshRequest{
		ObjectId: objectID,
		SpaceId:  spaceID,
	})
	response, err := client.ObjectShow(ctx, &pb.RpcObjectShowRequest{
		ContextId:                          contextID,
		ObjectId:                           objectID,
		SpaceId:                            spaceID,
		IncludeRelationsAsDependentObjects: includeRelations,
	})
	if err != nil {
		return nil, fmt.Errorf("ObjectShow RPC failed: %w", err)
	}
	if openResponse != nil && openResponse.ObjectView != nil {
		if response.ObjectView == nil {
			response.ObjectView = openResponse.ObjectView
		} else if len(listTextBlocks(openResponse.ObjectView)) >
			len(listTextBlocks(response.ObjectView)) ||
			len(openResponse.ObjectView.Blocks) > len(response.ObjectView.Blocks) {
			response.ObjectView.Blocks = openResponse.ObjectView.Blocks
		}
	}
	return response, nil
}

func ensureWorkspaceLoaded(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	timeout time.Duration,
) error {
	if strings.TrimSpace(spaceID) == "" {
		return nil
	}

	workspaceResponse, err := openWorkspace(client, token, spaceID, timeout)
	if err != nil {
		return err
	}
	if workspaceResponse.Error != nil && workspaceResponse.Error.Code.String() != "NULL" {
		return fmt.Errorf(
			"WorkspaceOpen returned %s: %s",
			workspaceResponse.Error.Code.String(),
			workspaceResponse.Error.Description,
		)
	}
	return nil
}

func openObjectContext(
	client servicepb.ClientCommandsClient,
	token string,
	objectID string,
	spaceID string,
	timeout time.Duration,
) (*pb.RpcObjectOpenResponse, error) {
	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.ObjectOpen(ctx, &pb.RpcObjectOpenRequest{
		ContextId: objectID,
		ObjectId:  objectID,
		SpaceId:   spaceID,
	})
	if err != nil {
		return nil, fmt.Errorf("ObjectOpen RPC failed: %w", err)
	}
	return response, nil
}

func openWorkspace(
	client servicepb.ClientCommandsClient,
	token string,
	spaceID string,
	timeout time.Duration,
) (*pb.RpcWorkspaceOpenResponse, error) {
	ctx, cancel := authContext(token, timeout)
	defer cancel()

	response, err := client.WorkspaceOpen(ctx, &pb.RpcWorkspaceOpenRequest{
		SpaceId: spaceID,
	})
	if err != nil {
		return nil, fmt.Errorf("WorkspaceOpen RPC failed: %w", err)
	}
	return response, nil
}

func inspectObjectView(objectID string, view *model.ObjectView) map[string]any {
	output := map[string]any{
		"object_id": objectID,
	}
	if view == nil {
		return output
	}

	detailSets := detailSetsByID(view)
	rootDetails := rootDetailsForObject(view, objectID, detailSets)

	output["root_id"] = view.RootId
	output["smart_block_type"] = view.Type.String()
	output["smart_block_type_number"] = int(view.Type)
	output["root_details"] = rootDetails
	output["detail_sets"] = detailSets
	output["relation_links"] = collectRelationLinks(view.RelationLinks)
	output["relations"] = collectRelations(view.Relations)
	output["resolved_relations"] = resolveRelationValues(rootDetails, view.Relations)
	output["block_count"] = len(view.Blocks)
	output["block_kinds"] = collectBlockKinds(view)
	output["text_blocks"] = collectTextBlocks(view)
	output["file_blocks"] = collectFileBlocks(view)
	output["dataviews"] = collectDataviews(view)
	return output
}

func detailSetsByID(view *model.ObjectView) map[string]map[string]any {
	sets := map[string]map[string]any{}
	if view == nil {
		return sets
	}

	for _, detailSet := range view.Details {
		if detailSet == nil {
			continue
		}
		id := detailSet.Id
		if id == "" {
			id = view.RootId
		}
		current := sets[id]
		if current == nil {
			current = map[string]any{}
		}
		for key, value := range structToMap(detailSet.Details) {
			current[key] = value
		}
		sets[id] = current
	}
	return sets
}

func rootDetailsForObject(
	view *model.ObjectView,
	objectID string,
	detailSets map[string]map[string]any,
) map[string]any {
	if details, ok := detailSets[objectID]; ok {
		return details
	}
	if details, ok := detailSets[view.RootId]; ok {
		return details
	}
	return map[string]any{}
}

func collectRelationLinks(links []*model.RelationLink) []map[string]any {
	out := make([]map[string]any, 0, len(links))
	for _, link := range links {
		if link == nil {
			continue
		}
		out = append(out, map[string]any{
			"key":    link.Key,
			"format": link.Format.String(),
		})
	}
	return out
}

func collectRelations(relations []*model.Relation) []map[string]any {
	out := make([]map[string]any, 0, len(relations))
	for _, relation := range relations {
		if relation == nil {
			continue
		}
		options := make([]map[string]any, 0, len(relation.SelectDict))
		for _, option := range relation.SelectDict {
			if option == nil {
				continue
			}
			options = append(options, map[string]any{
				"id":           option.Id,
				"text":         option.Text,
				"color":        option.Color,
				"relation_key": option.RelationKey,
				"order_id":     option.OrderId,
			})
		}
		out = append(out, map[string]any{
			"id":          relation.Id,
			"key":         relation.Key,
			"name":        relation.Name,
			"format":      relation.Format.String(),
			"multi":       relation.Multi,
			"select_dict": options,
		})
	}
	return out
}

func resolveRelationValues(rootDetails map[string]any, relations []*model.Relation) map[string]any {
	out := map[string]any{}
	for _, relation := range relations {
		if relation == nil {
			continue
		}
		raw, ok := rootDetails[relation.Key]
		if !ok {
			continue
		}
		switch relation.Format {
		case model.RelationFormat_status:
			out[relation.Key] = resolveOptionValue(raw, relation.SelectDict)
		case model.RelationFormat_tag:
			out[relation.Key] = resolveOptionValues(raw, relation.SelectDict)
		default:
			out[relation.Key] = raw
		}
	}
	return out
}

func resolveOptionValue(raw any, options []*model.RelationOption) any {
	id, ok := raw.(string)
	if !ok {
		return raw
	}
	if text := optionTextByID(options, id); text != "" {
		return text
	}
	return raw
}

func resolveOptionValues(raw any, options []*model.RelationOption) any {
	items, ok := raw.([]any)
	if !ok {
		return raw
	}

	out := make([]string, 0, len(items))
	for _, item := range items {
		id, ok := item.(string)
		if !ok {
			continue
		}
		if text := optionTextByID(options, id); text != "" {
			out = append(out, text)
		} else {
			out = append(out, id)
		}
	}
	return out
}

func optionTextByID(options []*model.RelationOption, id string) string {
	for _, option := range options {
		if option != nil && option.Id == id {
			return option.Text
		}
	}
	return ""
}

func collectTextBlocks(view *model.ObjectView) []map[string]any {
	if view == nil {
		return nil
	}
	out := []map[string]any{}
	for _, block := range view.Blocks {
		if block == nil || block.Id == "" {
			continue
		}
		text := block.GetText()
		if text == nil {
			continue
		}
		out = append(out, map[string]any{
			"id":      block.Id,
			"text":    text.Text,
			"style":   text.Style.String(),
			"checked": text.Checked,
		})
	}
	return out
}

func collectFileBlocks(view *model.ObjectView) []map[string]any {
	if view == nil {
		return nil
	}
	out := []map[string]any{}
	for _, block := range view.Blocks {
		if block == nil || block.Id == "" {
			continue
		}
		file := block.GetFile()
		if file == nil {
			continue
		}
		out = append(out, map[string]any{
			"id":               block.Id,
			"name":             file.Name,
			"mime":             file.Mime,
			"type":             file.Type.String(),
			"size":             file.Size_,
			"target_object_id": file.TargetObjectId,
			"state":            file.State.String(),
			"style":            file.Style.String(),
		})
	}
	return out
}

func collectDataviews(view *model.ObjectView) []map[string]any {
	if view == nil {
		return nil
	}
	out := []map[string]any{}
	for _, block := range view.Blocks {
		if block == nil || block.Id == "" {
			continue
		}
		dataview := block.GetDataview()
		if dataview == nil {
			continue
		}

		views := make([]map[string]any, 0, len(dataview.Views))
		for _, currentView := range dataview.Views {
			if currentView == nil {
				continue
			}
			views = append(views, map[string]any{
				"id":                     currentView.Id,
				"name":                   currentView.Name,
				"type":                   currentView.Type.String(),
				"default_template_id":    currentView.DefaultTemplateId,
				"default_object_type_id": currentView.DefaultObjectTypeId,
			})
		}

		objectOrders := make([]map[string]any, 0, len(dataview.ObjectOrders))
		for _, order := range dataview.ObjectOrders {
			if order == nil {
				continue
			}
			objectOrders = append(objectOrders, map[string]any{
				"view_id":    order.ViewId,
				"group_id":   order.GroupId,
				"object_ids": append([]string(nil), order.ObjectIds...),
			})
		}

		out = append(out, map[string]any{
			"block_id":      block.Id,
			"source":        append([]string(nil), dataview.Source...),
			"active_view":   dataview.ActiveView,
			"is_collection": dataview.IsCollection,
			"views":         views,
			"object_orders": objectOrders,
		})
	}
	return out
}

func collectBlockKinds(view *model.ObjectView) []map[string]any {
	if view == nil {
		return nil
	}
	out := []map[string]any{}
	for _, block := range view.Blocks {
		if block == nil || block.Id == "" {
			continue
		}
		kind := "unknown"
		switch {
		case block.GetText() != nil:
			kind = "text"
		case block.GetLayout() != nil:
			kind = "layout"
		case block.GetSmartblock() != nil:
			kind = "smartblock"
		case block.GetFeaturedRelations() != nil:
			kind = "featured-relations"
		case block.GetDataview() != nil:
			kind = "dataview"
		case block.GetFile() != nil:
			kind = "file"
		}
		out = append(out, map[string]any{
			"id":   block.Id,
			"kind": kind,
		})
	}
	return out
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
		blocks = append(blocks, textBlock{
			id:      block.Id,
			text:    content.Text,
			style:   content.Style.String(),
			checked: content.Checked,
		})
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

func buildDetailValue(kind string, value string, values []string) (*types.Value, any, error) {
	switch strings.ToLower(strings.TrimSpace(kind)) {
	case "string":
		return stringValue(value), value, nil
	case "string-list":
		if len(values) == 0 && strings.TrimSpace(value) != "" {
			values = splitCSV(value)
		}
		listValues := make([]*types.Value, 0, len(values))
		output := make([]string, 0, len(values))
		for _, item := range values {
			listValues = append(listValues, stringValue(item))
			output = append(output, item)
		}
		return &types.Value{
			Kind: &types.Value_ListValue{
				ListValue: &types.ListValue{Values: listValues},
			},
		}, output, nil
	case "bool":
		parsed, err := strconv.ParseBool(value)
		if err != nil {
			return nil, nil, fmt.Errorf("parse bool detail value: %w", err)
		}
		return &types.Value{
			Kind: &types.Value_BoolValue{BoolValue: parsed},
		}, parsed, nil
	case "number":
		parsed, err := strconv.ParseFloat(value, 64)
		if err != nil {
			return nil, nil, fmt.Errorf("parse number detail value: %w", err)
		}
		return numberValue(parsed), parsed, nil
	default:
		return nil, nil, fmt.Errorf("unsupported --detail-kind %q", kind)
	}
}

func parseInviteURL(inviteURL string) (string, string, error) {
	parsed, err := url.Parse(inviteURL)
	if err != nil {
		return "", "", fmt.Errorf("parse invite url: %w", err)
	}
	query := parsed.Query()
	inviteCID := query.Get("cid")
	inviteFileKey := query.Get("key")
	if inviteCID == "" || inviteFileKey == "" {
		return "", "", fmt.Errorf("invite url missing cid/key query params: %s", inviteURL)
	}
	return inviteCID, inviteFileKey, nil
}

func parseRelationFormat(raw string) (model.RelationFormat, error) {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "", "text", "longtext":
		return model.RelationFormat_longtext, nil
	case "shorttext":
		return model.RelationFormat_shorttext, nil
	case "number":
		return model.RelationFormat_number, nil
	case "status":
		return model.RelationFormat_status, nil
	case "tag":
		return model.RelationFormat_tag, nil
	case "date":
		return model.RelationFormat_date, nil
	case "file":
		return model.RelationFormat_file, nil
	case "checkbox":
		return model.RelationFormat_checkbox, nil
	case "url":
		return model.RelationFormat_url, nil
	case "email":
		return model.RelationFormat_email, nil
	case "phone":
		return model.RelationFormat_phone, nil
	case "object":
		return model.RelationFormat_object, nil
	default:
		return model.RelationFormat_longtext, fmt.Errorf("unsupported relation format %q", raw)
	}
}

func splitCSV(raw string) []string {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return nil
	}
	parts := strings.Split(trimmed, ",")
	out := make([]string, 0, len(parts))
	for _, part := range parts {
		value := strings.TrimSpace(part)
		if value != "" {
			out = append(out, value)
		}
	}
	return out
}

func structStringField(record *types.Struct, key string) string {
	value, ok := getStringField(record, key)
	if !ok {
		return ""
	}
	return value
}

func structBoolField(record *types.Struct, key string) bool {
	if record == nil {
		return false
	}
	value, ok := record.Fields[key]
	if !ok || value == nil {
		return false
	}
	boolValue, ok := value.Kind.(*types.Value_BoolValue)
	if !ok {
		return false
	}
	return boolValue.BoolValue
}

func toUniqueKey(name string) string {
	lower := strings.ToLower(name)
	var builder strings.Builder
	lastDash := false
	for _, r := range lower {
		isAlphaNum := (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9')
		if isAlphaNum {
			builder.WriteRune(r)
			lastDash = false
			continue
		}
		if builder.Len() == 0 || lastDash {
			continue
		}
		builder.WriteByte('-')
		lastDash = true
	}
	return strings.Trim(builder.String(), "-")
}

func stringValue(value string) *types.Value {
	return &types.Value{
		Kind: &types.Value_StringValue{StringValue: value},
	}
}

func numberValue(value float64) *types.Value {
	return &types.Value{
		Kind: &types.Value_NumberValue{NumberValue: value},
	}
}

func structToMap(input *types.Struct) map[string]any {
	if input == nil {
		return map[string]any{}
	}
	out := make(map[string]any, len(input.Fields))
	for key, value := range input.Fields {
		out[key] = valueToAny(value)
	}
	return out
}

func valueToAny(value *types.Value) any {
	if value == nil || value.Kind == nil {
		return nil
	}
	switch current := value.Kind.(type) {
	case *types.Value_NullValue:
		return nil
	case *types.Value_NumberValue:
		return current.NumberValue
	case *types.Value_StringValue:
		return current.StringValue
	case *types.Value_BoolValue:
		return current.BoolValue
	case *types.Value_StructValue:
		return structToMap(current.StructValue)
	case *types.Value_ListValue:
		out := make([]any, 0, len(current.ListValue.Values))
		for _, item := range current.ListValue.Values {
			out = append(out, valueToAny(item))
		}
		return out
	default:
		return nil
	}
}

func getStringField(input *types.Struct, key string) (string, bool) {
	if input == nil {
		return "", false
	}
	value, ok := input.Fields[key]
	if !ok || value == nil {
		return "", false
	}
	stringValue, ok := value.Kind.(*types.Value_StringValue)
	if !ok {
		return "", false
	}
	return stringValue.StringValue, true
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

	output := map[string]any{
		"action":    "upload",
		"object_id": response.ObjectId,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
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

	output := map[string]any{
		"action":        "download",
		"download_path": response.LocalPath,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	if response.LocalPath != "" {
		absolutePath, _ := filepath.Abs(response.LocalPath)
		output["download_path"] = absolutePath

		want, err := os.ReadFile(sourceFile)
		if err != nil {
			return fmt.Errorf("read source file %s: %w", sourceFile, err)
		}
		got, err := os.ReadFile(response.LocalPath)
		if err == nil {
			output["match"] = bytes.Equal(want, got)
		} else if _, ok := output["error_description"]; !ok {
			output["error_description"] = fmt.Sprintf("read downloaded file %s: %v", response.LocalPath, err)
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

	output := map[string]any{
		"action":          "offload",
		"bytes_offloaded": response.BytesOffloaded,
	}
	if response.Error != nil && response.Error.Code.String() != "NULL" {
		output["error_code"] = response.Error.Code.String()
		output["error_description"] = response.Error.Description
	}
	return writeJSON(output)
}

func writeJSON(value any) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	return encoder.Encode(value)
}
