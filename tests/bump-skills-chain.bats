#!/usr/bin/env bats
# Unit tests for the pure parts of scripts/bump-skills-chain: argument
# parsing, reading a lock, and the names and messages it builds. Sourcing
# the script defines its functions without running main.

setup() {
  # shellcheck source=scripts/bump-skills-chain
  source "$BATS_TEST_DIRNAME/../scripts/bump-skills-chain"
  unset SKILLS_DEVSHELLS
}

@test "parse_args collects the message, dev shells and inputs" {
  parse_args -m "new skills" --devshell a git-skills --devshell "b c" nix-skills
  [ "$brings" = "new skills" ]
  [ "${#devshells[@]}" -eq 2 ]
  [ "${devshells[0]}" = a ]
  [ "${devshells[1]}" = "b c" ]
  [ "${#inputs[@]}" -eq 2 ]
  [ "${inputs[0]}" = git-skills ]
  [ "${inputs[1]}" = nix-skills ]
}

@test "parse_args appends SKILLS_DEVSHELLS after --devshell" {
  SKILLS_DEVSHELLS="x:y z" parse_args -m msg --devshell a git-skills
  [ "${#devshells[@]}" -eq 3 ]
  [ "${devshells[0]}" = a ]
  [ "${devshells[1]}" = x ]
  [ "${devshells[2]}" = "y z" ]
}

@test "parse_args prints usage and exits 0 on --help" {
  run parse_args --help
  [ "$status" -eq 0 ]
  # `lines` skips blank lines, so match the whole output: usage is exactly
  # the Usage block of the header.
  [[ "$output" == "Usage: scripts/bump-skills-chain -m"* ]]
  [[ "$output" == *"whose own lock pins skill repos" ]]
}

@test "parse_args exits 2 without -m" {
  run parse_args git-skills
  [ "$status" -eq 2 ]
  [[ "${lines[0]}" == "Usage:"* ]]
}

@test "parse_args exits 2 without an input" {
  run parse_args -m msg
  [ "$status" -eq 2 ]
  [[ "${lines[0]}" == "Usage:"* ]]
}

@test "parse_args exits 2 on an unknown flag" {
  run parse_args -m msg --force git-skills
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "unknown flag: --force" ]
}

@test "parse_args exits 2 when a flag's value is missing" {
  run parse_args git-skills -m
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = "-m needs a value" ]
}

@test "locked_rev reads the rev of a root input and is empty for others" {
  dir=$BATS_TEST_TMPDIR/flake
  mkdir -p "$dir"
  cat >"$dir/flake.lock" <<'EOF'
{
  "nodes": {
    "root": { "inputs": { "git-skills": "git-skills_2", "systems": ["agent-skill-flake", "systems"] } },
    "git-skills_2": { "locked": { "rev": "ab89fea0000000000000000000000000000000000" } }
  },
  "root": "root",
  "version": 7
}
EOF
  [ "$(locked_rev "$dir" git-skills)" = ab89fea0000000000000000000000000000000000 ]
  # The script runs under `set -e`, so an input it lacks must still succeed.
  run locked_rev "$dir" nix-skills
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
