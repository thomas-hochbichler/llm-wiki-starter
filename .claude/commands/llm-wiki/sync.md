Offline sync: detect any sources added to `raw/` since the last session and batch-ingest them.

## Step 1 — List files in `raw/`

List every file under `raw/` recursively, **excluding** anything inside `raw/assets/`. Normalize to filenames (basenames or paths relative to `raw/`, whichever is consistently used in `log.md`).

## Step 2 — Parse `wiki/log.md`

Read `wiki/log.md` and extract every line matching `## [YYYY-MM-DD] ingest | <Source Title>`. The source title should correspond to a file in `raw/` — if the log stores titles rather than filenames, cross-reference with the `sources:` frontmatter field of pages in `wiki/sources/` to map titles back to raw filenames.

Build the set of already-ingested raw filenames.

## Step 3 — Diff

Compute `new_files = files_in_raw − already_ingested`.

Handle edge cases:
- **Non-text / scanned-PDF files** with no extractable text: exclude from `new_files` and list separately as "skipped — no text layer"
- **`raw/` empty or fully up to date:** report *"raw/ is up to date — nothing to ingest."* and stop

## Step 4 — Confirm with the user

Present the diff:

```
Found N new files in raw/:
1. <file-1>
2. <file-2>
...

Skipped (no text layer): <list or "none">

Ingest all N files? (yes / no / select-subset)
```

Wait for confirmation. If the user picks a subset, use only those.

## Step 5 — Sequential batch ingest

For each file in the confirmed list, run the full FR-2 ingest workflow (see `.claude/commands/llm-wiki/ingest.md`). The Discuss step (FR-2 step 2) applies per-source **unless** the user said "skip discuss" or "batch-ingest these" — in a `/llm-wiki:sync` context those phrases skip Discuss for the entire batch.

Between sources, give a brief progress line: *"[3/5] Ingesting <title>..."*.

## Step 6 — Final summary

After all files are processed, report:

```
Sync complete.
- N sources ingested
- M wiki pages created
- K wiki pages updated
- P entities added / Q concepts added
- overview.md: <touched | untouched>
- Skipped: <list or "none">
```

## Step 7 — Session-end validation

Same as FR-2 step 9, but applied to the whole batch:
- [ ] Every page touched during the batch appears in `wiki/index.md`
- [ ] Every page written has all six required frontmatter fields
- [ ] `wiki/log.md` has an `ingest |` entry for every newly ingested source with today's date

Fix any gaps before reporting done.
