# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.0] - 2026-04-09

### Added
- `BRIEF.md` — full product brief covering vision, architecture, ingest/query/lint workflows, Obsidian setup, page format standards, and bootstrap sequence
- `PRD.md` — product requirements document with functional requirements, slash command specs, implementation phases, and success metrics
- `.claude/commands/bootstrap.md` — initialize a wiki for a new domain
- `.claude/commands/ingest.md` — add a source to the wiki with discuss-first workflow
- `.claude/commands/sync.md` — offline batch-ingest: detect new files in `raw/` and process them
- `.claude/commands/query.md` — answer questions from the wiki with inline citations
- `.claude/commands/lint.md` — health check: contradictions, orphans, gaps, stale content
