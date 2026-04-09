Bootstrap a new LLM Wiki for the domain: `$ARGUMENTS`

Do this in one session, without asking the user to confirm individual file writes.

## Step 1 — Domain

If `$ARGUMENTS` is empty, ask the user: *"What domain is this wiki for? (e.g. 'AI safety research', 'WWII Pacific theater', 'personal health tracking')"*. Otherwise use `$ARGUMENTS` as the domain description.

## Step 2 — Seed the thesis (optional)

Ask the user exactly this question:

> What do you want to believe by the end of this research? (One paragraph. Leave empty if you don't have a position yet — you can fill it in later.)

Capture the answer. An empty answer is fine.

## Step 3 — Generate `CLAUDE.md` at the repo root

Create `CLAUDE.md` with the following sections. Keep it concise — this is the runtime schema.

```markdown
# CLAUDE.md — LLM Wiki Schema

## Domain
<one-paragraph description of the domain, synthesized from the user's input>

## Purpose
This is an LLM-maintained wiki. Claude reads sources from `raw/`, compiles them into structured markdown under `wiki/`, and maintains cross-references, contradictions, and synthesis as new sources arrive. The wiki is browsed in Obsidian.

This file is the runtime schema — all workflows read it for directory layout, frontmatter rules, and relation format.

## Directory Layout
- `raw/` — immutable source documents. Claude reads only, never writes (except `raw/assets/` which the user manages).
- `wiki/` — Claude-generated markdown. The compounding artifact.
  - `wiki/sources/` — one page per ingested source
  - `wiki/entities/` — people, orgs, products, places
  - `wiki/concepts/` — ideas, frameworks, methodologies
  - `wiki/overview.md` — current thesis, open questions, contradictions, key hubs
  - `wiki/index.md` — catalog of every wiki page with one-line summaries
  - `wiki/log.md` — append-only operation log
- `.claude/commands/llm-wiki/` — slash commands (`/llm-wiki:bootstrap`, `/llm-wiki:ingest`, `/llm-wiki:sync`, `/llm-wiki:lint`)

## v1 Frontmatter Schema
Every wiki page MUST have these six fields:

```yaml
type: source | entity | concept | synthesis | query
title: Human Readable Title
tags: [tag1, tag2]
sources: [source-slug.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
```

Additional fields are added only when a real lint session reveals the need — not speculated up-front. Any addition is recorded in `## Schema History` below.

## Page Templates
Use the inline templates in the `/llm-wiki:ingest` command for source, entity, and concept pages, and the template in Step 4 of this command for the overview page. Every page type carries the six required frontmatter fields above.

## Workflows
- **Ingest (`/llm-wiki:ingest <filename>`):** Read `raw/<filename>`, discuss framing with the user, write source/entity/concept pages, update `overview.md` if synthesis shifts, update `index.md`, append to `log.md`, validate at session end. Expected scope: 10–15 files touched per source.
- **Sync (`/llm-wiki:sync`):** Diff `raw/` against `log.md` ingest entries, batch-ingest new files sequentially.
- **Query (natural language):** Read `index.md`, synthesize from relevant pages, cite with `[[wikilinks]]`, file the answer as a `query` or `synthesis` page unless user says "don't file this."
- **Lint (`/llm-wiki:lint`):** Flag contradictions, orphans, stale content, concept gaps, missing cross-references. Output as chat markdown, don't auto-file. Run every 5–10 sources.

## Discuss Step
Claude discusses key takeaways and framing before filing pages, by default. Skip only when the user says "skip discuss" or "batch-ingest these."

## Ownership Rules
| Layer | Owned By | Rule |
|---|---|---|
| `raw/` | Human | Claude reads only |
| `wiki/` | Claude (primary) | Human may edit directly but must flag on the next prompt |
| `CLAUDE.md` | Co-owned | Schema History tracks changes |
| `.claude/commands/llm-wiki/` | Claude (generated) | Updated when schema evolves |

## Contradiction Handling
When conflicting claims are found across pages, add a `## Contradictions` section to each affected page with the conflicting claim, the opposing source, and a status: `open` → `investigating` → `resolved` or `accepted-tension`. Resolution is decided by the user; Claude updates the section and appends the resolution to `log.md`.

## Relations Format
Use a `## Relations` section on any wiki page where the relationship type is specific enough to label:

```markdown
## Relations
- contradicts: [[Page Title]] — one-line explanation of the conflict
- supports: [[Page Title]] — one-line explanation
- evolved_into: [[Page Title]] — one-line explanation
- depends_on: [[Page Title]] — one-line explanation
```

**Rule:** Every `contradicts:` edge must be mirrored in both pages' `## Contradictions` sections with `status: open`. Use untyped `## Related` / `## See Also` for peripheral mentions where the relation type isn't clear. Typed edges are queryable by Dataview and greppable during lint — they are the primary contradiction signal.

## Schema History
<!-- Append entries here as the schema evolves. Format:
[YYYY-MM-DD] — <what changed> | Trigger: <what prompted it>
-->
```

Fill `<one-paragraph description of the domain>` with a concise synthesis of the user's domain input.

## Step 4 — Create directory structure

Create these directories and files:

```
raw/assets/.gitkeep
wiki/sources/.gitkeep
wiki/entities/.gitkeep
wiki/concepts/.gitkeep
wiki/index.md
wiki/log.md
wiki/overview.md
```

### `wiki/index.md` content

```markdown
# Wiki Index

Catalog of every wiki page with one-line summaries. Claude updates this on every `/llm-wiki:ingest`, `/llm-wiki:sync`, and query-filing.

## Sources
<!-- - [[source-slug]] — one-line summary -->

## Entities
<!-- - [[entity-slug]] — one-line summary -->

## Concepts
<!-- - [[concept-slug]] — one-line summary -->

## Synthesis & Queries
<!-- - [[query-slug]] — one-line summary -->
```

### `wiki/log.md` content

Start with a single bootstrap entry:

```markdown
# Wiki Log

Append-only log of every operation. Grep with `grep "^## \[" wiki/log.md`.

## [YYYY-MM-DD] bootstrap | <domain>
```

Replace `YYYY-MM-DD` with today's date and `<domain>` with the domain description. Then append a blank line so future entries have somewhere to land.

### `wiki/overview.md` content

Use this template. If the user gave a thesis in Step 2, put it under `## Current Thesis`. If empty, leave one line: *"No position yet — seed this after the first 5–10 sources."*

```markdown
## Current Thesis
<seeded from user's Step 2 answer, or the empty-state placeholder>

## Thesis History
<!-- - YYYY-MM-DD — prior position, what changed it -->

## Open Questions
<!-- - Question — why it matters -->

## Known Contradictions
<!-- - [Source A] vs [Source B] on claim X — open | investigating | resolved | accepted-tension -->

## Things That Changed My Mind
<!-- - Prior belief → revised belief — triggering source -->

## Key Hubs
<!-- Updated after every lint run. Top 5–10 most-linked pages. -->
```

## Step 5 — Acceptance check

Before reporting completion, verify:
- [ ] `CLAUDE.md` exists at repo root
- [ ] `raw/assets/`, `wiki/sources/`, `wiki/entities/`, `wiki/concepts/` all exist
- [ ] `wiki/index.md`, `wiki/log.md`, `wiki/overview.md` all exist
- [ ] `wiki/overview.md` contains both `## Current Thesis` and `## Thesis History`
- [ ] `wiki/log.md` contains the bootstrap entry with today's date

Report the final structure to the user and suggest the next step: *"Drop a source into `raw/` and run `/llm-wiki:ingest <filename>` — or collect a few offline and run `/llm-wiki:sync` when you're back."*
