$ProjectPath = "D:\freellmapi\freellmapi-main"

# Start server (backend)
$serverProc = Start-Process -FilePath "npx.cmd" -ArgumentList "tsx", "$ProjectPath\server\src\index.ts" -WorkingDirectory $ProjectPath -PassThru -NoNewWindow

# Wait for server to bind port
Start-Sleep -Seconds 3

# Start client (frontend)
$clientProc = Start-Process -FilePath "npx.cmd" -ArgumentList "vite", "--host", "127.0.0.1" -WorkingDirectory "$ProjectPath\client" -PassThru -NoNewWindow

Write-Host "Server PID: $($serverProc.Id) - http://127.0.0.1:3001" -ForegroundColor Green
Write-Host "Client PID: $($clientProc.Id) - http://127.0.0.1:5173" -ForegroundColor Green

# Keep script alive so processes stay running
while ($true) { Start-Sleep -Seconds 60 }
