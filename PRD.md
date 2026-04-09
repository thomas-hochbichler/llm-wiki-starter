# PRD: LLM Wiki — Persistent Knowledge Base

> Status: Draft v1.0 | Date: 2026-04-09 | Author: Thomas Hochbichler + Claude

---

## 1. Executive Summary

Most knowledge work tools force a trade-off: either store raw documents and re-derive understanding at query time, or maintain a curated knowledge base that becomes a maintenance burden. This project eliminates that trade-off.

**LLM Wiki** uses Claude Code as a disciplined wiki maintainer and Obsidian as a zero-infrastructure wiki browser. When you add a source, Claude doesn't merely index it — it reads, extracts, and integrates it into a structured, interlinked markdown wiki. Cross-references are built once and maintained. Contradictions are flagged proactively. Synthesis compounds with every source added and every question asked.

The core bet: **compile knowledge once, query from the compiled result** — rather than re-deriving from raw documents on every question.

---

## 2. Problem Statement

| Current State | Desired State |
|---|---|
| RAG re-derives knowledge on every query | Wiki is pre-synthesized; answers draw from compiled knowledge |
| Synthesis effort disappears into chat history | Good answers are filed back into the wiki automatically |
| Cross-references reconstructed from scratch each time | Cross-references built once, maintained continuously |
| Humans abandon wikis — maintenance burden exceeds value | Claude handles maintenance; human directs and explores |
| Contradictions discovered by accident | Contradictions flagged proactively during ingest |
| Offline collection disconnected from active knowledge base | `/llm-wiki:sync` detects and batch-ingests new sources on reconnect |

**Who feels this pain:** A single researcher, analyst, or autodidact who accumulates sources faster than they can synthesize — reading papers, articles, books, transcripts — and loses the thread between sessions.

---

## 3. Goals & Non-Goals

### Goals
- Bootstrap a working wiki for any domain in under 15 minutes
- LLM-maintained ingest, query, and lint operations with a consistent, Dataview-queryable schema
- Obsidian as a zero-configuration wiki browser with graph view
- Claude Code custom commands that reduce every recurring operation to a single invocation
- Start with a minimal schema and co-evolve it through real usage (not a pre-specified one)
- Detect and batch-ingest sources added offline via `/llm-wiki:sync`

### Non-Goals
- Multi-user collaboration or shared wikis
- External databases, vector stores, or cloud infrastructure of any kind
- Automated ingest pipelines (RSS, web crawlers, scheduled fetches)
- Building a custom UI — Obsidian is the UI
- Mobile support
- Real-time sync or conflict resolution across devices

---

## 4. Target Users

**Primary persona: The Deep Researcher**

A single person building a private knowledge base over weeks or months. They accumulate sources faster than they can synthesize. They work in sessions — sometimes connected to Claude, sometimes offline. They want their knowledge to compound, not reset.

**Variants:**
| Variant | Use Case |
|---|---|
| Academic | Reading papers, building a domain thesis |
| Autodidact | Deep dives across topics (AI, history, philosophy) |
| Analyst | Competitive intelligence, due diligence |
| Journaler | Tracking health, psychology, personal patterns |
| Book reader | Filing chapters, building character/theme pages |

**Shared trait across all variants:** They value understanding over mere retrieval. They want the wiki to make them smarter, not just faster at looking things up.

---

## 5. User Stories

### Bootstrap
- *As a new user*, I want to set up a wiki for my domain in one session, so I can start ingesting sources immediately without manual scaffolding.
- *As a new user*, I want to optionally seed an intellectual position during bootstrap if I have one, and skip it if I don't — without the system branching into distinct modes.

### Ingest
- *As a researcher*, I want to add a single source and have Claude extract entities, concepts, key claims, and update the synthesis — so I can review the result rather than do the extraction myself.
- *As a researcher*, I want Claude to discuss its framing choices before filing pages, so the wiki reflects my interpretation, not just the source's.

### Offline Sync
- *As a researcher*, I work offline frequently and drop new articles into `raw/` without an active Claude session. When I reconnect, I want to run a single command to see what's new and ingest everything in sequence.

