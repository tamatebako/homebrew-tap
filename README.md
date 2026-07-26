# tamatebako/homebrew-tap

Homebrew tap for the tebako ecosystem.

## For users

```console
$ brew install tamatebako/tap/tebako
```

The `tebako` formula installs the four tebako binaries (`tebako`, `tfs`,
`tebako-pkg`, `tebako-shim`) plus shell completions, per platform with
sha256 verification. It lands here when tebako-rs ships v0.1.0 —
until then, see https://github.com/tamatebako/tebako-rs/releases.

## For app developers (persona C)

Ship your tebako-packaged app through your own tap using our template:

1. Create a `homebrew-tap` repo in your org.
2. Copy `templates/app-formula.rb.template` to `Formula/<yourapp>.rb`
   and fill the four `@@PLACEHOLDER@@` slots (app name, release base URL,
   version, per-platform sha256s — emitted by `tebako publish` or your
   release workflow).
3. Users then: `brew install <yourorg>/tap/<yourapp>`.

The template downloads the standalone tebako binary for the user's
platform (slim primary — the runtime resolves once into the shared
machine cache on first run; fat variants work fully offline). See
docs/spec/16 in tebako-rs for the full distribution model.
