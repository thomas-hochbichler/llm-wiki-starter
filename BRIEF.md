# LLM Wiki — Product Brief

> *"Obsidian is the IDE. The LLM is the programmer. The wiki is the codebase."*  
> — Andrej Karpathy, April 2026

---

## 1. Vision

Most interactions with LLMs and documents follow the RAG pattern: upload files, retrieve relevant chunks at query time, generate an answer. This works — but the LLM rediscovers knowledge from scratch on every question. Nothing compounds. Ask something requiring synthesis across five documents and the LLM must piece it together from fragments, again, every time.

The alternative: rather than retrieving from raw documents during queries, the LLM **incrementally builds and maintains a persistent wiki** — a structured, interlinked collection of markdown files that sits between you and your raw sources. When you add a new source, the LLM doesn't merely index it. It reads it, extracts what matters, and integrates it — updating entity pages, revising topic summaries, flagging contradictions, strengthening synthesis. Knowledge compiles once and stays current.

**The wiki is a persistent, compounding artifact.** Cross-references already exist. Contradictions have been flagged. Synthesis already reflects everything ingested. It grows richer with every source added and every question asked.

The human's job: curate sources, direct analysis, ask good questions.  
The LLM's job: everything else — summarizing, cross-referencing, filing, bookkeeping.

This idea connects to Vannevar Bush's *Memex* (1945) — a personal, curated knowledge store with associative trails between documents. Bush's vision was closer to this than to what the web became: private, actively curated, connections as valuable as documents. The part he couldn't solve was who does the maintenance. The LLM handles that.

**This project implements that vision using Claude Code as the LLM agent and Obsidian as the wiki browser.**

---

## 2. Problem Statement

| Current state | Desired state |
|---|---|
| RAG/file uploads re-derive knowledge on every query | Wiki is pre-synthesized; answers come from compiled knowledge |
| Synthesis effort is not saved | Good answers get filed back into the wiki |
| Cross-references must be reconstructed each time | Cross-references are maintained continuously |
| Humans abandon wikis — maintenance burden > value | LLM does maintenance; humans direct and explore |
| Contradictions discovered by accident | Contradictions flagged proactively on ingest |

---

## 3. Scope & Use Cases

**Primary user**: single person building a personal knowledge base.

**Target use cases** (pick any):
- **Research**: going deep on a topic over weeks — reading papers, articles, building a comprehensive wiki with an evolving thesis
- **Book reading**: filing each chapter, building character/theme/plot pages; personal Tolkien Gateway
- **Personal**: tracking goals, health, psychology — journal entries, podcast notes, structured self-picture over time
- **Competitive analysis, due diligence, course notes, hobby deep-dives** — anything where knowledge accumulates over time

**Constraints**:
- LLM agent: Claude Code (Sonnet 4.6 / Opus 4.6)
- Wiki reader: Obsidian
- Storage: local markdown files only — no external databases or services
- Sources: text-heavy (articles, papers, notes); images supported via local download
- Scale: designed for ~10–300 sources; search tooling optional beyond that

---

## 4. Architecture: Three Layers

```
raw/          ← Immutable source documents. LLM reads, never writes. Source of truth.
wiki/         ← LLM-generated markdown. The compounding artifact. LLM owns entirely.
CLAUDE.md     ← Schema layer. Tells Claude Code how the wiki is structured and what to do.
```

The schema (`CLAUDE.md`) is the critical file. It transforms Claude Code from a generic chatbot into a disciplined wiki maintainer. You and Claude co-evolve it as you discover what works for your domain.

---

## 5. Directory Structure

```
/
├── CLAUDE.md              # Schema & workflow instructions for Claude Code
├── BRIEF.md               # This document
│
├── raw/                   # Immutable sources (Claude reads, never modifies)
│   ├── assets/            # Downloaded images (set as Obsidian attachment folder)
│   └── <source files>     # Articles (.md), PDFs, notes, data files
│
├── wiki/                  # Claude-owned knowledge layer
│   ├── index.md           # Content catalog: every page with link + one-line summary
│   ├── log.md             # Append-only operation log (grep-parseable)
│   ├── overview.md        # High-level synthesis: current thesis, thesis history, open questions, contradictions, mind-changes
│   ├── entities/          # Pages for people, organizations, products, places
│   ├── concepts/          # Pages for ideas, frameworks, methodologies, topics
│   └── sources/           # Per-source summary pages
│
└── .obsidian/             # Obsidian vault configuration
```

