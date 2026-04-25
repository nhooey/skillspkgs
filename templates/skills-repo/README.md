# my-skills

A collection of [Claude Code Agent Skills](https://docs.claude.com/), packaged
as a Nix flake with [skillpkgs](https://github.com/nhooey/skillspkgs).

## Quick start

1. Drop your skills into `./skills/`. Each one is a folder containing a
   `SKILL.md` with YAML frontmatter (`name`, `description`).
2. Build the bundle:
   ```
   nix build
   ```
3. Install into `~/.claude/skills` (copies, not symlinks):
   ```
   nix run .#install
   ```

## Home-manager

```nix
{
  imports = [ inputs.my-skills.homeManagerModules.default ];
  programs.agent-skills.enable = true;
}
```

## Optional: per-skill runtime dependencies

If a skill ships executable helpers under `scripts/`, drop a `skill.nix`
sidecar next to its `SKILL.md` to declare what they need on PATH:

```nix
{ pkgs, ... }:
{
  runtimeInputs = [ pkgs.jq pkgs.curl ];
}
```

The sidecar is read by the discovery layer and not copied into the install.
