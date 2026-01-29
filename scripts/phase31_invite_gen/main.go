package main

import (
	"crypto/ed25519"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/anyproto/any-sync/util/crypto"
	"github.com/gogo/protobuf/proto"
	unixfspb "github.com/ipfs/boxo/ipld/unixfs/pb"
	"github.com/ipfs/boxo/ipld/merkledag"
	blocks "github.com/ipfs/go-block-format"
	"github.com/ipfs/go-cid"
	"github.com/mr-tron/base58/base58"
	mh "github.com/multiformats/go-multihash"

	model "github.com/anyproto/anytype-heart/pkg/lib/pb/model"
)

type output struct {
	OwnerAccountID string `json:"owner_account_id"`

	InviteFileCid       string `json:"invite_file_cid"`
	InviteFileKeyBase58 string `json:"invite_file_key_base58"`
	InviteBlockBase64   string `json:"invite_block_base64"`

	InviteKeyPrivateProtoBase64 string `json:"invite_key_private_proto_base64"`
	InviteKeyPublicProtoBase64  string `json:"invite_key_public_proto_base64"`

	DerivedReadKeyProtoBase64   string `json:"derived_read_key_proto_base64"`
	EncryptedReadKeyBase64      string `json:"encrypted_read_key_base64"`
	InviteUrl                   string `json:"invite_url"`
	InviteType                  string `json:"invite_type"`
	SpaceId                     string `json:"space_id"`
	SpaceName                   string `json:"space_name"`
	CreatorName                 string `json:"creator_name"`
}

func makeIpfsBlock(data []byte) (blocks.Block, error) {
	uf := &unixfspb.Data{
		Type:     unixfspb.Data_File.Enum(),
		Data:     data,
		Filesize: proto.Uint64(uint64(len(data))),
	}
	ufBytes, err := proto.Marshal(uf)
	if err != nil {
		return nil, err
	}

	node := merkledag.NodeWithData(ufBytes)
	rawBlock, err := node.EncodeProtobuf(false)
	if err != nil {
		return nil, err
	}

	prefix := cid.Prefix{
		Version:  1,
		Codec:    cid.DagProtobuf, // 0x70
		MhType:   mh.SHA2_256,
		MhLength: -1,
	}
	c, err := prefix.Sum(rawBlock)
	if err != nil {
		return nil, err
	}
	return blocks.NewBlockWithCid(rawBlock, c)
}

