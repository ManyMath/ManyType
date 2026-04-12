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
  `AccountDelete` coordinator teardown operation — that is a distinct, still
  out-of-scope operation (see `.gsd/DECISIONS.md`).

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