### Query
- *As a researcher*, I want to ask synthesis questions and get answers with inline wiki citations, so I can trace claims back to sources.
- *As a researcher*, I want good answers automatically filed back into the wiki, so my explorations compound rather than disappear into chat history.

### Lint
- *As a curator*, I want to run a periodic health check every 5–10 sources and get a prioritized list of issues (contradictions, orphans, gaps) without reading every page myself.
- *As a researcher*, I want contradictions flagged proactively so I discover them during ingest, not by accident months later.

### Schema Evolution
- *As a power user*, I want to co-evolve `CLAUDE.md` with Claude as my domain and habits reveal what conventions work — and have a traceable history of what changed and why.

### Browse
- *As a reader*, I want Obsidian's graph view to show a non-trivial link structure after 10 sources — clusters, hubs, and connections I didn't explicitly create.

---

## 6. Functional Requirements

### FR-1: Bootstrap

**Trigger:** User runs `/llm-wiki:bootstrap [domain description]` or equivalent prompt.

**Requirements:**
1. Claude generates `CLAUDE.md` from the domain description using the minimal v1 schema (see FR-2 frontmatter)
2. Creates directory structure:
   ```
   raw/assets/
   wiki/entities/
   wiki/concepts/
   wiki/sources/
   wiki/index.md       (empty catalog)
   wiki/log.md         (empty log)
   wiki/overview.md    (seeded stub with ## Current Thesis and ## Thesis History sections)
   ```
3. Claude asks: *"What do you want to believe by the end of this research?"* — the answer seeds `overview.md`'s `## Current Thesis` section. Leave it empty if no position yet; you can fill it in later.
4. Adds bootstrap entry to `wiki/log.md`: `## [YYYY-MM-DD] bootstrap | <domain>`

**Acceptance:** Directory structure exists, CLAUDE.md is present, log has bootstrap entry, `overview.md` contains `## Current Thesis` and `## Thesis History` sections.

---

### FR-2: Ingest

**Trigger:** User runs `/llm-wiki:ingest <filename>` or prompts "Please ingest raw/\<filename\>".

**Steps (in order):**
1. Read source file from `raw/` — never modify
2. **Discuss** — Claude summarizes key takeaways, explains framing choices, and asks for correction before filing. Discuss by default. Skip only when the user says "skip discuss" or "batch-ingest these."
3. Write `wiki/sources/<slug>.md` with full frontmatter, summary, key claims, notable quotes, related pages
4. Identify all entities (people, orgs, products, places) → create or update `wiki/entities/<slug>.md`
5. Identify all concepts (ideas, frameworks, methodologies) → create or update `wiki/concepts/<slug>.md`
5.5. For each entity/concept page created or updated, identify typed relationships to other pages already in the wiki. Write a `## Relations` section using the typed edge format (`contradicts:`, `supports:`, `evolved_into:`, `depends_on:`). If writing a `contradicts:` edge, also add the target to the source page's `## Contradictions` section with `status: open` (and vice versa on the target page).
6. Update `wiki/overview.md` if the source meaningfully shifts the synthesis
7. Update `wiki/index.md` — add all new/updated pages with one-line summaries
8. Append to `wiki/log.md`: `## [YYYY-MM-DD] ingest | <Source Title>`
9. **Session-end validation** — verify every page touched this session is listed in `wiki/index.md` with a one-line summary, and that the required frontmatter fields are present on every page written. Fix any gaps in the same session.

**Expected scope:** 10–15 wiki files touched per source.

**Frontmatter fields (v1 schema, all required on every page):**
```yaml
type: source | entity | concept | synthesis | query
title: Human Readable Title
tags: [tag1, tag2]
sources: [source-slug.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
```

Additional fields (e.g. source confidence, quality, contradiction status) should be added through `## Schema History` entries in CLAUDE.md when real lint sessions reveal the need — not speculated into the schema on day one.

---

### FR-2b: Offline Sync (Batch Ingest)

**Trigger:** User runs `/llm-wiki:sync`.

