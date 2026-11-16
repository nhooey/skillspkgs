#!/usr/bin/env bats
# Unit tests for the pure parts of scripts/skillspkgs: command dispatch
# and help, argument parsing, reading locks, and the names and messages it
# builds. Sourcing the script defines its functions without running main.

bats_require_minimum_version 1.5.0

setup() {
  # shellcheck source=scripts/skillspkgs
  source "$BATS_TEST_DIRNAME/../scripts/skillspkgs"
  unset SKILLS_DEVSHELLS
}

# Write a flake.lock into $1 whose root locks each "<input> <rev>" argument
# as github:nhooey/<input>/<rev>, plus a `systems` input that follows
# another.
write_lock() {
  local dir=$1 input rev nodes="" roots='"systems": ["agent-skill-flake", "systems"]'
  shift
  mkdir -p "$dir"
  for pair in "$@"; do
    read -r input rev <<<"$pair"
    roots+=", \"$input\": \"${input}_2\""
    nodes+=", \"${input}_2\": { \"locked\": { \"type\": \"github\", \"owner\": \"nhooey\", \"repo\": \"$input\", \"rev\": \"$rev\" } }"
  done
  printf '{ "nodes": { "root": { "inputs": { %s } }%s }, "root": "root", "version": 7 }\n' \
    "$roots" "$nodes" >"$dir/flake.lock"
}

@test "main --help lists every command" {
  run main --help
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: skillspkgs <command> [options]" ]
  for cmd in bump-chain bump-vendored sync-aggregated check-aggregated help; do
    [[ "$output" == *"  $cmd "* ]]
  done
}

@test "main exits 2 with usage and no command" {
  run main
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "Usage: skillspkgs <command> [options]" ]
}

@test "main exits 2 on an unknown command" {
  run main frobnicate
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "unknown command: frobnicate" ]
}

@test "help COMMAND and COMMAND --help print the same usage" {
  for cmd in bump-chain bump-vendored sync-aggregated check-aggregated; do
    run main help "$cmd"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "Usage: skillspkgs $cmd"* ]]
    local via_help=$output
    run main "$cmd" --help
    [ "$status" -eq 0 ]
    [ "$output" = "$via_help" ]
  done
}

@test "help exits 2 on an unknown command" {
  run main help frobnicate
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "unknown command: frobnicate" ]
}

@test "bump-chain --help lists its options" {
  run main bump-chain --help
  [[ "$output" == *"-m, --message MESSAGE"* ]]
  [[ "$output" == *"--devshell DIR"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "commands without options exit 2 on an argument" {
  for cmd in sync-aggregated check-aggregated; do
    run main "$cmd" extra
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "unexpected argument: extra" ]
  done
}

@test "parse_bump_chain_args collects the message, dev shells and inputs" {
  parse_bump_chain_args -m "new skills" --devshell a git-skills --devshell "b c" nix-skills
  [ "$brings" = "new skills" ]
  [ "${#devshells[@]}" -eq 2 ]
  [ "${devshells[0]}" = a ]
  [ "${devshells[1]}" = "b c" ]
  [ "${#inputs[@]}" -eq 2 ]
  [ "${inputs[0]}" = git-skills ]
  [ "${inputs[1]}" = nix-skills ]
}

@test "parse_bump_chain_args takes --message for -m" {
  parse_bump_chain_args --message "new skills" git-skills
  [ "$brings" = "new skills" ]
}

@test "parse_bump_chain_args appends SKILLS_DEVSHELLS after --devshell" {
  SKILLS_DEVSHELLS="x:y z" parse_bump_chain_args -m msg --devshell a git-skills
  [ "${#devshells[@]}" -eq 3 ]
  [ "${devshells[0]}" = a ]
  [ "${devshells[1]}" = x ]
  [ "${devshells[2]}" = "y z" ]
}

@test "parse_bump_chain_args exits 2 without -m" {
  run parse_bump_chain_args git-skills
  [ "$status" -eq 2 ]
  [[ "${lines[0]}" == "Usage: skillspkgs bump-chain"* ]]
}

@test "parse_bump_chain_args exits 2 without an input" {
  run parse_bump_chain_args -m msg
  [ "$status" -eq 2 ]
  [[ "${lines[0]}" == "Usage: skillspkgs bump-chain"* ]]
}

@test "parse_bump_chain_args exits 2 on an unknown flag" {
  run parse_bump_chain_args -m msg --force git-skills
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "unknown flag: --force" ]
}

@test "parse_bump_chain_args exits 2 when a flag's value is missing" {
  run parse_bump_chain_args git-skills -m
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "-m needs a value" ]
}

