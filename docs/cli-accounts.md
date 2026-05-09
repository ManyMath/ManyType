# Multi-account support (manytype_cli)

`manytype` supports more than one local account (mnemonic/identity) per
install. Each account has its own database: data never crosses accounts.

## Commands

- `manytype account create [--name <name>]`: generate a new mnemonic and
  register a new account profile. The first account you create is
  automatically selected as current.
- `manytype account list`: list all known accounts; `*` marks the current one.
- `manytype account use <id|name>`: select which account subsequent commands
  operate against (persisted; survives across invocations).
- `manytype account current`: print the currently-selected account.
- `manytype account remove <id>`: delete a **local** account profile (its
  config and database). This does **not** perform the Anytype protocol-level
  `AccountDelete` coordinator teardown operation: see `manytype account-delete`
  below for that, and note the two are unrelated: removing the local profile
  does not delete anything on the coordinator, and running `account-delete`
  does not remove the local profile.
- `manytype account-delete --network-config <path>`: send the protocol-level
  `AccountDelete` request to the coordinator, then immediately repeat it for
  the same identity. `AccountDelete` has no reread/status-check RPC to
  independently verify a single response the way `space-delete` can: but
  the official self-hosted oracle rejects a second `AccountDelete` call for
  an already-deleted account with "account is deleted"
  (`test_vectors/phase50/oracle_account_delete.json`), and `manytype_server`
  now mirrors that idempotency contract. The command accepts
  (`supported-and-verified`, exit 0) only when the second call is
  independently rejected on those grounds; otherwise it exits non-zero with
  a structured `unsupported-surface-or-scenario` assessment. See
  `docs/m018-account-delete-idempotency.md`.

Every other command (`create`, `sync`, `read`, `edit`, `list`, etc.) operates
against whichever account is currently selected, using this precedence:

1. An explicit `--account <id|name>` flag
2. The `MANYTYPE_ACCOUNT` environment variable
3. The persisted "current" account (`manytype account use`)
4. Auto-selected, if exactly one account exists
5. Otherwise: a clear error: ambiguous (2+ accounts, no selection) or none
   (0 accounts)

## Storage layout

Each account's config and database live under
`~/.manytype/accounts/<accountId>/{config.toml,store.db}`, indexed by
`~/.manytype/accounts.json` and a `~/.manytype/current` pointer file.
`<accountId>` is derived deterministically from the account's public key, so
re-importing the same mnemonic always resolves to the same account id.

## Upgrading from a single-account install

If you only ever ran `manytype init` (before multi-account support existed),
your mnemonic and database live at the legacy top-level
`~/.manytype/config.toml`/`store.db`. The first time any account-aware
command runs afterward, this legacy install is automatically registered as a
real account profile (named `default`): **without moving or copying any
files**; the registered profile simply points at your existing config/db in
place. This is idempotent (safe to run repeatedly) and preserves your data
exactly as-is. You can then create additional accounts normally with
`manytype account create --name <name>`.
