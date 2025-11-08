import json
import base64
import sys
import subprocess

def protoc_decode(data, msg_type):
    p = subprocess.Popen(["protoc", "--decode_raw"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate(input=data)
    if p.returncode != 0:
        return ""
    return out.decode("utf-8", errors="replace")

with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print(f"Role: {ev.get('role')}")
        print("Request messages:")
        for msg in ev.get("request_messages", []):
            decoded = base64.b64decode(msg["base64"])
            print("---")
            print(protoc_decode(decoded, "ObjectSyncMessage"))
