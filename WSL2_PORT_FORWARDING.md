# WSL2 Port Forwarding Setup

## Problem
When running the backend in WSL2 and the Flutter app on an Android emulator in Windows, you may encounter timeout errors because the emulator cannot reach the WSL2 backend.

The Android emulator uses `10.0.2.2` to access Windows' localhost, but the backend is running in WSL2, not on Windows' localhost.

## Solution: Set Up Port Forwarding

You need to forward Windows port 4000 to WSL2 port 4000.

### Option 1: Using PowerShell Script (Recommended)

1. Copy `setup-wsl-port-forward.ps1` to your Windows machine (or access it via `\\wsl.localhost\Ubuntu\home\epi_linux\homedx-platform\`)

2. Open PowerShell **as Administrator** on Windows

3. Run the script:
   ```powershell
   .\setup-wsl-port-forward.ps1
   ```

The script will automatically detect your WSL2 IP and set up port forwarding.

### Option 2: Manual Setup

1. Get your WSL2 IP address:
   ```bash
   # In WSL2
   hostname -I | awk '{print $1}'
   ```

2. Open PowerShell **as Administrator** on Windows

3. Run this command (replace `172.26.71.195` with your WSL2 IP):
   ```powershell
   netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=172.26.71.195
   ```

4. Verify the port forwarding:
   ```powershell
   netsh interface portproxy show all
   ```

### Option 3: Using the Helper Script

From WSL2, run:
```bash
./setup-wsl-port-forward.sh
```

This will output the exact command you need to run in Windows PowerShell.

## Important Notes

- **You must run PowerShell as Administrator** for port forwarding to work
- If you restart WSL2, the IP address may change. You'll need to run the setup again
- To remove port forwarding, run:
  ```powershell
  netsh interface portproxy delete v4tov4 listenport=4000 listenaddress=127.0.0.1
  ```

## Verify Backend is Running

In WSL2, check if the backend is running:
```bash
curl http://localhost:4000/gg-homedx-json/gg-api/v1/get-be-status-flags -X POST -H "Content-Type: application/json" -d '{}'
```

You should see: `{"success":true,"cwa":true,"cwaLaive":true}`

## Verify Port Forwarding Works

From Windows PowerShell (not as admin is fine for testing):
```powershell
Test-NetConnection -ComputerName localhost -Port 4000
```

Or from Windows Command Prompt:
```cmd
curl http://localhost:4000/gg-homedx-json/gg-api/v1/get-be-status-flags -X POST -H "Content-Type: application/json" -d "{}"
```

## Troubleshooting

1. **Backend not accessible from Windows**: Make sure the backend is listening on `0.0.0.0` (check `backend/src/main.ts` - it should have `app.listen(4000, '0.0.0.0')`)

2. **Port forwarding not working**: 
   - Make sure you ran PowerShell as Administrator
   - Check if Windows Firewall is blocking the connection
   - Verify the WSL2 IP hasn't changed (restart WSL2 may change the IP)

3. **Still getting timeouts**:
   - Verify port forwarding: `netsh interface portproxy show all`
   - Test from Windows: `curl http://localhost:4000/...`
   - Check Flutter app's `.env` file has `API_BASE_URL=http://10.0.2.2:4000`

