Answer the question: $ARGUMENTS

Use the wiki as the primary source. Do not perform a web search unless the question explicitly asks for current/external information.

## Step 1 — Map relevant pages

Read `wiki/index.md`. Identify every page whose title or summary is relevant to the question.

## Step 2 — Read relevant pages

Read each identified page. If a page references other pages that seem relevant, read those too. Drill as deep as needed to answer the question well.

## Step 3 — Synthesize

Write a clear, direct answer to the question. Every factual claim should be cited with an inline `[[wikilink]]` to the wiki page it came from. If the wiki doesn't contain enough information to answer confidently, say so explicitly rather than inferring or guessing.

## Step 4 — File by default

After answering, write the result as a wiki page — a `query` page if it's a focused answer, a `synthesis` page if it draws connections across multiple sources. Use this template:

```markdown
---
type: query | synthesis
title: <Question or Synthesis Title>
tags: [tag1, tag2]
sources: [source-slug.md, ...]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

<the answer, with [[wikilink]] citations>
```

File it to `wiki/` (for synthesis pages) or appropriate subdirectory. Skip filing ONLY if the user says "don't file this" or the answer is trivial/ephemeral.

## Step 5 — Update `wiki/index.md`

Add the new page under a `## Queries` or `## Syntheses` section (create the section if it doesn't exist). Format: `- [[Page Title]] — one-line summary of the question/synthesis`.

## Step 6 — Append to `wiki/log.md`

```markdown
## [YYYY-MM-DD] query | <Question Summary>
```

Use today's date. Keep the question summary to one line.
