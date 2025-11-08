import json
import base64
import os
import sys
import struct

def parse_grpc_frames(data):
    frames = []
    idx = 0
    while idx < len(data):
        if idx + 5 > len(data):
            break
        compressed = data[idx]
        length = struct.unpack(">I", data[idx+1:idx+5])[0]
        idx += 5
        frame = data[idx:idx+length]
        frames.append(frame)
        idx += length
    return frames

with open(sys.argv[1]) as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print(f"\n=============================================\nRole: {ev.get('role')}")
        print("--- Request messages (Client -> Server) ---")
        for i, msg in enumerate(ev.get("request_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            frames = parse_grpc_frames(decoded)
            for j, frame in enumerate(frames):
                print(f"--- Req Msg {i} Frame {j} ---")
                with open(f"/tmp/frame_req.bin", "wb") as mf:
                    mf.write(frame)
                os.system(f"protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/frame_req.bin > /tmp/decoded_req.txt")
                os.system("cat /tmp/decoded_req.txt")
                
                # Also decode payload
                os.system("grep -oP '(?<=payload: \").*(?=\")' /tmp/decoded_req.txt | sed 's/\\\\/\\\\\\\\/g' | xargs -I {} echo -e \"{}\" > /tmp/payload.bin 2>/dev/null")
                # A more robust way: use python to extract payload
                pass

        print("--- Response messages (Server -> Client) ---")
        for i, msg in enumerate(ev.get("response_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            frames = parse_grpc_frames(decoded)
            for j, frame in enumerate(frames):
                print(f"--- Res Msg {i} Frame {j} ---")
                with open(f"/tmp/frame_res.bin", "wb") as mf:
                    mf.write(frame)
                os.system(f"protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/frame_res.bin")

