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

## 5. Share with colleagues

| Link | Purpose |
|------|---------|
| `http://NAS_IP:8080/` | App entry / login |
| `http://NAS_IP:8080/#/about` | Marketing page |
| `http://NAS_IP:8080/downloads/hdx-mobile.apk` | Install Android app |

**Phones:** install APK (allow unknown sources) or use Chrome on the web URL.

**Cube Bluetooth tests:** Android APK only; web shows a placeholder.

## 6. Demo logins

See `docs/APPOINTMENTS_VIDEO.md` for doctor accounts after seed (e.g. `anna.weber@homedx.local`).

## 7. Stop / update

```bash
docker compose down
# Rebuild artifacts, then:
docker compose up -d --build
```

## Troubleshooting

- **Web loads but login fails:** API not reachable — check `http://NAS_IP:4000` from phone browser (should not 404 on API path). Rebuild web/APK with correct `HOMEDX_NAS_IP`.
- **Blank page:** ensure `web/` contains `index.html` from `build-artifacts.sh`.
- **Video calls:** set `DAILY_API_KEY` and `DAILY_DOMAIN` in `.env`.
- **Backend crash loop (`CORS_ORIGINS is required`):** set `CORS_ORIGINS=http://YOUR_NAS_IP:8080` in `.env` (required when `NODE_ENV=production`).
- **Port 4000 already in use:** set `BACKEND_PORT=4002` (or another free port) in `.env`, update `APP_URL`, and rebuild the Flutter web artifact with matching `API_BASE_URL`.
- **Backend entrypoint permission denied on some NAS hosts:** keep `deploy/nas/docker-compose.override.yml` in place (Compose merges it automatically) until the backend image is rebuilt with the fixed Dockerfile.

## Security note

This is a **LAN preview** setup (HTTP, no TLS). Do not expose ports 4000/8080 to the public internet without HTTPS and hardening.