**Rules:**
- `raw/` is read-only for Claude. Never modify source files.
- `wiki/` is primarily read-for-the-human. Prefer asking Claude to edit pages so the LLM can keep index.md and cross-links consistent. Direct edits are allowed — if you make one, mention what you changed on your next prompt so Claude doesn't unknowingly overwrite your change.
- `CLAUDE.md` is co-edited — the human and Claude both refine it over time.

---

## 6. CLAUDE.md Schema Design

The starter `CLAUDE.md` (generated during bootstrap) must contain these sections. Claude and the user will refine them over time.

### Required sections:

**Wiki Identity**
- One-paragraph description of what this wiki is about and what domain it covers
- Who the intended reader is
- What kinds of sources will be ingested

**Page Type Definitions**
- `source` — summary of a single ingested document
- `entity` — a person, organization, product, or place that appears across sources
- `concept` — an idea, framework, methodology, or topic
- `synthesis` — a cross-cutting analysis or comparison across multiple sources
- `query` — a valuable answer that was filed back from a Q&A session

**Special Root Files** (not page-typed, not in subdirectories)
- `wiki/overview.md` — continuously updated high-level synthesis of all ingested material; contains `## Current Thesis` and `## Thesis History` sections (see Section 10). Seed the thesis during bootstrap with the answer to: *What do you want to believe by the end of this research?* Leave it empty if you don't have a position yet.

**Frontmatter Schema** (applied to every wiki page):
```yaml
---
type: source | entity | concept | synthesis | query
title: Human Readable Title
tags: [tag1, tag2]
sources: [source-slug.md]         # which raw sources informed this page
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

> **Start minimal**: these six fields are the v1 schema. Additional fields (source confidence, extraction confidence, source quality, contradiction status, etc.) should be added through `## Schema History` entries when real usage reveals the need — not speculated into the schema on day one. CLAUDE.md co-evolution is the mechanism for discovering what conventions work for your domain; don't skip it by pre-loading the schema.

**Wikilink Conventions**
- Use `[[Page Title]]` syntax throughout (Obsidian-compatible)
- Before writing a link, check `wiki/index.md` to confirm the page exists or will be created
- Never leave broken wikilinks — create stub pages rather than omit the link
- Typed edges use a `## Relations` section: `- type: [[Target]] — explanation`. Four types: `contradicts`, `supports`, `evolved_into`, `depends_on`. Use when the relationship is specific enough to label; leave untyped `## Related` / `## See Also` links for peripheral mentions where the type isn't clear.

**Naming Conventions**
- Filenames: `kebab-case.md` (e.g., `andrej-karpathy.md`, `retrieval-augmented-generation.md`)
- Page titles: Title Case (e.g., "Retrieval Augmented Generation")
- Directory: `entities/` for proper nouns, `concepts/` for abstract ideas

**Index & Log Update Rules**
- `wiki/index.md`: update on every ingest; format: `- [[Page Title]] — one-line summary`
- `wiki/log.md`: append-only; each entry starts with `## [YYYY-MM-DD] <operation> | <title>`
- Never delete log entries

**Output Format Options**
- Default: markdown page filed into wiki
- Comparison: markdown table
- Presentation: Marp slide deck (fenced with `<!-- marp: true -->`). Best for: summarizing a single source for sharing, presenting a synthesis to an audience. Trigger phrase: "Make a slide deck for...". Claude will produce a 5–10 slide structure with one claim per slide.
- Claude should offer the most appropriate format per query type

**Schema Maintenance**

CLAUDE.md must include a `## Schema History` section tracking: date, what changed, what prompted the change. Update CLAUDE.md when:
- Every 5 ingests
- After every lint run
- Any time you correct Claude's formatting or emphasis ("don't do that again")
- Any time the domain shifts (new source type, new topic area)

Format: `[YYYY-MM-DD] — <what changed> | Trigger: <what prompted it>`

**Compaction rule**: When `## Schema History` exceeds 20 entries, rotate older entries to `.claude/schema-history.md` and keep a one-line pointer in CLAUDE.md. CLAUDE.md is loaded on every session — don't let it bloat silently. Operational state lives under `.claude/`; content lives under `wiki/`.

---

## 7. Ingest Operation

**Trigger**: "Please ingest `raw/<filename>`" (or any equivalent phrasing)

