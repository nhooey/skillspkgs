# The locked source of each vendored skill, keyed by its pkgs/<name>
# directory, from a flake's `*-src` inputs. Both the root flake and the
# standalone pkgs/flake.nix pass their inputs here, so the two can't name
# different sources. It must name every pkgs/<name>/ directory: default.nix
# forces `srcs.<name>` for each one it discovers.
inputs: {
  caveman = inputs.caveman-src;
  "clojure-skills" = inputs.clojure-skills-src;
  daymade = inputs.daymade-skills-src;
  humanizer = inputs.humanizer-src;
  malli = inputs.clojure-malli-skill-src;
  "opinionated-software-engineering" = inputs.opinionated-claude-skills-src;
  pstack = inputs.cursor-plugins-src;
  "shadow-cljs" = inputs.clojure-shadow-cljs-skill-src;
  "rust-best-practices" = inputs.apollographql-skills-src;
  "skill-creator" = inputs.anthropics-skills-src;
  superpowers = inputs.superpowers-src;
  "tla-check" = inputs.younes-io-agent-skills-src;
  "typescript-strict" = inputs.citypaul-dotfiles-src;
  trailofbits = inputs.trailofbits-skills-src;
  "update-changelog" = inputs.agent-stuff-src;
}
