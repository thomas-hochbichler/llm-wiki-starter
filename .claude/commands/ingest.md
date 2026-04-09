Ingest the source file `raw/$ARGUMENTS` into the wiki.

Follow the full 9-step workflow from FR-2 in PRD.md and the schema in CLAUDE.md.

## Step 1 — Read the source

Read `raw/$ARGUMENTS`. Never modify the source file. If the file is missing, ask the user for the correct filename. If it's a binary or scanned PDF with no extractable text, report it and stop.

## Step 2 — Discuss (default on)

Before writing any wiki pages:
1. Summarize the 3–7 key takeaways from the source
2. Explain your framing choices — what angle you're planning to take, which entities/concepts you'll extract, any ambiguities
3. Ask the user: *"Does this framing match your interpretation, or should I re-angle anything before filing?"*

Skip this step ONLY if the user has said "skip discuss" or "batch-ingest these" for this session or this specific ingest.

## Step 3 — Write the source page

Create `wiki/sources/<slug>.md` using the Appendix A source template:

```markdown
---
type: source
title: <Article/Document Title>
tags: [topic1, topic2]
sources: [<original-filename>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Summary
2–4 paragraph synthesis of the source.

## Key Claims
- Claim 1 (with context)
- Claim 2

## Notable Quotes
> "Direct quote from source."

## Related Pages
- [[Related Entity]]
- [[Related Concept]]

## Sources
- `raw/<original-filename>`
```

All six frontmatter fields are required. `<slug>` should be a lowercase, hyphenated version of the title.

## Step 4 — Entity pages

Identify every person, organization, product, and place mentioned in the source. For each:
- If `wiki/entities/<slug>.md` does not exist, create it from the Appendix A entity template.
- If it exists, update the `## What They Did / What It Is`, `## Appearances`, and `## Related` sections to incorporate what this source adds. Bump `updated:` to today. Append this source's slug to the `sources:` frontmatter list if not already present.

## Step 5 — Concept pages

Identify every idea, framework, methodology, or topic. Same create-or-update logic as Step 4, using the Appendix A concept template and `wiki/concepts/<slug>.md`.

## Step 5.5 — Typed edges

For each entity/concept page created or updated in steps 4–5, identify typed relationships to other pages already in the wiki. Write a `## Relations` section using the format:

```markdown
## Relations
- contradicts: [[Page Title]] — one-line explanation of the conflict
- supports: [[Page Title]] — one-line explanation
- evolved_into: [[Page Title]] — one-line explanation
- depends_on: [[Page Title]] — one-line explanation
```

Only include edges where the relation type is clear from the source. Leave peripheral or uncertain mentions as untyped `## Related` links.

**Rule:** If writing a `contradicts:` edge, also add the target page to the current page's `## Contradictions` section with `status: open`, and add the current page to the target's `## Contradictions` section with `status: open`.

## Step 6 — Update `wiki/overview.md` (only if synthesis shifts)

Only edit `overview.md` if this source *meaningfully changes* the thesis, opens a new question, or introduces a new contradiction. Specifically:
- If `## Current Thesis` needs revising: copy the prior thesis to `## Thesis History` with today's date and a one-line note on what changed, then rewrite `## Current Thesis`.
- Add open questions, contradictions, or "changed my mind" entries as applicable.
- If the source is routine and doesn't shift synthesis, leave `overview.md` alone.

## Step 7 — Update `wiki/index.md`

Add a one-line entry under the appropriate section (`## Sources`, `## Entities`, `## Concepts`) for every page created or updated in steps 3–5. Format: `- [[slug]] — one-line summary`. For updates, refresh the summary if it's now stale.

## Step 8 — Append to `wiki/log.md`

Add one line at the bottom:

```markdown
## [YYYY-MM-DD] ingest | <Source Title>
```

Use today's date. `<Source Title>` should match the `title:` field of the source page.

## Step 9 — Session-end validation

Before reporting done, verify:
- [ ] Every page touched in this ingest is listed in `wiki/index.md`
- [ ] Every page written has all six required frontmatter fields (`type`, `title`, `tags`, `sources`, `created`, `updated`)
- [ ] The log entry is present with today's date

Fix any gaps in the same session — don't report "done" until the check passes.

## Expected scope

A typical ingest touches **10–15 files**: 1 source page, 3–6 entities, 3–6 concepts, possibly `overview.md`, always `index.md` and `log.md`. If you're touching fewer than 5, double-check that you haven't missed entities/concepts. If you're touching more than 20, you may be creating entity/concept pages for peripheral mentions — prefer linking existing pages.

Report at the end: which pages were created vs. updated, and whether `overview.md` was touched.
