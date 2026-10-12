# CLAUDE.md — homeDX platform

Guidance for Claude Code working in this repo. Keep it accurate; update it when commands or paths change.

## What this is

homeDX is a **software accessory** to the Cube rapid-test reader. The phone connects to Cube over Bluetooth, Cube's SDK evaluates the test on-device, and the app sends the result to the backend, stores it, and displays it. The app **does not perform the diagnostic measurement**. A positive result leads to a specialist booking and a video consult (Daily.co). The product is in scope for EU IVDR/MDR and German MPDG. Regulatory status is an open question for a qualified person, not something to decide in code.

## Layout

- `backend/` — NestJS 11 + Prisma + PostgreSQL, port 4000. REST API under `/gg-homedx-json/gg-api/v1`, **every endpoint is POST**. Controllers: `src/controllers/mobile-*.controller.ts`. Feature modules: `src/modules/`. Schema: `prisma/schema.prisma`.
- `frontend/mobile/hdx_mobile/` — Flutter app (Android, iOS, web). Provider, **GoRouter only** (no `Navigator.push`). HTTP goes through `lib/core/api_service.dart`. Cube integration: `lib/features/cube/`.
- `deploy/nas/` — LAN preview deploy (Docker, nginx). See `docs/NAS_DEPLOY.md`.
- `docs/` — setup and component docs. `docs/regulatory/` — MDR/IVDR material.
- `work/` — non-code project work (strategy, roadmap, brand). See the work rules below.
- `vendor/` — Cube reference material (gitignored). `flutter/` — local Flutter SDK checkout, **do not edit**.

## Commands

Backend (`cd backend`):
- `npm run start:dev` (its `prestart:dev` hook kills anything on ports 4000 and 4010)
- `npm run build`, `npm run lint`, `npm run test:e2e`
- `npx prisma migrate deploy`, `npx prisma migrate status`
- `npm run seed:doctors` (only when `HOMEDX_SEED_DOCTORS=true`)

Flutter (`cd frontend/mobile/hdx_mobile`, SDK at `/home/epi_linux/homedx-platform/flutter/bin` on this machine):
- `flutter analyze`, `flutter test`
- `flutter gen-l10n` (runs automatically on build)
- `flutter build web --release`, then `./serve-web.sh 8080`

Root: `./deploy.sh [all|backend|mobile|web|connectivity]`, `./stop.sh`.

## Local development gotchas

- **Use `127.0.0.1`, not `localhost`**, for the web app and the API (IPv6 mismatch on WSL2).
- The Postgres container is named `hdx_postgres` on this machine. `deploy.sh` expects `hdx-postgres`. Check with `docker ps -a`.
- A stale local database makes login fail with the generic "Anmeldung fehlgeschlagen". Run `npx prisma migrate status` before debugging auth.
- Mobile API errors are sanitized. The real cause is in the backend log.
- Changes to `.env` need a full Flutter rebuild (hot reload does not pick them up).
- After mobile UI changes: rebuild web, restart `serve-web.sh 8080`, then hard refresh (Ctrl+Shift+R).
- On WSL2, "Failed to fetch" or timeouts are usually environment issues (stale `netsh` portproxy, wrong `API_BASE_URL`). Run `./deploy.sh connectivity` before changing Nest or Prisma code.
- Not in git: Cube config `.bin` files, `google-services.json`, `.env` files. Secrets and seeded passwords are documented in `docs/ENV_SETUP.md`, not here.

## Conventions

- Navigation: GoRouter only.
- Payments are server-authoritative. The server sets the amount and only the server marks a payment `COMPLETED`.
- Styling: use `AppTheme` tokens (`lib/config/app_theme.dart`), not raw `Colors.*`, except for semantic status colors.
- **Localization:** add every key to **both** `lib/l10n/app_de.arb` (template) and `app_en.arb`. Access with `context.l10n.<key>`. Commit the regenerated `app_localizations*.dart`. Do not translate Cube SDK messages, questionnaire content or legal pages without the review in `docs/regulatory/`.
- Use the existing helpers and patterns before writing new ones (`ApiService`, `FigmaUi`, `AdaptiveScreen`).

## Regulatory guardrails

Full rule: `.cursor/rules/mdr-compliance.mdc`. Read it before touching in-scope code. The condensed version:

- **In-scope paths:** `backend/src/**`, `backend/prisma/schema.prisma`, `frontend/mobile/hdx_mobile/lib/**`, `docs/regulatory/**`. This covers result interpretation and display, Cube data handling, certificates, health data, auth, and the wording and colors shown to users.
- **Definition of done for an in-scope change:** a short **Regulatory note** covering (1) whether it is regulatory-relevant, (2) failure modes in ISO 14971 terms (wrong or dropped result, wrong certificate), (3) test evidence that exists or is missing, and (4) whether human or PRRC sign-off is needed before merge. A one-line "not relevant" is fine for typos, logs or unrelated copy. Urgent or terse instructions do not waive this.
- **Result logic:** never change thresholds, rounding, unit conversion or status mapping inside a cleanup. Fail closed: a missing Cube `class` means INCONCLUSIVE.
- **Wording on result and certificate screens** counts as in scope (IEC 62366-1 use-error risk).
- **PHI:** never log full result payloads, patient identifiers or certificate contents. Use synthetic data in fixtures and prompts.
- **Vigilance:** if a bug already affected a result or certificate a user saw, say so and escalate. Do not patch it quietly.
- **Classification:** do not assume MDR vs IVDR vs DiGA, and do not claim CE status. Flag questions to a human.
- Record regulated-surface changes in `CHANGELOG.md` with a risk note and test evidence.

For a second opinion on an in-scope change, invoke the `regulatory-reviewer` subagent (`.claude/agents/regulatory-reviewer.md`).

## Work folder

`work/` is non-code project work. Follow `.cursor/rules/homedx-work.mdc`: cite sources in `work/strategy/sources/`, don't invent market sizes, CE marks or clinical performance (mark them TBD), don't commit secrets or finance details, and don't refactor `backend/` or `frontend/` during `work/` tasks.

## Git and CI

- Default branch: `main`. Work on a feature branch; don't commit straight to `main`.
- CI (`.github/workflows/ci.yml`) runs on pushes and PRs to `main`: backend build, `npm audit --audit-level=critical`, `prisma migrate deploy`, `test:e2e`; a gitleaks scan and a check that `backend/uploads/` is not in history; Flutter `analyze`, `test`, `build web`. `npm run lint` is **not** a CI gate.
- Pre-commit hook: install with `scripts/install-git-hooks.sh`. It blocks `backend/uploads/` and runs gitleaks.
- `CHANGELOG.md` has an `## Unreleased` section at the top. Backend and mobile are versioned independently (`backend/package.json`, `frontend/mobile/hdx_mobile/pubspec.yaml`).

## Docs map

- `docs/README.md` — index of setup and component docs.
- `docs/MOBILE_APP.md`, `docs/ENV_SETUP.md`, `docs/NAS_DEPLOY.md`, `docs/APP_FUNCTIONALITIES.md` (shipped features and gaps).
- `docs/regulatory/` — gap assessment, classification draft (not yet signed off), SOUP list.
- `frontend/mobile/hdx_mobile/PAYMENT_INTEGRATION.md` — the complete list of payment env vars.
- Ignore the one-off troubleshooting notes in `frontend/mobile/hdx_mobile/` (`SUCCESS.md`, `IMMEDIATE_SOLUTION.md`, `START_EMULATOR.md`, `*DEVTOOLS*.md` and similar). They are personal and out of date.
