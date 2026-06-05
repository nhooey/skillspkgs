# my-skills

A first-party Claude Code skills repo built with [`nhooey/agent-skill-flake`](https://github.com/nhooey/agent-skill-flake).

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
   nix run . -- --scope=personal
   ```
4. Install into `~/.claude/skills/` (symlinks + per-user GC roots):
   ```
   nix run .#install -- --scope=personal
   ```

Other apps:

```
nix run .#install   -- --scope=personal           # install into $HOME
nix run .#install   -- --scope=project            # install at <project>/.claude/skills/
nix run .#install   -- --scope=custom --root=/p   # install into /p
nix run .#uninstall -- --scope=personal           # remove all skills
nix run .#uninstall -- --scope=personal <name>    # remove one
nix run .#reap      -- --scope=personal           # remove broken managed entries
nix run .#reconcile -- --scope=personal           # install declared set, sweep strays
nix build .#agent-skills-all                      # symlinkJoin'd derivation for every skill (also .#default)
nix build .#skill-<skill-name>                    # single skill derivation (skills are prefixed `skill-`)
```

## Home-manager (optional)

Skills installed via `nix run .#install` already symlink into `~/.claude/skills/`. If you'd rather have home-manager manage installation declaratively, use the `homeManagerModules.default` exported by `agent-skill-flake`:

```nix
{
  imports = [ inputs.agent-skill-flake.homeManagerModules.default ];
  programs.agent-skills = {
    enable = true;
    skills = [ inputs.self.packages.${pkgs.system}.skill-<skill-name> ];
  };
}
```

See [`agent-skill-flake`'s README](https://github.com/nhooey/agent-skill-flake) for the full reference and additional configuration options (`agent`, `systems`, and the install-time `--scope` flag).
