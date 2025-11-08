import json
import base64
import sys

def varint(data, idx):
    res = 0
    shift = 0
    while True:
        b = data[idx]
        res |= (b & 0x7f) << shift
        shift += 7
        idx += 1
        if not (b & 0x80):
            break
    return res, idx

with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream" and ev.get("role") == "sync-node":
        msgs = ev.get("request_messages", [])
        for i, m in enumerate(msgs):
            b = base64.b64decode(m["base64"])
            print(f"Message {i} len {len(b)}: {b[:30].hex()}")
            
            # If the first byte is a tag... 0x0A (10) means field 1 (length delimited)
            if len(b) > 0 and b[0] == 0x0A:
                length, idx = varint(b, 1)
                print(f"  Field 1 length: {length}, total length: {len(b)}")
                if length == len(b) - idx:
                    print("  Looks like it's wrapped in a length-prefixed bytes field 1")
