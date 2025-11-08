import json, base64, subprocess, struct

with open("test_vectors/phase27-object-truth.json", "r") as f:
    events = json.load(f).get("events", [])

for event in events:
    if event.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print(f"Role: {event.get('role')}")
        for i, rm in enumerate(event.get("request_messages", [])):
            raw = base64.b64decode(rm["base64"])
            print(f"--- Request {i} ---")
            p = subprocess.Popen(
                ["protoc", "--decode_raw"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            out, err = p.communicate(input=raw)
            print(out.decode())
            print(err.decode())
