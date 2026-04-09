Run a full lint pass on the wiki.

Run this every 5–10 sources. Output the report as a markdown block in chat — **do not** auto-file it unless the user explicitly asks.

## Step 1 — Map the wiki

Read `wiki/index.md` to get the full page catalog. Then read every page under `wiki/` (spot-check a representative sample if the wiki exceeds 50 pages). Note the `updated:` dates and `sources:` lists as you go.

## Step 2 — Flag contradictions

**Primary pass — typed edges:** Grep all pages under `wiki/` for lines matching `^- contradicts:`. For each edge found:
1. Verify both pages have a `## Contradictions` section entry referencing each other with a current status (`open`, `investigating`, `resolved`, or `accepted-tension`)
2. If missing or out of sync, add or update the entry: list the conflicting claim, the opposing page (`[[wikilink]]`), and `status: open`
3. Record confirmed contradictions in the lint report

**Secondary pass — untyped conflicts:** Scan page text for conflicting claims not yet captured as `contradicts:` edges. For each found, flag it in the lint report and suggest: "Consider promoting to a typed edge: `- contradicts: [[Page]] — <explanation>`."

**Contradiction resolution lifecycle:** `open` → `investigating` → `resolved` or `accepted-tension`. The user decides. When they do, update the page's `## Contradictions` section with the new status and a one-sentence rationale, and append a log entry to `wiki/log.md`:

```markdown
## [YYYY-MM-DD] contradiction-resolved | <page> — <one-line summary>
```

## Step 3 — Flag stale content

Compare `updated:` dates against the log. If a page makes a claim that a newer source contradicts or supersedes, flag it as stale. Don't auto-rewrite — just list.

## Step 4 — Flag orphan pages

Find any page with zero inbound `[[wikilinks]]` (i.e. no other wiki page references it). An orphan is fine if it's genuinely peripheral, but it often means a cross-reference is missing. List all orphans with a one-line "looks deliberate" vs "looks missing" judgment.

## Step 5 — Flag concept gaps

Scan source and synthesis pages for terms that appear frequently (3+ times across 2+ sources) but have no dedicated `wiki/concepts/` page. List each with a suggested slug.

## Step 6 — Flag missing cross-references

Find page pairs that clearly *should* link to each other but don't — e.g. an entity and a source that discusses them, two concepts mentioned together in multiple sources, etc. List suggestions.

## Step 6.5 — Flag untyped relation candidates

Scan all `## Related` and `## See Also` sections. For each untyped link where the relation type is obvious (e.g. "X is a prerequisite for Y", "X superseded by Y"), flag it in the report as a candidate for promotion to a typed edge. Format: `[[Source page]] → [[Target page]]: suggest \`depends_on\` / \`evolved_into\` / etc.`

## Step 7 — Suggest sources and questions

- **Sources:** What specific documents, papers, or searches would fill the biggest gaps? List 3–5 concrete suggestions.
- **Questions:** What synthesis angles are worth exploring via a natural-language query? List 3–5.

## Step 8 — Output the lint report (chat only)

Emit the report as a single markdown block in the chat:

```markdown
# Lint Report — YYYY-MM-DD

## Contradictions (N)
- ...

## Stale (N)
- ...

## Orphans (N)
- ...

## Concept gaps (N)
- ...

## Missing cross-references (N)
- ...

## Suggested sources
- ...

## Suggested questions
- ...

## Summary
<one-paragraph overall health read>
```

Do NOT write this report to a file unless the user says "file this lint report."

## Step 9 — Append to `wiki/log.md`

Add one line:

```markdown
## [YYYY-MM-DD] lint | <N issues found> — <one-line summary>
```

where `<N issues found>` totals contradictions + stale + orphans + concept gaps + missing cross-refs.
