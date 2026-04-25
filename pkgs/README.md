# pkgs/

Curated wrappers for third-party Agent Skills.

## Layout

Each wrapper is its own folder under `pkgs/` with a `default.nix`:

```
pkgs/
├── default.nix         # imports every wrapper and exposes them as an attrset
└── <skill-name>/
    └── default.nix     # one wrapper
```

## What `default.nix` should look like

A wrapper vendors **metadata only** — the upstream URL, revision, and sha256.
Source itself is fetched from the upstream repository at build time:

```nix
{ pkgs, mkSkill }:
mkSkill {
  inherit pkgs;
  name = "example-skill";
  src = pkgs.fetchFromGitHub {
    owner = "<upstream-owner>";
    repo = "<upstream-repo>";
    rev = "<commit-sha>";
    sha256 = "<sha256>";
  };
  # If the upstream skill ships scripts/ with executable helpers, list
  # their runtime dependencies here so makeWrapper can put them on PATH:
  # runtimeInputs = [ pkgs.jq pkgs.curl ];
}
```

If the skill lives inside a subdirectory of the upstream repo, post-fetch
the relevant subtree so `SKILL.md` ends up at the source root — `mkSkill`
expects to find it there.

Then add an entry to `pkgs/default.nix`:

```nix
example-skill = pkgs.callPackage ./example-skill { inherit mkSkill; };
```

## Computing the sha256

```bash
nix run nixpkgs#nix-prefetch-github -- <owner> <repo> --rev <commit-sha>
```

Paste the resulting hash into your wrapper's `sha256` field.

## Review

`/pkgs/` has no CODEOWNER, so PRs adding wrappers don't auto-request review.
That's deliberate — third-party additions are open contribution territory.
