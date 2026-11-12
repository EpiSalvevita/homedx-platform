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
| `telemed_players.json` | telemedicine / home-test player (DE/EU) | `slug` |
| `telemed_market.json` | published telemedicine / digital-health figure | `slice` |

## Fields

**Language:** the dashboard is in German. Field names stay English; text
values are written in German (company names and quoted claims stay as published).

**competitors.json**: `slug`, `name`, `segment`, `category`, `overlap`
(Niedrig, Mittel, Mittel–Hoch, Hoch), `threat_now`, `threat_24m` (one of
Niedrig, Niedrig–Mittel, Mittel, Mittel–Hoch, Hoch),
`last_checked` (last *full* check, YYYY-MM-DD), `partial_check` (last
changes-only re-check, or ""), `recheck_note` (what that re-check covered),
`latest` (latest sourced change, one sentence), `watch`, `website`, `profile`.

**market.json**: `slice`, `usd_bn` (number), `year`, `role` (TAM-Näherung,
SAM-Näherung or Nur Kontext), `why`, `source`, `url`, `accessed`, `paywalled`
(ja/nein), `rechecked` (date or ""), `recheck_note`.

**watchlist.json**: `id`, `item`, `date` (YYYY-MM-DD or ""), `kind`
(Regulatorische Frist, Aufgabe or Offene Frage), `priority` (Hoch, Mittel,
Niedrig), `owner`, `note`.

**telemed_players.json**: `slug`, `name`, `country`, `region` (DACH, Europa
= Europe outside DACH, Global = outside Europe; by headquarters or by the
service checked when the HQ is not on the page), `model` (e.g.
Heimtest + Arztzugang, Videosprechstunde, Online-Rezept), `home_test` and
`doctor_access` (ja, nein, unklar), `payer` (Selbstzahler, GKV, PKV, gemischt,
unklar), `overlap` (Niedrig, Mittel, Hoch), `note` (one sourced sentence),
`url`, `accessed`.

**telemed_market.json**: `slice`, `value` (number), `unit` (Mrd. EUR or
Mrd. USD), `year`, `geography`, `role` (Kontext), `why`, `source`, `url`,
`accessed`, `paywalled` (ja/nein).

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
