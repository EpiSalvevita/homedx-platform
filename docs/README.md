---
description: Documentation index for homeDX platform
---

# Docs Index

## Development setup

- `WSL2_MOBILE_SETUP.md` – WSL2 + Flutter mobile development setup
- `WSL2_PORT_FORWARDING.md` – WSL2 port forwarding, `API_BASE_URL`, connectivity checks
- `ENV_SETUP.md` – Environment variables (backend + Flutter)

## Component docs

- `MOBILE_APP.md` – Flutter app setup, Cube flow, web builds
- `APP_FUNCTIONALITIES.md` – Feature matrix, gaps, and prioritized backlog
- `FOLDER_STRUCTURE.md` – Project layout and API entry points
- `APPOINTMENTS_VIDEO.md` – Doctor appointments and Daily.co video calls
- `NAS_DEPLOY.md` – LAN preview deploy (Docker on NAS)

## Frontend

- `../frontend/README.md` – Frontend apps index
- `../frontend/mobile/hdx_mobile/PAYMENT_INTEGRATION.md` – Stripe / PayPal REST flow

## API note

Clients talk to the NestJS backend over **REST only**:

- Mobile API: `POST /gg-homedx-json/gg-api/v1/<endpoint>`
- Auth: `Authorization: Bearer <jwt>` or `x-auth-token` header
- Public routes (login, register, status flags): no token required

There is no `/graphql` endpoint in this repository.