func main() {
	var (
		accountSeedHex = flag.String("account-seed-hex", "", "32-byte hex ed25519 seed (Manytype accountSeed)")
		spaceId        = flag.String("space-id", "", "SpaceId to embed in invite payload")
		spaceName      = flag.String("space-name", "Manytype Phase 31", "Space name to embed in invite payload")
		creatorName    = flag.String("creator-name", "manytype", "Creator name to embed in invite payload")
	)
	flag.Parse()

	if *accountSeedHex == "" || *spaceId == "" {
		fmt.Fprintln(os.Stderr, "usage: --account-seed-hex <hex32> --space-id <spaceId> [--space-name ...] [--creator-name ...]")
		os.Exit(2)
	}

	seedBytes, err := hex.DecodeString(*accountSeedHex)
	if err != nil {
		fmt.Fprintf(os.Stderr, "decode account seed hex: %v\n", err)
		os.Exit(2)
	}
	if len(seedBytes) != 32 {
		fmt.Fprintf(os.Stderr, "account seed must be 32 bytes, got %d\n", len(seedBytes))
		os.Exit(2)
	}

	ownerPriv := crypto.NewEd25519PrivKey(ed25519.NewKeyFromSeed(seedBytes))
	ownerPub := ownerPriv.GetPublic()
	ownerAccountId := ownerPub.Account()

	// Derived read key for derived ACL roots (EncryptedReadKey absent).
	ownerPrivRaw, err := ownerPriv.Raw()
	if err != nil {
		fmt.Fprintf(os.Stderr, "owner priv raw: %v\n", err)
		os.Exit(1)
	}
	derivedReadKey, err := crypto.DeriveSymmetricKey(ownerPrivRaw, crypto.AnysyncSpacePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "derive read key: %v\n", err)
		os.Exit(1)
	}
	derivedReadKeyProto, err := derivedReadKey.Marshall()
	if err != nil {
		fmt.Fprintf(os.Stderr, "marshall derived read key: %v\n", err)
		os.Exit(1)
	}

	// Invite keypair + encrypt derived read key for the invite record.
	invitePriv, invitePub, err := crypto.GenerateRandomEd25519KeyPair()
	if err != nil {
		fmt.Fprintf(os.Stderr, "generate invite keypair: %v\n", err)
		os.Exit(1)
	}
	invitePrivProto, err := invitePriv.Marshall()
	if err != nil {
		fmt.Fprintf(os.Stderr, "marshall invite priv: %v\n", err)
		os.Exit(1)
	}
	invitePubProto, err := invitePub.Marshall()
	if err != nil {
		fmt.Fprintf(os.Stderr, "marshall invite pub: %v\n", err)
		os.Exit(1)
	}
	// Upstream stores the read key as an AES key protobuf (KeyType_AES). Invite
	// joiners decrypt and unmarshal this proto to obtain the current read key.
	encryptedReadKey, err := invitePub.Encrypt(derivedReadKeyProto)
	if err != nil {
		fmt.Fprintf(os.Stderr, "encrypt read key: %v\n", err)
		os.Exit(1)
	}

	// Invite payload (WithoutApprove) + signature by creator account key.
	invitePayload := &model.InvitePayload{
		CreatorIdentity: ownerAccountId,
		CreatorName:     *creatorName,
		SpaceId:         *spaceId,
		SpaceName:       *spaceName,
		InviteType:      model.InviteType_WithoutApprove,
		AclKey:          invitePrivProto,
	}
	invitePayloadRaw, err := proto.Marshal(invitePayload)
	if err != nil {
		fmt.Fprintf(os.Stderr, "marshal invite payload: %v\n", err)
		os.Exit(1)
	}
	inviteSig, err := ownerPriv.Sign(invitePayloadRaw)
	if err != nil {
		fmt.Fprintf(os.Stderr, "sign invite payload: %v\n", err)
		os.Exit(1)
	}
	invite := &model.Invite{
		Payload:   invitePayloadRaw,
		Signature: inviteSig,
	}
	rawInvite, err := proto.Marshal(invite)
	if err != nil {
		fmt.Fprintf(os.Stderr, "marshal invite: %v\n", err)
		os.Exit(1)
	}

	// Encrypt invite and wrap as a unixfs DAG-PB block (exactly like invitestore.StoreInvite).
	inviteFileKey, err := crypto.NewRandomAES()
	if err != nil {
		fmt.Fprintf(os.Stderr, "generate invite file key: %v\n", err)
		os.Exit(1)
	}
	encryptedInvite, err := inviteFileKey.Encrypt(rawInvite)
	if err != nil {
		fmt.Fprintf(os.Stderr, "encrypt invite: %v\n", err)
		os.Exit(1)
	}
	inviteBlock, err := makeIpfsBlock(encryptedInvite)
	if err != nil {
		fmt.Fprintf(os.Stderr, "make ipfs block: %v\n", err)
		os.Exit(1)
	}
	inviteKeyRaw, err := inviteFileKey.Raw()
	if err != nil {
		fmt.Fprintf(os.Stderr, "invite file key raw: %v\n", err)
		os.Exit(1)
	}
	inviteKeyBase58 := base58.Encode(inviteKeyRaw)
	inviteCid := inviteBlock.Cid().String()
	inviteUrl := fmt.Sprintf("anytype://invite/?cid=%s&key=%s", inviteCid, inviteKeyBase58)

	out := output{
		OwnerAccountID: ownerAccountId,

		InviteFileCid:       inviteCid,
		InviteFileKeyBase58: inviteKeyBase58,
		InviteBlockBase64:   base64.StdEncoding.EncodeToString(inviteBlock.RawData()),

		InviteKeyPrivateProtoBase64: base64.StdEncoding.EncodeToString(invitePrivProto),
		InviteKeyPublicProtoBase64:  base64.StdEncoding.EncodeToString(invitePubProto),

	DerivedReadKeyProtoBase64: base64.StdEncoding.EncodeToString(derivedReadKeyProto),
	EncryptedReadKeyBase64:    base64.StdEncoding.EncodeToString(encryptedReadKey),

		InviteUrl:    inviteUrl,
		InviteType:   "WithoutApprove/AnyoneCanJoin",
		SpaceId:      *spaceId,
		SpaceName:    *spaceName,
		CreatorName:  *creatorName,
	}

	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if err := enc.Encode(out); err != nil {
		fmt.Fprintf(os.Stderr, "encode json: %v\n", err)
		os.Exit(1)
	}
}
