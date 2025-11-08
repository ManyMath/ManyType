import json
import base64
import os

with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print("Found ObjectSyncStream")
        msg = ev.get("request_messages", [])[0]
        decoded = base64.b64decode(msg["base64"])
        with open("/tmp/msg.bin", "wb") as mf:
            mf.write(decoded)
        print("Decoding as ObjectSyncMessage:")
        os.system("protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/msg.bin")
        print("Decoding as TreeSyncMessage:")
        os.system("protoc --decode=treechange.TreeSyncMessage -Iproto/any_sync proto/any_sync/treechange.proto < /tmp/msg.bin")
        break
