# Contributing

Contributions are welcome. This project is a scaffold — the most useful contributions are improvements to the slash commands, workflow extensions, and documentation clarity.

## What to contribute

- **Slash command improvements** — better prompts, more robust ingest logic, edge-case handling (e.g. scanned PDFs, non-English sources)
- **New commands** — e.g. `/export`, `/compare`, `/archive`
- **Workflow extensions** — multi-vault setups, team wikis, integration with other tools
- **Bug reports** — unexpected LLM behavior, broken command flows, Obsidian compatibility issues
- **Documentation** — clearer instructions, better examples, corrections

## How to open a PR

1. Fork the repo and create a branch from `main`
2. Make your change — keep it focused: **one concern per PR**
3. If your change affects intended behavior, update `BRIEF.md` or `PRD.md` accordingly
4. Open a PR with a short description of what changed and why

## Slash command changes

Commands live in `.claude/commands/`. Each file is a markdown prompt that Claude Code interprets as a slash command. When modifying:

- Test the command end-to-end in a real wiki before submitting
- Document any new parameters or behavior in the command file's header comment
- Keep commands self-contained — they should work without requiring changes to other files

## Issues

Use the issue templates for bug reports and feature requests. For questions or discussion, open a plain issue with the `question` label.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.
