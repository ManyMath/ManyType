import json
import base64
import subprocess
import os
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print(f"\n=============================================\nRole: {ev.get('role')}")
        print("--- Request messages (Client -> Server) ---")
        for i, msg in enumerate(ev.get("request_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            with open(f"/tmp/msg_req_{i}.bin", "wb") as mf:
                mf.write(decoded)
            print(f"--- Req Msg {i} ---")
            os.system(f"protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/msg_req_{i}.bin")

        print("--- Response messages (Server -> Client) ---")
        for i, msg in enumerate(ev.get("response_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            with open(f"/tmp/msg_res_{i}.bin", "wb") as mf:
                mf.write(decoded)
            print(f"--- Res Msg {i} ---")
            os.system(f"protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/msg_res_{i}.bin")