**Steps** (Claude executes these in order):

1. **Read** the source file from `raw/`
2. **Discuss** — Claude summarizes key takeaways, highlights what it chose to emphasize and why, and asks if the framing is correct. This is the calibration step — skip it and the wiki drifts from your frame toward the source's frame. Discuss by default. Skip only when the user says "skip discuss" or "batch-ingest these."
3. **Write source page** → `wiki/sources/<source-slug>.md` with full summary, key claims, quotes, and frontmatter
4. **Identify entities** — list all people, organizations, products, places mentioned; create or update `wiki/entities/<entity-slug>.md` for each
5. **Identify concepts** — list all ideas, frameworks, and topics; create or update `wiki/concepts/<concept-slug>.md` for each
6. **Update overview** — revise `wiki/overview.md` if the new source shifts the synthesis or introduces a significant new thread
7. **Update index** — add any new pages to `wiki/index.md` with a one-line summary
8. **Append to log** — `## [YYYY-MM-DD] ingest | <Source Title>`
9. **Session-end validation** — before ending, verify every new or touched page is listed in `wiki/index.md` with a one-line summary, and that required frontmatter fields are present on every page written this session. Fix any gaps in the same session.

**Expected scope**: 10–15 wiki files touched per source.  
**Style**: prefer to ingest one source at a time and stay involved. Read the summaries, check the updates, guide what to emphasize. You can batch-ingest with less supervision — document your preference in CLAUDE.md.

**Index scaling**: When `wiki/index.md` exceeds ~50 pages, restructure it into typed sections (Sources, Entities, Concepts, Syntheses). When it exceeds ~100 pages, add `wiki/index-by-tag.md` as a secondary index organized by tag clusters. Claude maintains both. At ~100 sources, switch from full-index reads to section-targeted reads during queries.

---

## 8. Query Operation

**Trigger**: Any question asked in the Claude Code session

**Steps**:

1. **Read `wiki/index.md`** to identify relevant pages
2. **Read** those pages (drill further if needed)
3. **Synthesize** an answer with inline `[[wikilink]]` citations to wiki pages
4. **File by default** — After synthesizing an answer, Claude writes a `query` or `synthesis` page unless the user explicitly says "don't file this." Good answers must not disappear into chat history — that defeats the entire system. The default is to file; the exception is ephemeral or trivial answers.
5. **Append to log** — `## [YYYY-MM-DD] query | <Question Summary>`

**Key insight**: good answers shouldn't disappear into chat history. A comparison you asked for, an analysis, a connection you discovered — file them back. Your explorations compound in the knowledge base just like ingested sources do. Filing is opt-*out*, not opt-in.

---

## 9. Lint Operation

**Trigger**: "Please lint the wiki" (run periodically, e.g., after every 5–10 sources)

**Steps**:

1. Read `wiki/index.md` as a map; read all pages (or spot-check if large)
2. **Flag contradictions** — claims on different pages that conflict; for each, add a `## Contradictions` section to the affected pages listing the conflicting claim and the opposing source
3. **Flag stale content** — claims superseded by newer sources (check log dates)
4. **Flag orphans** — pages with no inbound `[[wikilink]]` references
5. **Flag concept gaps** — important terms mentioned frequently but lacking their own page
6. **Flag missing cross-references** — two pages that should link to each other but don't
7. **Suggest sources** — gaps in knowledge that could be filled with a web search or specific document
8. **Suggest questions** — interesting angles worth exploring via Query
9. **Append to log** — `## [YYYY-MM-DD] lint | <N issues found, summary>`

**Contradiction Resolution Workflow**: Once a contradiction is flagged in a page's `## Contradictions` section, the human decides how to proceed:
- **Investigate** — gather more sources to resolve the conflict; note `investigating` in the section body
- **Resolve** — update the page when the evidence is clear; mark the entry `resolved` and summarize the reasoning in the section body
- **Accept tension** — note that sources genuinely disagree; mark the entry `accepted-tension` and leave the conflicting claims side by side

Claude updates the `## Contradictions` section and appends the resolution to `wiki/log.md`.

Output: a lint report as a temporary markdown block in chat (not filed unless the user wants it).

---

## 10. Page Format Standards

