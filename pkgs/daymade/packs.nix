# Canonical daymade pack definitions (skill-name lists, pre-rename directory
# names). Single source of truth, imported by ./default.nix (and transitively by
# the root flake's pkgs/ fold and the standalone faces). Edit pack membership
# here and nowhere else.
#
# The seven topical packs are a DISJOINT partition of all 58 skills (every skill
# in exactly one); `all` is the only overlapping bundle. ./default.nix renames
# every skill to `daymade-<name>` (lowercased) on build, so these bare directory
# names map to package keys `agent-skill-daymade-<name>` — the env builder
# applies that prefix, keeping the lists readable against the upstream tree.
{
  # All 58 skills as a single mkSkillsEnv, mirroring superpowers' `-all`. Same
  # content as the base aggregate, but with passthru.isFlakeSkillsEnv so the
  # home-manager module can expand it back into per-skill records on activation.
  agent-skills-daymade-all = [
    # skill-creation
    "skill-creator"
    "skill-reviewer"
    "skills-search"
    "claude-skills-troubleshooting"
    "claude-md-progressive-disclosurer"
    # claude-code
    "claude-code-history-files-finder"
    "claude-export-txt-better"
    "continue-claude-work"
    "marketplace-dev"
    "statusline-generator"
    "prompt-optimizer"
    # audio
    "asr-transcribe-to-text"
    "meeting-minutes-taker"
    "stepfun-asr"
    "stepfun-tts"
    "transcript-fixer"
    # docs
    "doc-to-markdown"
    "docs-cleaner"
    "mermaid-tools"
    "pdf-creator"
    "ppt-creator"
    "slides-creator"
    # research
    "deep-research"
    "fact-checker"
    "competitors-analysis"
    "product-analysis"
    "benchmark-due-diligence"
    "financial-data-collector"
    "bigdata-skill"
    "gangtise-copilot"
    "ima-copilot"
    # devops
    "auto-repo-setup"
    "github-ops"
    "github-contributor"
    "terraform-skill"
    "cloudflare-troubleshooting"
    "tunnel-doctor"
    "debugging-network-issues"
    "windows-remote-desktop-connection-doctor"
    "promptfoo-evaluation"
    "qa-expert"
    "i18n-expert"
    "iOS-APP-developer"
    # utilities
    "capture-screen"
    "cli-demo-generator"
    "douban-skill"
    "excel-automation"
    "feishu-doc-scraper"
    "llm-icon-finder"
    "macos-cleaner"
    "repomix-safe-mixer"
    "repomix-unmixer"
    "scrapling-skill"
    "teams-channel-post-writer"
    "twitter-reader"
    "ui-designer"
    "video-comparer"
    "youtube-downloader"
  ];

  # Authoring & maintaining skills — create, review, search, troubleshoot, and
  # tighten CLAUDE.md. Deliberately crosses the upstream suite boundary (three
  # from daymade-skill, two from daymade-claude-code).
  agent-skills-daymade-skill-creation = [
    "skill-creator"
    "skill-reviewer"
    "skills-search"
    "claude-skills-troubleshooting"
    "claude-md-progressive-disclosurer"
  ];

  # Claude Code operations — session history, export repair, continuation,
  # marketplace authoring, statusline, prompt optimization.
  agent-skills-daymade-claude-code = [
    "claude-code-history-files-finder"
    "claude-export-txt-better"
    "continue-claude-work"
    "marketplace-dev"
    "statusline-generator"
    "prompt-optimizer"
  ];

  # Audio — transcription, TTS/ASR (StepFun), meeting minutes, transcript repair.
  agent-skills-daymade-audio = [
    "asr-transcribe-to-text"
    "meeting-minutes-taker"
    "stepfun-asr"
    "stepfun-tts"
    "transcript-fixer"
  ];

  # Documents — conversion, cleanup, diagrams, PDF/PPT/slide generation.
  agent-skills-daymade-docs = [
    "doc-to-markdown"
    "docs-cleaner"
    "mermaid-tools"
    "pdf-creator"
    "ppt-creator"
    "slides-creator"
  ];

  # Research & analysis — deep research, fact-checking, competitor/product
  # analysis, due diligence, financial data, knowledge-base copilots.
  agent-skills-daymade-research = [
    "deep-research"
    "fact-checker"
    "competitors-analysis"
    "product-analysis"
    "benchmark-due-diligence"
    "financial-data-collector"
    "bigdata-skill"
    "gangtise-copilot"
    "ima-copilot"
  ];

  # Dev / infra / ops — repo setup, GitHub, Terraform, network & connectivity
  # diagnosis, QA & eval, i18n, iOS app development.
  agent-skills-daymade-devops = [
    "auto-repo-setup"
    "github-ops"
    "github-contributor"
    "terraform-skill"
    "cloudflare-troubleshooting"
    "tunnel-doctor"
    "debugging-network-issues"
    "windows-remote-desktop-connection-doctor"
    "promptfoo-evaluation"
    "qa-expert"
    "i18n-expert"
    "iOS-APP-developer"
  ];

  # Utilities — capture, scraping, media, repomix, spreadsheets, misc tooling.
  agent-skills-daymade-utilities = [
    "capture-screen"
    "cli-demo-generator"
    "douban-skill"
    "excel-automation"
    "feishu-doc-scraper"
    "llm-icon-finder"
    "macos-cleaner"
    "repomix-safe-mixer"
    "repomix-unmixer"
    "scrapling-skill"
    "teams-channel-post-writer"
    "twitter-reader"
    "ui-designer"
    "video-comparer"
    "youtube-downloader"
  ];
}
