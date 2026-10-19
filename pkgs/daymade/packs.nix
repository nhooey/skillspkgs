# Canonical daymade pack definitions (skill-name lists, upstream directory
# names). Single source of truth, imported by ./default.nix (and transitively by
# the root flake's pkgs/ fold and the standalone faces). Edit pack membership
# here and nowhere else.
#
# The seven topical packs are a DISJOINT partition of all 118 skills (every skill
# in exactly one); `all` is the only overlapping bundle. Packs are topical, not
# a mirror of upstream's suites, so they freely cross suite boundaries. The
# bare directory names map to package keys `agent-skill-daymade-<name>` — the
# env builder applies that prefix, keeping the lists readable against the
# upstream tree.
{
  # All 118 skills as a single mkSkillsEnv, mirroring superpowers' `-all`. Same
  # content as the base aggregate, but with passthru.isFlakeSkillsEnv so the
  # home-manager module can expand it back into per-skill records on activation.
  agent-skills-daymade-all = [
    # skill-creation
    "skill-creator"
    "skill-reviewer"
    "skills-search"
    "skill-governance"
    "skill-evolver"
    "claude-skills-troubleshooting"
    "claude-md-progressive-disclosurer"
    # claude-code
    "read-claude-code-history"
    "read-claude-web-conversation"
    "read-codex-history"
    "local-conversation-history"
    "prior-work-retrieval"
    "continue-claude-code-work"
    "continue-codex-work"
    "claude-export-txt-better"
    "claude-migrate-memory-to-doc"
    "claude-code-hooks"
    "claude-code-ops-router"
    "claude-code-ping-start-5h-quota"
    "claude-switch-models-setup"
    "claude-usage-analyst"
    "agent-web-search-setup"
    "marketplace-dev"
    "marketplace-health-check"
    "statusline-generator"
    "prompt-optimizer"
    "peer-message"
    "ghostty-use"
    "codex-1m-context-window-setup"
    "codex-image-gallery"
    "local-codex"
    "tibo-reset-codex"
    # audio
    "audio-router"
    "asr-transcribe-to-text"
    "meeting-minutes-taker"
    "stepfun-asr"
    "stepfun-tts"
    "transcript-fixer"
    # docs
    "docs-router"
    "doc-to-markdown"
    "docs-cleaner"
    "docx-creator"
    "read-docx-review"
    "pdf-creator"
    "pdf-to-html"
    "photo-to-scanned-pdf"
    "ppt-creator"
    "slides-creator"
    "mermaid-tools"
    "excalidraw-use"
    "report-with-html"
    "data-visualization-discipline"
    # research
    "deep-research"
    "fact-checker"
    "devils-advocate"
    "competitors-analysis"
    "product-analysis"
    "app-evolver"
    "tech-selection"
    "benchmark-due-diligence"
    "financial-router"
    "financial-data-collector"
    "ashare-news-fetcher"
    "daymade-sector-research"
    "pharma-daily-report"
    "bigdata-skill"
    "gangtise-copilot"
    "ima-copilot"
    "kimi-use"
    "llm-wiki-setup"
    "bilibili-source"
    # devops
    "auto-repo-setup"
    "git-safety-net"
    "github-ops"
    "github-contributor"
    "github-review-pr"
    "github-sensitive-data-cleanup"
    "terraform-skill"
    "cloudflare-troubleshooting"
    "tunnel-doctor"
    "debugging-network-issues"
    "windows-remote-desktop-connection-doctor"
    "macos-load-doctor"
    "macos-permissions"
    "macos-watchdog"
    "openclaw"
    "openclaw-model-switch"
    "notify-wecom"
    "setup-notifications-via-wecom"
    "promptfoo-evaluation"
    "llm-eval-harness"
    "qa-expert"
    "frontend-visual-qa"
    "i18n-expert"
    "developing-ios-apps"
    # utilities
    "capture-screen"
    "terminal-screenshot"
    "cli-demo-generator"
    "douban-skill"
    "excel-automation"
    "feishu-doc-scraper"
    "wps-doc-scraper"
    "lark-cli-router"
    "download-gemini-images"
    "gemini-history-analyzer"
    "llm-icon-finder"
    "macos-cleaner"
    "repomix-safe-mixer"
    "repomix-unmixer"
    "scrapling-skill"
    "teams-channel-post-writer"
    "twitter-reader"
    "ui-designer"
    "design-style-picker"
    "interaction-design-board"
    "meme-creator"
    "video-comparer"
    "youtube-downloader"
  ];

  # Authoring & maintaining skills — create, review, search, troubleshoot,
  # govern and evolve skills, and tighten CLAUDE.md. Deliberately crosses the
  # upstream suite boundary (daymade-skill, daymade-claude-code, repo root).
  agent-skills-daymade-skill-creation = [
    "skill-creator"
    "skill-reviewer"
    "skills-search"
    "skill-governance"
    "skill-evolver"
    "claude-skills-troubleshooting"
    "claude-md-progressive-disclosurer"
  ];

  # Claude Code & agent-CLI operations — Claude Code / Codex / Kimi session
  # history and continuation, hooks, model/profile/quota setup, marketplace
  # authoring and health, statusline, prompt optimization, cross-session
  # messaging, and the daymade-codex suite's Codex CLI tooling.
  agent-skills-daymade-claude-code = [
    "read-claude-code-history"
    "read-claude-web-conversation"
    "read-codex-history"
    "local-conversation-history"
    "prior-work-retrieval"
    "continue-claude-code-work"
    "continue-codex-work"
    "claude-export-txt-better"
    "claude-migrate-memory-to-doc"
    "claude-code-hooks"
    "claude-code-ops-router"
    "claude-code-ping-start-5h-quota"
    "claude-switch-models-setup"
    "claude-usage-analyst"
    "agent-web-search-setup"
    "marketplace-dev"
    "marketplace-health-check"
    "statusline-generator"
    "prompt-optimizer"
    "peer-message"
    "ghostty-use"
    "codex-1m-context-window-setup"
    "codex-image-gallery"
    "local-codex"
    "tibo-reset-codex"
  ];

  # Audio — transcription, TTS/ASR (StepFun), meeting minutes, transcript repair,
  # and the suite router.
  agent-skills-daymade-audio = [
    "audio-router"
    "asr-transcribe-to-text"
    "meeting-minutes-taker"
    "stepfun-asr"
    "stepfun-tts"
    "transcript-fixer"
  ];

  # Documents — conversion, cleanup, review, diagrams/whiteboards, PDF/Word/PPT/
  # slide/HTML-report generation, data-visualization discipline.
  agent-skills-daymade-docs = [
    "docs-router"
    "doc-to-markdown"
    "docs-cleaner"
    "docx-creator"
    "read-docx-review"
    "pdf-creator"
    "pdf-to-html"
    "photo-to-scanned-pdf"
    "ppt-creator"
    "slides-creator"
    "mermaid-tools"
    "excalidraw-use"
    "report-with-html"
    "data-visualization-discipline"
  ];

  # Research & analysis — deep research, fact-checking, devil's advocate,
  # competitor/product/app analysis, tech selection, due diligence, financial and
  # A-share data/sector research, knowledge-base and research copilots.
  agent-skills-daymade-research = [
    "deep-research"
    "fact-checker"
    "devils-advocate"
    "competitors-analysis"
    "product-analysis"
    "app-evolver"
    "tech-selection"
    "benchmark-due-diligence"
    "financial-router"
    "financial-data-collector"
    "ashare-news-fetcher"
    "daymade-sector-research"
    "pharma-daily-report"
    "bigdata-skill"
    "gangtise-copilot"
    "ima-copilot"
    "kimi-use"
    "llm-wiki-setup"
    "bilibili-source"
  ];

  # Dev / infra / ops — repo setup, Git/GitHub (PR review, history cleanup,
  # safety net), Terraform, network & connectivity diagnosis, macOS system
  # health (load, TCC permissions, launchd watchdogs), OpenClaw config, WeCom
  # notifications, QA & LLM eval, i18n, iOS/macOS app development.
  agent-skills-daymade-devops = [
    "auto-repo-setup"
    "git-safety-net"
    "github-ops"
    "github-contributor"
    "github-review-pr"
    "github-sensitive-data-cleanup"
    "terraform-skill"
    "cloudflare-troubleshooting"
    "tunnel-doctor"
    "debugging-network-issues"
    "windows-remote-desktop-connection-doctor"
    "macos-load-doctor"
    "macos-permissions"
    "macos-watchdog"
    "openclaw"
    "openclaw-model-switch"
    "notify-wecom"
    "setup-notifications-via-wecom"
    "promptfoo-evaluation"
    "llm-eval-harness"
    "qa-expert"
    "frontend-visual-qa"
    "i18n-expert"
    "developing-ios-apps"
  ];

  # Utilities — capture, scraping, media/memes, Feishu/Lark, Gemini exports,
  # repomix, spreadsheets, UI/interaction design exploration, misc tooling.
  agent-skills-daymade-utilities = [
    "capture-screen"
    "terminal-screenshot"
    "cli-demo-generator"
    "douban-skill"
    "excel-automation"
    "feishu-doc-scraper"
    "wps-doc-scraper"
    "lark-cli-router"
    "download-gemini-images"
    "gemini-history-analyzer"
    "llm-icon-finder"
    "macos-cleaner"
    "repomix-safe-mixer"
    "repomix-unmixer"
    "scrapling-skill"
    "teams-channel-post-writer"
    "twitter-reader"
    "ui-designer"
    "design-style-picker"
    "interaction-design-board"
    "meme-creator"
    "video-comparer"
    "youtube-downloader"
  ];
}
