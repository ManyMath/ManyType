import sys
path = ".planning/phases/28-manytype-cli-official-object-push-pull/28-02-PLAN.md"
with open(path, "r") as f:
    text = f.read()

new_findings = """**Findings & What we tried (UPDATED)**:
1. We successfully fixed the "space not exists" issue for Home B by falling back to SpacePullBootstrap if _loadSpaceBootstrap returns null.
2. We fixed HeadSync to properly compute actual heads instead of parent heads.
3. We tried sending TreeFullSyncRequest, TreeFullSyncResponse, and even adding a SpaceSubscription message before the object push. None of these caused the official node to retain the object.
4. **CRITICAL FINDING**: We parsed the official client's ObjectSyncStream (`test_vectors/phase27-object-truth.json`).
   - The official client's FIRST message for a new object contains `headUpdate.heads` AND `rootChange`.
   - The official client's message for an EXISTING object (like the Note) does NOT contain `rootChange`! It only contains `headUpdate.changes` for the new blocks!
   - Our CLI's `_buildTreeSyncMessage` currently embeds the `rootChange` into the `TreeSyncMessage` even if the server already has the tree (`isNewToServer=false`). The official node likely rejects or drops the push because it sees a redundant `rootChange` instead of just appending the new blocks via `headUpdate.changes`.
   - Also, for existing objects, the official client first sends a `TreeSyncMessage` with ONLY `headUpdate.heads`, waits for a response, and THEN sends the `TreeSyncMessage` with `headUpdate.changes`.

**Next Steps**:
1. Run `LD_LIBRARY_PATH=rust/target/debug dart test packages/manytype_cli/test/oracle_object_pull_test.dart` to see the current failure.
2. Update `packages/manytype_cli/lib/src/commands/sync.dart` -> `_buildTreeSyncMessage` to completely omit the `rootChange` from the payload if `isNewToServer` is false. Put the new changes entirely inside `content.headUpdate.changes`.
3. If necessary, adjust the `syncObject` loop to send a heads-only message first, read the response, and then send the actual changes, matching the official client's multi-step push.
4. Verify the official node accepts the object and Home B can pull it."""

# Replace from "**Findings & What we tried**:" to the end of <current_blocker>
start_idx = text.find("**Findings & What we tried**:")
if start_idx != -1:
    end_idx = text.find("</current_blocker>")
    text = text[:start_idx] + new_findings + "\n" + text[end_idx:]
else:
    # If not found, just replace Next Steps
    start_idx = text.find("**Next Steps**:")
    end_idx = text.find("</current_blocker>")
    text = text[:start_idx] + new_findings + "\n" + text[end_idx:]

with open(path, "w") as f:
    f.write(text)