@test "parse_inputs collects inputs and exits 2 without one or on a flag" {
  parse_inputs usage_bump_vendored humanizer-src superpowers-src
  [ "${inputs[*]}" = "humanizer-src superpowers-src" ]
  run parse_inputs usage_bump_vendored
  [ "$status" -eq 2 ]
  [[ "${lines[0]}" == "Usage: skillspkgs bump-vendored"* ]]
  run parse_inputs usage_bump_vendored --force humanizer-src
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "unknown flag: --force" ]
}

@test "locked_rev reads the rev of a root input and is empty for others" {
  write_lock "$BATS_TEST_TMPDIR/flake" "git-skills ab89fea"
  [ "$(locked_rev "$BATS_TEST_TMPDIR/flake" git-skills)" = ab89fea ]
  # The script runs under `set -e`, so an input it lacks, or one that
  # follows another, must still succeed.
  run locked_rev "$BATS_TEST_TMPDIR/flake" nix-skills
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  run locked_rev "$BATS_TEST_TMPDIR/flake" systems
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "pinned_ref gives a GitHub reference for a locked input only" {
  write_lock "$BATS_TEST_TMPDIR/flake" "git-skills ab89fea"
  [ "$(pinned_ref "$BATS_TEST_TMPDIR/flake" git-skills)" = github:nhooey/git-skills/ab89fea ]
  [ "$(pinned_ref "$BATS_TEST_TMPDIR/flake" systems)" = "" ]
  [ "$(pinned_ref "$BATS_TEST_TMPDIR/flake" nix-skills)" = "" ]
}

@test "lock_dirs_declaring names only the dirs whose lock has the input" {
  cd "$BATS_TEST_TMPDIR"
  write_lock pkgs "humanizer-src 1111111" "superpowers-src 2222222"
  write_lock pkgs/humanizer "humanizer-src 1111111"
  write_lock pkgs/superpowers "superpowers-src 2222222"
  mkdir -p pkgs/no-lock
  run lock_dirs_declaring humanizer-src pkgs pkgs/humanizer pkgs/no-lock pkgs/superpowers
  [ "$status" -eq 0 ]
  [ "$output" = "pkgs
pkgs/humanizer" ]
}

@test "sync_overrides names each drifted input with the root's reference" {
  write_lock "$BATS_TEST_TMPDIR/root" "agent-skill-flake a000000" "git-skills b000000" \
    "nix-skills c000000" "nixpkgs d000000"
  write_lock "$BATS_TEST_TMPDIR/sub" "agent-skill-flake a111111" "git-skills b000000" \
    "nix-skills c111111" "nixpkgs d111111" "gone-skills e000000"
  run --separate-stderr sync_overrides "$BATS_TEST_TMPDIR/root" "$BATS_TEST_TMPDIR/sub"
  [ "$status" -eq 0 ]
  [ "$output" = "agent-skill-flake github:nhooey/agent-skill-flake/a000000
nix-skills github:nhooey/nix-skills/c000000" ]
  [[ "$stderr" == "gone-skills: "* ]]
}

@test "sync_overrides prints nothing when the locks agree" {
  write_lock "$BATS_TEST_TMPDIR/root" "git-skills b000000"
  write_lock "$BATS_TEST_TMPDIR/sub" "git-skills b000000"
  run sync_overrides "$BATS_TEST_TMPDIR/root" "$BATS_TEST_TMPDIR/sub"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "moved_summary joins one, two and three inputs" {
  [ "$(moved_summary "git-skills ab89fea")" = "git-skills ab89fea" ]
  [ "$(moved_summary "git-skills ab89fea" "nix-skills bb57f90")" = "git-skills ab89fea and nix-skills bb57f90" ]
  [ "$(moved_summary "a 1111111" "b 2222222" "c 3333333")" = "a 1111111, b 2222222 and c 3333333" ]
}

@test "moved_branch names a branch after every moved input" {
  [ "$(moved_branch "git-skills ab89fea")" = update-git-skills-ab89fea ]
  [ "$(moved_branch "git-skills ab89fea" "nix-skills bb57f90")" = update-git-skills-ab89fea-nix-skills-bb57f90 ]
}

@test "commit_message puts the title, body and trailer in separate paragraphs" {
  run commit_message "Update git-skills ab89fea" "Brings in X."
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" = "Update git-skills ab89fea" ]
  [ "${lines[1]}" = "Brings in X." ]
  [[ "${lines[2]}" == "Co-Authored-By: Claude "*" <noreply@anthropic.com>" ]]
  [ "$(commit_message t b | sed -n 2p)" = "" ]
  [ "$(commit_message t b | sed -n 4p)" = "" ]
}

@test "pr_body ends the body with the Claude Code footer" {
  body=$(pr_body "Brings in X.")
  [ "$(printf '%s\n' "$body" | head -1)" = "Brings in X." ]
  [ "$(printf '%s\n' "$body" | tail -1)" = "🤖 Generated with [Claude Code](https://claude.com/claude-code)" ]
}