**Requirements:**
1. List all files in `raw/` (excluding `raw/assets/`)
2. Parse `wiki/log.md` for all `ingest |` entries to extract already-processed filenames
3. Diff the two lists → identify new (uningestd) files
4. Present to user: list of new files with count, e.g. "5 new files found: [list]. Ingest all?"
5. On confirm: ingest each file sequentially using the standard FR-2 workflow (Discuss applies per-source as normal)
6. After batch completes: report summary — N sources ingested, M wiki pages created/updated, P entities/concepts added
7. **Session-end validation** — same check as FR-2 step 9: every touched page in `wiki/index.md`, required frontmatter present on every write.

**Edge cases:**
- If `raw/` contains non-text files (images, PDFs without text layer): skip with a note
- If no new files found: report "raw/ is up to date, nothing to ingest"

---

### FR-3: Query

**Trigger:** Any question asked in the Claude Code session.

**Steps:**
1. Read `wiki/index.md` to identify relevant pages
2. Read those pages (drill further if needed)
3. Synthesize an answer with inline `[[wikilink]]` citations
4. **File by default** — write a `query` or `synthesis` page to `wiki/` unless the user says "don't file this." Filing is opt-out, not opt-in.
5. Update `wiki/index.md` with the new query/synthesis page
6. Append to `wiki/log.md`: `## [YYYY-MM-DD] query | <Question Summary>`

**Key rule:** Good answers must not disappear into chat history. Explorations compound in the knowledge base just like ingested sources.

---

### FR-4: Lint

**Trigger:** User runs `/llm-wiki:lint` or prompts "Please lint the wiki." Run every 5–10 sources.

**Steps:**
1. Read `wiki/index.md` as map; read all pages (spot-check if large)
2. **Flag contradictions** — Primary pass: grep all pages for `- contradicts:` edges. For each, verify both pages have a corresponding `## Contradictions` section entry with `status: open` (or later status). Secondary pass: scan page text for untyped conflicting claims not yet captured as typed edges — flag these and suggest promoting them to `contradicts:` edges.
3. **Flag stale content** — claims superseded by newer sources (check log dates)
4. **Flag orphans** — pages with no inbound `[[wikilink]]` references
5. **Flag concept gaps** — frequently mentioned terms with no dedicated page
6. **Flag missing cross-references** — pages that should link to each other but don't
7. **Suggest sources** — knowledge gaps that could be filled with a specific document or search
8. **Suggest questions** — interesting synthesis angles worth exploring via Query
9. Append to `wiki/log.md`: `## [YYYY-MM-DD] lint | <N issues found, summary>`

**Output:** Lint report as a markdown block in chat only. Not auto-filed unless user asks.

**Contradiction Resolution Workflow:**
After a contradiction is flagged in a page's `## Contradictions` section, the human decides:
- **Investigate** — gather more sources; annotate the section with `investigating`
- **Resolve** — update the page when evidence is clear; mark the entry `resolved` and summarize the reasoning in the section body
- **Accept Tension** — sources genuinely disagree; mark the entry `accepted-tension` and leave the conflicting claims side by side

Claude updates the `## Contradictions` section body and appends the resolution to `wiki/log.md`.

---

### FR-5: Schema Management

**Requirements:**
- `CLAUDE.md` maintains a `## Schema History` section
- Update triggers: every 5 ingests, after every lint run, after any user correction ("don't do that again"), when domain shifts (new source type, new topic area)
- Entry format: `[YYYY-MM-DD] — <what changed> | Trigger: <what prompted it>`
- Schema is co-owned: human and Claude both refine it; neither has unilateral authority

---

### FR-6: Frontmatter Consistency

- Every wiki page must have the six required v1 frontmatter fields (see FR-2)
- Additional fields can be added to specific page types through `## Schema History` entries when real usage demonstrates the need — do not pre-load the schema with speculative fields
- Dataview-queryable at all times — any query across `type` and `tags` must return correct results on the v1 schema

---

## 7. Claude Code Commands

The primary UX enhancement over the baseline BRIEF: custom slash commands in `.claude/commands/llm-wiki/` reduce every workflow to a single invocation. These are markdown files containing the exact prompt Claude should execute — they are generated during bootstrap and co-evolved with `CLAUDE.md`.

