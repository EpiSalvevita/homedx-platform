# HomeDX NAS deployment (Ugreen / Docker)

Deploy the **web app**, **backend API**, **PostgreSQL**, and an **Android APK download** on your LAN so colleagues can review the product.

## What runs where

| Piece | NAS role | Colleague access |
|-------|----------|------------------|
| **nginx** (`:8080`) | Serves Flutter web + APK file | Browser: `http://NAS_IP:8080` |
| **backend** (`:4000`) | NestJS API | Used by web/APK (not opened directly) |
| **postgres** | Database | Internal only |
| **APK file** | Static download | `http://NAS_IP:8080/downloads/hdx-mobile.apk` |

Web and mobile are **separate artifacts** from the same Flutter project; the NAS hosts static files and the API, not a “running mobile app.”

## Prerequisites

- Ugreen NAS with **Docker** (Compose)
- Your dev machine: Flutter SDK, Node (for local builds)
- Colleagues on the **same Wi‑Fi/LAN** as the NAS

## 1. Clone on the NAS (or copy `deploy/nas`)

```bash
git clone https://github.com/EpiSalvevita/homedx-platform.git
cd homedx-platform/deploy/nas
cp .env.example .env
# Edit .env: POSTGRES_PASSWORD, JWT_SECRET, CORS_ORIGINS, APP_URL=http://YOUR_NAS_IP:4000
# For signup/reset emails: SMTP_HOST, SMTP_USER, SMTP_PASS, SMTP_FROM, WEB_APP_URL
```

## 2. Build web + APK (on dev machine)

Set your NAS LAN IP (find it in the NAS network settings):

```bash
cd homedx-platform/deploy/nas
chmod +x build-artifacts.sh
HOMEDX_NAS_IP=192.168.1.50 ./build-artifacts.sh
```

This fills `deploy/nas/web/` and `deploy/nas/downloads/hdx-mobile.apk`.

The script temporarily sets `frontend/mobile/hdx_mobile/.env` to the NAS API URL for the
build, then **restores** your previous local `.env` (or removes the temp file if none existed).
Safe to run in the same tree you use for WSL/web/phone day-to-day.

Copy the whole `deploy/nas` folder to the NAS (SCP, SMB share, or git pull on NAS after push).

`API_BASE_URL` is **baked into** the web/APK build — rebuild if the NAS IP changes.

## 3. Start the stack on the NAS

On the NAS (SSH or Ugreen Docker UI → Compose):

```bash
cd deploy/nas
chmod +x deploy.sh build-artifacts.sh
./deploy.sh
```

Uses `docker compose` or `docker-compose` automatically.

Or manually:

```bash
docker compose up -d --build
# or: docker-compose up -d --build
```

First boot runs Prisma migrations and seeds demo doctors.

Check logs:

```bash
docker compose logs -f backend
```

## 4. Ugreen Docker UI (GUI)

1. Docker → **Compose** → **Create**
2. Upload or paste `docker-compose.yml` from `deploy/nas`
3. Set env file from `.env`
4. Map ports **8080** (web) and **4000** (API) if the UI asks
5. Ensure `web/`, `downloads/`, and `nginx.conf` paths are mounted as in the compose file

## 5. Readable URL (e.g. `http://homedx.de:8080`)

The web app is served on port **8080** (Ugreen’s own UI already owns ports 80/443).

FritzBox does **not** have a “add DNS A-record” form under *Erweiterte Netzwerkeinstellungen* (that page is static routes, guest IPv4, etc.). It only publishes **`name.fritz.box`** for devices in the home network.

Use the name that already exists: **http://salvenas.fritz.box:8080/**

To pick a shorter name (`homedx.fritz.box`):

1. Open **http://fritz.box**
2. **Heimnetz → Netzwerk** (the device list, not *Erweiterte Netzwerkeinstellungen*)
3. Click **salveNAS** → **Bearbeiten** (pencil)
4. Set **Name** to `homedx` → apply
5. Open **http://homedx.fritz.box:8080/**

A real `http://homedx.de` URL is a public DNS record at the domain registrar, not a FritzBox setting. Do not point the public domain at this NAS unless you intend to put the preview on the internet (needs HTTPS).

Nginx reverse-proxies `/gg-homedx-json/` to the API, so the web build uses **same-origin** and does not bake in the NAS IP.

## 6. Share with colleagues

| Link | Purpose |
|------|---------|
| `http://salvenas.fritz.box:8080/` | App (LAN hostname, works today) |
| `http://homedx.fritz.box:8080/` | App (after renaming the NAS in Heimnetz → Netzwerk) |
| `http://NAS_IP:8080/` | App (raw IP still works) |
| `http://NAS_IP:8080/#/about` | Marketing page |
| `http://NAS_IP:8080/downloads/hdx-mobile.apk` | Install Android app |

**Phones:** install APK (allow unknown sources) or use Chrome on the web URL.

**Cube Bluetooth tests:** Android APK only; web shows a placeholder.

## 7. Demo logins

See `docs/APPOINTMENTS_VIDEO.md` for doctor accounts after seed (e.g. `anna.weber@homedx.local`).

## 8. Stop / update

```bash
docker compose down
# Rebuild artifacts, then:
docker compose up -d --build
```

## Troubleshooting

- **Web loads but login fails:** API not reachable — check `http://NAS_IP:8080/gg-homedx-json/gg-api/v1/get-be-status-flags` (nginx proxies this). If you still call the API on :4002 from a browser, that origin must be in `CORS_ORIGINS`.
- **`salvenas.fritz.box` does not open:** use **http://** (not https). That name exists only if the device uses the FritzBox as DNS (`192.168.178.1`). Public DNS (8.8.8.8, 1.1.1.1) returns NXDOMAIN. Fallback on LAN: `http://192.168.178.88:8080/`. If the IP works but the name hangs, the browser is likely trying IPv6 first.
- **Blank page:** ensure `web/` contains `index.html` from `build-artifacts.sh`.
- **No emails after signup / password reset:** set SMTP in `deploy/nas/.env` (`SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`) and `WEB_APP_URL` to the public web origin (e.g. `http://homedx.de:8080`). Recreate the backend so Compose reloads the env file (`docker compose up -d --force-recreate backend` — a plain `restart` keeps the old password). Check `docker compose logs backend` for `SMTP is not configured` or `535 Authentication credentials invalid`. Use port **587** with STARTTLS (`SMTP_SECURE=false`); residential ISPs often block port 25. After changing mailer/UI code, rebuild web (`build-artifacts.sh`) so `/verify-email` exists for the confirmation link.
- **Video calls:** set `DAILY_API_KEY` and `DAILY_DOMAIN` in `.env`.
- **Backend crash loop (`CORS_ORIGINS is required`):** set `CORS_ORIGINS=http://YOUR_NAS_IP:8080` in `.env` (required when `NODE_ENV=production`).
- **Port 4000 already in use:** set `BACKEND_PORT=4002` (or another free port) in `.env`, update `APP_URL`, and rebuild the Flutter web artifact with matching `API_BASE_URL`.
- **Backend entrypoint permission denied on some NAS hosts:** keep `deploy/nas/docker-compose.override.yml` in place (Compose merges it automatically) until the backend image is rebuilt with the fixed Dockerfile.

## Security note

This is a **LAN preview** setup (HTTP, no TLS). Do not expose ports 4000/8080 to the public internet without HTTPS and hardening.
