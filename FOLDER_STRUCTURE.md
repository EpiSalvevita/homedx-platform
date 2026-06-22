# homeDX Platform - Folder Structure

This file is a short pointer. The canonical copy lives in **[docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md)**.

## Overview

- `backend/` – NestJS REST API (PostgreSQL + Prisma)
- `frontend/mobile/hdx_mobile/` – Flutter app (mobile, web, desktop targets)
- `Cube APP V0.1.21/` – Cube Android SDK reference package
- `docs/` – Setup and feature documentation
- `deploy.sh`, `stop.sh` – Start/stop local dev services

## API surface

All client traffic uses **REST** under:

`/gg-homedx-json/gg-api/v1/*`

Payment provider webhooks: `POST /webhooks/stripe`, `POST /webhooks/paypal`.

There is **no GraphQL** endpoint in this repo.

## Legacy / reference (do not use for active development)

- `mobile/` – Old React Native tree (deprecated)
- `flutter/` – Local Flutter SDK checkout (not an app project)