| Command | File | Description |
|---|---|---|
| `/llm-wiki:bootstrap` | `.claude/commands/llm-wiki/bootstrap.md` | Prompt: domain → generates CLAUDE.md + full directory structure + seeds overview.md |
| `/llm-wiki:ingest` | `.claude/commands/llm-wiki/ingest.md` | Accepts filename argument → runs full 9-step FR-2 ingest workflow, including session-end validation |
| `/llm-wiki:sync` | `.claude/commands/llm-wiki/sync.md` | Diffs raw/ against log.md → lists new files → confirms → batch-ingests sequentially → session-end validation |
| `/llm-wiki:lint` | `.claude/commands/llm-wiki/lint.md` | Runs full FR-4 lint operation → outputs report to chat |

**Command design principles:**
- Each command file is a self-contained prompt — it references the relevant FR sections of CLAUDE.md
- Arguments are passed as `$ARGUMENTS` in the command prompt template
- Commands are created during bootstrap and updated alongside CLAUDE.md when the schema evolves
- Query, status, and thesis operations use natural-language prompts — no slash commands. Adding more commands is easy later if friction reveals the need; starting lean avoids command/CLAUDE.md drift.

---

## 8. Claude Code Hooks

**No hooks in v1.** Validation happens as the final step of the `/llm-wiki:ingest` and `/llm-wiki:sync` command prompts (see FR-2 step 9 and FR-2b step 7). A PostToolUse hook would fire on every mid-ingest write and produce noise on intermediate states — the session-end check gives the same guarantee with no settings.json to keep in sync when the schema evolves. Hooks can be introduced later if real usage reveals a gap the session-end check can't cover.

---

## 9. Technical Architecture

### Three-Layer Model

```
raw/             ← Immutable source documents. Claude reads, never writes. Source of truth.
wiki/            ← Claude-generated markdown. The compounding artifact. Human reads primarily; direct edits allowed if flagged.
CLAUDE.md        ← Schema layer. Tells Claude how the wiki is structured and what to do.
```

### Extended: Commands Layer

```
.claude/
  commands/llm-wiki/    ← Custom slash commands (generated during bootstrap, co-evolved with CLAUDE.md)
  schema-history.md     ← Rotated CLAUDE.md Schema History entries (created when CLAUDE.md exceeds 20 entries)
  settings.json         ← Empty/unused in v1; reserved for future hooks if needed
```

### File Ownership Matrix

| Layer | Owned By | Rule |
|---|---|---|
| `raw/` | Human | Claude reads only, never writes |
| `wiki/` | Claude (primary) | Human reads primarily; direct edits allowed if flagged to Claude on the next prompt so it doesn't unknowingly overwrite |
| `CLAUDE.md` | Co-owned | Human and Claude refine together; Schema History tracks changes |
| `.claude/commands/llm-wiki/` | Claude (generated) | Human may inspect; Claude updates when schema evolves |
| `.claude/schema-history.md` | Claude | Rotated Schema History entries once CLAUDE.md exceeds 20 (keeps CLAUDE.md small) |
| `.claude/settings.json` | Human | Empty/unused in v1; reserved for future hooks if needed |
| `.obsidian/` | Obsidian | Neither human nor Claude modifies directly |
| `BRIEF.md`, `PRD.md` | Human | Reference documents; Claude reads, never modifies |

---

## 10. Implementation Phases

### Phase 0 — Foundation ✓
- **Deliverable:** `PRD.md` (this document)
- **Status:** Complete

### Phase 1 — Bootstrap
- Generate `CLAUDE.md` for a test domain (using `/llm-wiki:bootstrap`)
- Create full directory structure
- Create 4 slash command files in `.claude/commands/llm-wiki/` (`bootstrap`, `ingest`, `sync`, `lint`)
- **Acceptance:** All four commands invoke without error; directory structure is correct; log has bootstrap entry; `overview.md` has `## Current Thesis` and `## Thesis History` sections

### Phase 2 — First Ingest Cycle
- Run `/llm-wiki:ingest` on 2–3 test sources
- Verify: 10–15 files touched per source, frontmatter complete, index updated, log has entries
- Open Obsidian graph view — should show initial cluster structure
- **Acceptance:** Dataview query `WHERE type = "source"` returns all ingested sources

