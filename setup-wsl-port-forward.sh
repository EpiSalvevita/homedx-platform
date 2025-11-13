#!/bin/bash
# Helper script to set up WSL2 port forwarding from Linux
# This will output the PowerShell command you need to run on Windows

WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL2 IP: $WSL_IP"
echo ""
echo "Run this command in Windows PowerShell (as Administrator):"
echo ""
echo "netsh interface portproxy add v4tov4 listenport=4000 listenaddress=127.0.0.1 connectport=4000 connectaddress=$WSL_IP"
echo ""
echo "Or run the PowerShell script: setup-wsl-port-forward.ps1"
