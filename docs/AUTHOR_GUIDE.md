# Documentation Authoring Guide

Use this guide when adding or updating ARS Markdown files.

## Where Docs Go

- Project docs belong in `docs/`.
- Keep `README.md` at the repository root as the public entry point.
- Keep tool-specific root files only when the tool expects them there, such as `CLAUDE.md`.

## Naming

- Use descriptive names: `PAYMENT_INTEGRATION.md`, `SHOP_IMPLEMENTATION.md`, `MECHANIC_FLOW.md`.
- Avoid `copy`, `final`, `new`, `updated`, or timestamp suffixes.
- If a guide replaces an older one, update the existing file or add a short archive note in the old file.

## Structure

Prefer this shape for implementation docs:

```markdown
# Feature Name

## Status

## Overview

## User Flow

## Technical Notes

## Files Changed

## Testing

## Next Steps
```

Short quick references can use fewer sections, but they should still answer: what this is, where the code lives, how to use it, and how to verify it.

## Links

- Link to docs with relative paths: `[Architecture](./ARCHITECTURE.md)`.
- Link to root files with `../`: `[Project README](../README.md)`.
- Do not use `file://` links or machine-specific absolute paths.
- After moving a file, update links in `README.md`, `docs/README.md`, and related docs.

## Quality Checklist

- The title explains the topic without needing the filename.
- The first section says whether the feature is implemented, planned, or report-only.
- Commands are fenced with a language tag such as `bash`.
- Code paths are wrapped in backticks.
- The doc has no copied chat prompts, assistant filler, or local editor traces.
- Related docs are linked from `docs/README.md`.
