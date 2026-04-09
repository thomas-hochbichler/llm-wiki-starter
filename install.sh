#!/usr/bin/env bash
set -euo pipefail

REPO="thomas-hochbichler/llm-wiki-starter"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
DEST=".claude/commands/llm-wiki"
FILES=(bootstrap ingest sync lint query)

# ── preflight ──────────────────────────────────────────────────────────────────

if ! command -v curl &>/dev/null; then
  echo "Error: curl is required but not installed." >&2
  exit 1
fi

echo "Installing llm-wiki commands into $(pwd)/.claude/"
echo ""

# ── create directories ─────────────────────────────────────────────────────────

mkdir -p "$DEST"

# ── download command files ─────────────────────────────────────────────────────

for name in "${FILES[@]}"; do
  file="${DEST}/${name}.md"
  if [[ -e "$file" ]]; then
    status="updated"
  else
    status="new"
  fi

  if ! curl -fsSL "${RAW}/.claude/commands/llm-wiki/${name}.md" -o "$file"; then
    echo "" >&2
    echo "Error: failed to download ${name}.md — check your network connection or" >&2
    echo "       https://github.com/${REPO}" >&2
    exit 1
  fi

  printf "  \xE2\x9C\x93 %-16s (%s)\n" "${name}.md" "$status"
done

# ── done ───────────────────────────────────────────────────────────────────────

echo ""
echo "llm-wiki installed. Commands available:"
echo "  /llm-wiki:bootstrap   initialize a new wiki"
echo "  /llm-wiki:ingest      add a source file"
echo "  /llm-wiki:sync        batch-ingest offline additions"
echo "  /llm-wiki:lint        health check"
echo "  /llm-wiki:query       answer a question"
echo ""
echo "Next: open Claude Code in this directory and run /llm-wiki:bootstrap <domain>"
