import json, base64

def dump_tags(data):
    i = 0
    res = []
    while i < len(data):
        tag = data[i]
        field_num = tag >> 3
        wire_type = tag & 7
        i += 1
        if wire_type == 2: # length delimited
            length = 0
            shift = 0
            while True:
                b = data[i]
                length |= (b & 0x7f) << shift
                shift += 7
                i += 1
                if not (b & 0x80):
                    break
            val = data[i:i+length]
            res.append((field_num, wire_type, length, val[:10]))
            i += length
        elif wire_type == 0: # varint
            val = 0
            shift = 0
            while True:
                b = data[i]
                val |= (b & 0x7f) << shift
                shift += 7
                i += 1
                if not (b & 0x80):
                    break
            res.append((field_num, wire_type, val, b''))
        else:
            res.append((field_num, wire_type, "unknown", b''))
            break
    return res

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
                
                print(dump_tags(raw[start:]))
