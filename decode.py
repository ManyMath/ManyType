import json
import base64
import subprocess

with open("test_vectors/phase27-object-truth.json", "r") as f:
    data = json.load(f)
    interactions = data if isinstance(data, list) else data.get("interactions", [])
    for item in interactions:
        if isinstance(item, dict) and item.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
            for msg in item.get("request_messages", []):
                raw = base64.b64decode(msg["base64"])
                # The raw message might be length prefixed, but in base64 it usually isn't.
                # However, the bytes might be `Length || Protobuf`. Let's check.
                # Actually, our dart code does: [length_prefix_bytes, proto_bytes].
                # Wait, if we just decode raw:
                p = subprocess.Popen(["protoc", "--decode_raw"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
                out, _ = p.communicate(raw)
                print(out.decode())
