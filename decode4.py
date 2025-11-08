import json, base64, subprocess

with open("test_vectors/phase27-object-truth.json", "r") as f:
    data = json.load(f)
    events = data.get("events", [])
    for msg in events:
        if msg.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
            for rm in msg.get("request_messages", []):
                raw = base64.b64decode(rm["base64"])
                start = 0
                if len(raw) > 4 and raw[4] == 0x0A:
                    start = 4
                elif len(raw) > 5 and raw[5] == 0x0A:
                    start = 5
                
                print("---")
                p = subprocess.run(["protoc", "--decode_raw"], input=raw[start:], capture_output=True)
                print(p.stdout.decode())
