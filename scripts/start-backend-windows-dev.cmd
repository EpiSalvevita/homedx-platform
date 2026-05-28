@echo off
REM Nest on Windows: phone uses http://<PC-LAN-IP>:4000 (no WSL portproxy hop).
REM Stop WSL backend first:  ./stop.sh   from WSL in repo root.
REM Requires: Windows Node/npm, Docker Postgres on localhost:5432 (same DB as backend\.env).

pushd "%~dp0..\backend" || exit /b 1

set "DATABASE_URL=postgresql://devuser:devpassword@localhost:5432/devdb?schema=public"
set "JWT_SECRET=your-secret-key-development"

if not exist "node_modules" (
  echo Installing npm dependencies on Windows...
  call npm install --legacy-peer-deps
)

echo Starting Nest on Windows — http://0.0.0.0:4000  (Ctrl+C to stop)
call npm run start:dev

popd
