import json, base64, os
with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)
for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream" and ev.get("role") == "sync-node":
        b = base64.b64decode(ev["request_messages"][0]["base64"])
        with open("/tmp/msg.bin", "wb") as mf:
            mf.write(b)
        print("Try decoding as ObjectSyncMessage:")
        os.system("protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/msg.bin 2>&1")
        break
