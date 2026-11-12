# Market Watch dashboard data

Data behind the homeDX Market Watch dashboard (a private claude.ai page; ask the
strategy owner for access). These files are a structured copy of the profiles,
market overview and analyses in `work/strategy/`. Those markdown files remain the
source of truth, and every value here must trace back to them and their sources.

| File | One row per | Key |
|------|-------------|-----|
| `competitors.json` | tracked competitor | `slug` |
| `market.json` | published market figure | `slice` |
| `watchlist.json` | regulatory date, action or open question | `id` |

## Fields

**competitors.json**: `slug`, `name`, `segment`, `category`, `overlap`,
`threat_now`, `threat_24m` (one of Low, Low–Medium, Medium, Medium–High, High),
`last_checked` (last *full* check, YYYY-MM-DD), `partial_check` (last
changes-only re-check, or ""), `recheck_note` (what that re-check covered),
`latest` (latest sourced change, one sentence), `watch`, `website`, `profile`.

**market.json**: `slice`, `usd_bn` (number), `year`, `role` (TAM proxy, SAM
proxy or Context only), `why`, `source`, `url`, `accessed`, `paywalled`
(yes/no), `rechecked` (date or ""), `recheck_note`.

**watchlist.json**: `id`, `item`, `date` (YYYY-MM-DD or ""), `kind`
(Regulatory date, Action or Open question), `priority` (High, Medium, Low),
`owner`, `note`.

## Rules

- Keep the field names. The dashboard reads them.
- No number without a source in `work/strategy/sources/`. Market sizes stay
  as published figures; never derive a homeDX TAM/SAM/SOM.
- `last_checked` moves only on a full check. A changes-only pass sets
  `partial_check` and `recheck_note`.
- Regulatory dates are industry context, not homeDX status.
- No finance details, credentials or personal data: everyone who can open the
  dashboard can read these files in full.
- After these files change on `main`, the dashboard is updated by uploading
  them to it (Claude does this on request).
