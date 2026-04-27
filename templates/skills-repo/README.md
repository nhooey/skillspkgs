# my-skills

A first-party Claude Code skills repo built with [`nhooey/flake-skills`](https://github.com/nhooey/flake-skills).

## Quick start

1. Drop your skills into `./skills/`. Each one is a folder containing a
   `SKILL.md` with YAML frontmatter (`name`, `description`). Optional:
   `references/` for long-form docs, `scripts/` for executable helpers.
2. Lock the flake:
   ```
   nix flake lock
   ```
3. Preview what will be installed (read-only):
   ```
   nix run .
   ```
4. Install into `~/.claude/skills/` (symlinks + per-user GC roots):
   ```
   nix run .#install
   ```

Other apps:

```
nix run .#install -- --profile   # install via `nix profile install`
nix run .#uninstall              # remove all skills
nix run .#uninstall -- <name>    # remove one
nix run .#reap                   # remove broken managed entries
nix run .#reconcile              # install declared set, sweep strays
nix build .#all                  # symlinkJoin'd derivation for every skill
nix build .#<skill-name>         # single skill derivation
```

## Home-manager (optional)

Skills installed via `nix run .#install` already symlink into `~/.claude/skills/`. If you'd rather have home-manager manage installation declaratively, use `skillpkgs.homeManagerModules.default`:

```nix
{
  imports = [ inputs.skillpkgs.homeManagerModules.default ];
  programs.agent-skills = {
    enable = true;
    skills = [ inputs.self.packages.${pkgs.system}.<skill-name> ];
  };
}
```

See [`flake-skills`'s README](https://github.com/nhooey/flake-skills) for the full reference and additional configuration options (`installRoot`, `envVarOverride`, `systems`).