### Phase 3 — Query + Filing
- Ask 3–5 questions in the Claude Code session (natural-language queries)
- Verify: answers contain `[[wikilinks]]`, result pages auto-filed in wiki, log updated
- **Acceptance:** `wiki/sources/` + `wiki/concepts/` + `wiki/entities/` all have non-trivial cross-links

### Phase 4 — Lint + Schema Refinement
- Run `/llm-wiki:lint` after 5 ingests
- Resolve or accept-tension all flagged contradictions
- Update `CLAUDE.md` with `## Schema History` entry
- **Acceptance:** All flagged contradictions have been either resolved or explicitly accepted-tension in each page's `## Contradictions` section; CLAUDE.md has at least one Schema History entry

### Phase 5 — Offline Sync Validation
- Add 3+ sources to `raw/` without an active Claude session
- Reconnect, run `/llm-wiki:sync`
- Verify: new files detected, batch ingest completes, summary reported
- **Acceptance:** `wiki/log.md` contains ingest entries for each new source, `wiki/index.md` lists every page the batch created, and a quick count of `## [*] ingest |` entries matches the total source count

### Phase 6 — Scale Testing (optional)
- Ingest 15–20 sources total
- Test index restructuring into typed sections at ~50 pages
- Validate Dataview queries across the v1 schema (by `type`, by `tags`)
- **Acceptance:** Query response quality exceeds cold-reading raw sources on a non-trivial synthesis question

---

## 11. Success Metrics

### Functional (per phase)

| Metric | Target | Phase |
|---|---|---|
| Answering from wiki faster than re-reading raw | Subjective — user confirms | Phase 6 |
| Obsidian graph shows non-trivial link structure | No isolated nodes after 10 sources | Phase 2–3 |
| Contradictions flagged proactively | Zero contradictions discovered by accident | Phase 4+ |
| Files touched per ingest | 10–15 | Phase 2+ |
| Log is grep-parseable | `grep "^## \[" wiki/log.md` returns all operations | Phase 1+ |
| index.md is complete | Every wiki page has an entry | Phase 2+ |
| Frontmatter is consistent | Dataview queries `type` and `tags` without errors | Phase 2+ |
| CLAUDE.md has been refined at least once | Has `## Schema History` entry | Phase 4 |
| `/llm-wiki:sync` detects offline additions | Correct diff, correct batch ingest | Phase 5 |

### Qualitative

- **Quality bar (Phase 6):** Pick a non-trivial synthesis question. Answer it from the wiki. Then answer it by cold-reading raw sources. The wiki answer should be faster, better-cited, and reveal connections the cold-read misses. If not, the wiki is a filing cabinet — revisit the ingest Discuss step and `overview.md` structure.
- **Thesis evolution:** `overview.md`'s `## Current Thesis` has been revised at least once after 20 sources, with a corresponding `## Thesis History` entry. If your position has never changed, you are filing, not thinking. (Skip if you chose not to seed a thesis at bootstrap.)

---

## 12. Open Questions & Assumptions

| Item | Decision |
|---|---|
| Wiki domain | Intentionally generic — each user seeds their own CLAUDE.md at bootstrap |
| Thesis tracking | Not a separate file; lives as `## Current Thesis` and `## Thesis History` sections inside `overview.md`. Optional to seed at bootstrap. |
| Multi-user | Out of scope — single-user only |
| CI/CD for wiki validation | Out of scope — Obsidian Git covers version history if desired |
| Web Clipper setup | Manual — outside Claude Code's scope; documented in BRIEF.md §11 |
| Image/binary files in raw/ | Skipped during ingest with a note; text-heavy sources only |
| PDF support | Text-extractable PDFs supported; scanned PDFs without text layer skipped |
| Search at scale | index.md sufficient to ~100 sources; switch to section-targeted reads at ~100; add `qmd` at ~300 |
| Discuss step | Behavioral default — discuss unless user says "skip discuss" or "batch-ingest these" |
| Schema evolution | v1 ships minimal (6 fields); additional frontmatter fields added via `## Schema History` only when real lint sessions reveal the need |

---

## Appendix A: Page Format Templates

### Source Page (`wiki/sources/<slug>.md`)
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