### Overview page (`wiki/overview.md`)
```markdown
## Current Thesis
One paragraph: what you currently believe about this domain, based on everything ingested so far. Leave empty if you don't yet have a position.

## Thesis History
- YYYY-MM-DD — <one-line summary of prior position and what changed it>

## Open Questions
- Question 1 — why it matters
- Question 2

## Known Contradictions
- [Source A] vs [Source B] on claim X — open | investigating | resolved | accepted-tension

## Things That Changed My Mind
- Prior belief → revised belief — source that triggered the update

## Key Hubs
The 5–10 most-linked entities and concepts (updated after every lint run).
```

> Update `overview.md` after every ingest if the new source meaningfully shifts the synthesis. When the **Current Thesis** changes, move the old version into **Thesis History** with the trigger. This file is the single most important artifact in the wiki — if your thesis has never changed, you're filing, not thinking.

---

### Source page (`wiki/sources/<slug>.md`)
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
- ...

## Notable Quotes
> "Direct quote from source."

## Related Pages
- [[Related Entity]]
- [[Related Concept]]

## Sources
- `raw/<original-filename>`
```

### Entity page (`wiki/entities/<slug>.md`)
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
- [[Source Page 2]] — context of appearance

## Related
- [[Related Entity or Concept]]

## Relations
- contradicts: [[Page]] — one-line explanation
- supports: [[Page]] — one-line explanation
```

### Concept page (`wiki/concepts/<slug>.md`)
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
- Property or variant 2

## Appears In
- [[Source Page]] — how it was used
- [[Entity Page]] — relationship

## See Also
- [[Related Concept]]

## Relations
- contradicts: [[Page]] — one-line explanation
- supports: [[Page]] — one-line explanation
```

---

## 11. Obsidian Configuration

**Vault root**: `<your-vault-path>` — the directory where you cloned/created this project (open it as an Obsidian vault)

### Settings to configure
| Setting | Location | Value |
|---|---|---|
| Attachment folder | Settings → Files and links | `raw/assets` |
| New note location | Settings → Files and links | `wiki/` |
| Default file format | Settings → Editor | Markdown |

### Hotkey to bind
- Search for "Download attachments for current file" in Settings → Hotkeys
- Bind to `Ctrl+Shift+D` (or your preference)
- Use after Web Clipping an article to download all images to `raw/assets/`

### Community plugins to install
| Plugin | Purpose | Priority |
|---|---|---|
| **Dataview** | Run queries over frontmatter; generate dynamic tables (e.g., pages by type, by tag, recently updated) | High |
| **Marp** | Render slide decks from wiki content | Medium |
| **Obsidian Git** | Auto-commit wiki changes to git | Medium |

### Core features to use
- **Graph View**: best way to see the shape of your wiki — hubs, orphans, clusters. Open it after every few ingests.
- **Backlinks panel**: open on any wiki page to see what references it
- **Canvas**: optional — useful for spatial arrangement of concepts during research phases

### Browser extension
- Install **Obsidian Web Clipper** — converts web articles to markdown, saves directly to `raw/`
- Workflow: clip article → Obsidian opens the file → hit `Ctrl+Shift+D` to download images → tell Claude to ingest it

---

## 12. Bootstrap Sequence

Follow these steps to go from empty directory to running first ingest.

### Step 1 — Generate starter CLAUDE.md
```
Tell Claude Code: "Generate a starter CLAUDE.md for this wiki. The domain is: <describe your topic>"
```
Claude will draft `CLAUDE.md` from the schema design in Section 6. Review and refine it together. CLAUDE.md is the schema that governs everything — it must exist before the directory structure is created.

### Step 2 — Create directory structure
```
Tell Claude Code: "Bootstrap the wiki directory structure per BRIEF.md"
```
Claude will create: `raw/assets/`, `wiki/entities/`, `wiki/concepts/`, `wiki/sources/`, `wiki/index.md`, `wiki/log.md`, `wiki/overview.md`

### Step 2.5 — Seed overview.md's Current Thesis
Claude will ask: *What do you want to believe by the end of this research?* Your answer — however rough — becomes the opening entry in `overview.md`'s `## Current Thesis` section. This seeds the intellectual direction the wiki will build toward. Leave it empty if you don't have a position yet; you can fill it in later. It is expected to change.

### Step 3 — Open as Obsidian vault
- File → Open Vault → select `/Users/xhocht/Temp/obsidian-karpathy`
- Install Dataview plugin (Settings → Community plugins → Browse)
- Configure attachment folder (Section 11)
- Bind the download hotkey

