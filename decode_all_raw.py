import json, base64, os, sys
with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)

for i, ev in enumerate(data.get("events", [])):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        for j, msg in enumerate(ev.get("request_messages", [])):
            with open(f"/tmp/msg_raw.bin", "wb") as mf:
                mf.write(base64.b64decode(msg["base64"]))
            print(f"--- Event {i} Req Msg {j} ---")
            os.system(f"protoc --decode_raw < /tmp/msg_raw.bin")
