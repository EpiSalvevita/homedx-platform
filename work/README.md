# Work — non-code project space

Anything **project-related that is not application code** lives here: market work, meetings, roadmap, partnerships, brand, finance notes, and misc project thinking. Engineering setup and API docs stay in [`docs/`](../docs/); source code stays in `backend/` and `frontend/`.

## Map

| Area | Path | Use for |
|------|------|---------|
| Product brief | [`product-brief.md`](product-brief.md) | Shared “what homeDX is” for any non-code work |
| Strategy / market | [`strategy/`](strategy/) | Market, competitors, analyses, sources |
| Meetings | [`meetings/`](meetings/) | Agendas, notes, decisions |
| Roadmap | [`roadmap/`](roadmap/) | Priorities, milestones, non-code planning — including [`roadmap/certification-roadmap.md`](roadmap/certification-roadmap.md) |
| Partnerships | [`partnerships/`](partnerships/) | Vendors, channels, Cube/OEM relationships |
| Brand | [`brand/`](brand/) | Messaging, naming, positioning copy drafts |
| Finance | [`finance/`](finance/) | Pricing notes, unit economics sketches (not secrets in git if sensitive) |
| Notes | [`notes/`](notes/) | Catch-all when nothing else fits |

## What does *not* belong here

- How to run the stack, API, WSL2 → [`docs/`](../docs/)
- Regulatory / QMS engineering guardrails → [`docs/regulatory/`](../docs/regulatory/) and [`.cursor/rules/mdr-compliance.mdc`](../.cursor/rules/mdr-compliance.mdc)
- App / backend code → `backend/`, `frontend/mobile/hdx_mobile/`

## How to use with Cursor

1. Open or create files under `work/` for the topic you care about.
2. Ask the agent to update those files (durable notes) rather than chat-only answers.
3. Ground product claims in [`product-brief.md`](product-brief.md). Flag medical-claims risk; do not invent clinical or CE claims.
4. Use templates where present (`_template.md`); otherwise a short dated markdown file is enough.

## Naming

- Meetings: `meetings/YYYY-MM-DD-topic.md`
- Analyses: `strategy/analyses/YYYY-MM-DD-short-title.md`
- Competitors: `strategy/competitors/<slug>.md` + update the index
- Misc: `notes/YYYY-MM-DD-topic.md` or a clear slug