### Step 4 — Install Web Clipper
- Install Obsidian Web Clipper from the Chrome/Firefox extension store
- Configure it to save to `raw/` in your vault

### Step 5 — First ingest
- Drop a source file into `raw/` (clip an article, copy a note, etc.)
- Tell Claude Code: `"Please ingest raw/<filename>"`
- Watch Obsidian update in real time as Claude writes pages
- Open Graph View after — you should see your first cluster

### Step 6 — Refine schema
- After the first ingest, review what Claude produced
- If page format, naming, or emphasis feels off, update `CLAUDE.md` together
- Add `## Schema History` to CLAUDE.md with the initial entry: `[YYYY-MM-DD] — Initial schema | Trigger: first ingest`
- This co-evolution of the schema is expected and healthy; the Schema Maintenance rules in Section 6 define when to update it going forward

### Step 7 — Establish rhythm
- Ingest → Query → Ingest → Ingest → Query → Lint (every ~5 sources)
- After ~10 sources: graph view becomes interesting
- After ~20 sources: query speed advantage over re-reading becomes obvious

---

## 13. Tooling Reference

| Tool | Purpose | Required? | Notes |
|---|---|---|---|
| **Claude Code** | LLM agent that writes and maintains the wiki | Yes | Sonnet 4.6 for most work; Opus 4.6 for complex synthesis |
| **Obsidian** | Wiki reader, graph view, browsing | Yes | Free; vault = this directory |
| **Obsidian Web Clipper** | Clip web articles to `raw/` as markdown | Recommended | Browser extension |
| **Dataview** | Query frontmatter; dynamic tables in Obsidian | Recommended | Community plugin |
| **Marp** | Render markdown as slide decks | Optional | Community plugin |
| **Obsidian Git** | Auto-commit wiki to git | Optional | Community plugin; free version history |
| **git** | Version history, branching, collaboration | Recommended | Run `git init` in vault root |
| **qmd** | Local hybrid BM25/vector search | Optional | Add at ~300 sources; at ~100, switch to section-targeted index reads (see Section 7) |

---

## 14. Success Criteria — Functional & Qualitative

The implementation is working when:

**Functional**
- [ ] Answering a question from the wiki is faster than re-reading raw sources
- [ ] Obsidian graph view shows non-trivial link structure after 10 sources (no isolated nodes)
- [ ] Contradictions are flagged proactively during ingest — not discovered by accident later
- [ ] A new source integrates in one Claude Code session, touching 10–15 files
- [ ] Log is grep-parseable: `grep "^## \[" wiki/log.md | tail -10` returns the last 10 operations
- [ ] `wiki/index.md` is complete — every wiki page has an entry with a one-line summary
- [ ] Frontmatter is consistent — Dataview can query all pages by `type` and `tags` without errors
- [ ] The CLAUDE.md schema has been refined at least once after real usage, with a `## Schema History` entry

**Qualitative**
- [ ] **Quality bar**: After 20 sources, pick a non-trivial synthesis question. Answer it from the wiki. Then answer it by cold-reading the raw sources. The wiki answer should be faster, better-cited, and reveal connections the cold-read misses. If not, the wiki is a filing cabinet, not a knowledge base — revisit the ingest Discuss step and `overview.md` structure.
- [ ] `overview.md`'s `## Current Thesis` has been revised at least once, with a corresponding `## Thesis History` entry — if your position has never been revised, you're filing, not thinking.

---

## Appendix: Key Decisions & Rationale

**Why markdown + Obsidian over a database?**  
Zero infrastructure. Git for free. LLMs read markdown natively. The wiki is just files — portable, inspectable, and forkable.

**Why index.md over embedding-based RAG?**  
At small to medium scale (~100 sources, ~hundreds of pages), a well-maintained index.md plus direct file reads is sufficient and adds no infrastructure. Add qmd when you feel the need for better search.

**Why wikilinks resolved at write-time?**  
Obsidian renders broken `[[links]]` as red. Resolving at write-time (by checking index.md before writing) keeps the graph clean and prevents link rot accumulating silently.

**Why append-only log.md?**  
The log gives temporal context — what was ingested when, what questions were asked, when lint was last run. This helps Claude understand recency without scanning all pages. It's also just useful for you.

**Why co-evolve CLAUDE.md?**  
No schema is right on day one. Your domain, your style, and your use patterns will reveal what conventions work. The schema is a living document. Treat it as the most important file in the project.
