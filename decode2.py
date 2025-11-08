import json, base64, subprocess

with open("test_vectors/phase27-object-truth.json", "r") as f:
    data = json.load(f)
    for msg in data:
        if msg.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
            for rm in msg.get("request_messages", []):
                raw = base64.b64decode(rm["base64"])
                # raw bytes: might have 5 byte grpc header.
                # In drpc/grpc, first byte is 0, next 4 are length, then proto.
                # But `base64` in these test vectors is just the length-prefixed drpc message: 4 byte length prefix, then proto?
                # Actually, manytype test vectors usually store raw proto in "base64" or length-prefixed.
                # Let's write it to a file and run protoc --decode_raw.
                with open("tmp.bin", "wb") as bf:
                    # Let's assume the first 1-5 bytes might be length. 
                    # If it's pure proto, 1st byte is field tag. spaceId is field 1, so tag = 1<<3 | 2 = 10 (0x0A).
                    if raw[0] == 0x0A:
                        bf.write(raw)
                    elif raw[4] == 0x0A:
                        bf.write(raw[4:])
                    elif raw[5] == 0x0A:
                        bf.write(raw[5:])
                    else:
                        bf.write(raw) # try anyway
                
                print("---")
                p = subprocess.run(["protoc", "--decode_raw"], input=open("tmp.bin", "rb").read(), capture_output=True)
                print(p.stdout.decode())