### Entity Page (`wiki/entities/<slug>.md`)
```markdown
---
type: entity
title: <Name>
tags: [person|org|product|place, ...]
sources: [source1.md, source2.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

One-sentence description.

## What They Did / What It Is
Paragraph synthesis across all sources mentioning this entity.

## Appearances
- [[Source Page 1]] — context of appearance

## Related
- [[Related Entity or Concept]]

## Relations
- contradicts: [[Page]] — one-line explanation
- supports: [[Page]] — one-line explanation
```

### Concept Page (`wiki/concepts/<slug>.md`)
```markdown
---
type: concept
title: <Concept Name>
tags: [framework|methodology|idea|topic, ...]
sources: [source1.md, source2.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

One-sentence definition.

## Description
Synthesis of this concept across all sources.

## Key Properties / Variants
- Property or variant 1

## Appears In
- [[Source Page]] — how it was used

## See Also
- [[Related Concept]]

## Relations
- contradicts: [[Page]] — one-line explanation
- supports: [[Page]] — one-line explanation
```

### Overview Page (`wiki/overview.md`)
```markdown
## Current Thesis
One paragraph: what you currently believe about this domain, based on everything ingested so far. Leave empty if no position yet.

## Thesis History
- YYYY-MM-DD — <one-line summary of prior position and what changed it>

## Open Questions
- Question 1 — why it matters

## Known Contradictions
- [Source A] vs [Source B] on claim X — open | investigating | resolved | accepted-tension

## Things That Changed My Mind
- Prior belief → revised belief — source that triggered the update

## Key Hubs
The 5–10 most-linked entities and concepts (updated after every lint run).
```

---

## Appendix B: Slash Command Templates

Command files live in `.claude/commands/llm-wiki/`. They are created during bootstrap and updated with `CLAUDE.md`.

### `/llm-wiki:ingest` (`.claude/commands/llm-wiki/ingest.md`)
```markdown
Please ingest the source file at `raw/$ARGUMENTS` following the full ingest workflow defined in CLAUDE.md:
1. Read the source file
2. Discuss: summarize key takeaways, explain framing, ask for correction (skip only if user says "skip discuss")
3. Write source page to wiki/sources/
4. Identify and create/update entity pages in wiki/entities/
5. Identify and create/update concept pages in wiki/concepts/
6. Update wiki/overview.md if synthesis shifts (including ## Current Thesis and ## Thesis History if position changes)
7. Update wiki/index.md with all new pages
8. Append to wiki/log.md: ## [today's date] ingest | <Source Title>
9. Session-end validation: verify every touched page is listed in wiki/index.md with a one-line summary, and that all required frontmatter fields are present on every page written. Fix any gaps in the same session.
```

### `/llm-wiki:sync` (`.claude/commands/llm-wiki/sync.md`)
```markdown
Run an offline sync to detect and ingest any new sources added to raw/ since the last session:
1. List all files in raw/ (excluding raw/assets/)
2. Parse wiki/log.md for all lines matching "ingest |" to get already-processed filenames
3. Diff the two lists to identify new (uningestd) files
4. Show the user the list of new files with count, and ask: "Ingest all N files?"
5. On confirmation, ingest each file sequentially using the full ingest workflow from CLAUDE.md (Discuss applies per-source unless user says "skip discuss")
6. After completion, report: N sources ingested, M pages created/updated
7. Session-end validation: verify every page touched during the batch is listed in wiki/index.md, and required frontmatter fields are present on every write. Fix any gaps in the same session.
```

### `/llm-wiki:lint` (`.claude/commands/llm-wiki/lint.md`)
```markdown
Run a full lint pass on the wiki following the lint workflow in CLAUDE.md:
1. Read wiki/index.md as a map; read all pages (spot-check if > 50 pages)
2. Flag contradictions — add a ## Contradictions section to each affected page listing the conflicting claim and the opposing source
3. Flag stale content — claims superseded by newer sources
4. Flag orphan pages — no inbound wikilinks
5. Flag concept gaps — frequent terms with no page
6. Flag missing cross-references
7. Suggest sources and questions
8. Output a lint report as a markdown block in chat (do not auto-file)
9. Append to wiki/log.md: ## [today's date] lint | <N issues found, summary>
```

