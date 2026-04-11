# Project Guidelines

## Scope
- This workspace uses a single global instruction file: `.github/copilot-instructions.md`.
- Do not create `AGENTS.md` in parallel unless explicitly requested.

## Architecture
- Main ArkTS code lives under `entry/src/main/ets`.
- Layering rule: `pages -> services -> repository -> storage/persistence -> api`.
- `pages` is presentation only. Do not call `api`, `repository`, `storage`, or `persistence` directly from pages.
- `services` owns business orchestration and cross-layer coordination.
- `repository` handles data access/state transfer only; no UI prompts and no business orchestration.
- `api` is request infrastructure and raw request calls only, and must not depend on `repository/services/pages/storage`.

See module responsibilities in:
- `entry/src/main/ets/README.md`
- `entry/src/main/ets/pages/README.md`
- `entry/src/main/ets/services/README.md`
- `entry/src/main/ets/repository/README.md`
- `entry/src/main/ets/api/README.md`
- `entry/src/main/ets/router/README.md`

## Build and Validation
- Install dependencies (if needed): `ohpm install` (workspace root).
- Build app (Hvigor): `hvigor build` (workspace root).
- Layer guard check: `bash structure_guard_check.sh` from `entry/src/main/ets`.
- Behavior smoke check: `bash structure_smoke_check.sh` from `entry/src/main/ets`.

Before finishing non-trivial changes, run at least:
1. `bash structure_guard_check.sh`
2. `bash structure_smoke_check.sh`

## Conventions
- API result handling: request layer returns `ApiResult`; handle failures through `result.ok` in upper layers.
- Do not reintroduce broad try/catch in page layer for ordinary network failures if the flow already uses `ApiResult`.
- Keep typed normalization for training domain (`TrainingType`, `TrainItemStatus`, `PracticeMode`); avoid raw string spread.
- Keep route parsing concentrated in route adapter/matcher responsibilities; avoid ad hoc route parsing in business services.
- For training flow, avoid expanding runtime state with page-only display fields.

## Documentation Sync (Mandatory)
- If a change affects directory responsibilities, boundaries, routing, cache ownership, request failure semantics, or guard scripts, update related README files in the same change.
- Also update restructure records when applicable:
  - `entry/src/main/ets/docs/restructure/*.md`
- Historical AI handoff and self-check traces are archived under:
  - `entry/src/main/ets/docs/history/ai-traces/`
- Prefer linking existing docs in responses and new docs; do not duplicate long content across files.

## High-Value Entry Points
- App bootstrap and lifecycle: `entry/src/main/ets/entryability/EntryAbility.ets`
- Top-level architecture contract: `entry/src/main/ets/README.md`
- Guard scripts:
  - `entry/src/main/ets/structure_guard_check.sh`
  - `entry/src/main/ets/structure_smoke_check.sh`

## Common Pitfalls
- Page layer directly calling repository or API.
- Repository layer drifting into business orchestration.
- API layer taking reverse dependencies on upper layers.
- Route parsing and stage normalization leaking into unrelated modules.
- Code changes without synchronized README/handoff updates.