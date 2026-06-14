param(
    [string]$ProjectPath = "D:\freellmapi\freellmapi-main"
)

$TaskName = "FreeLLMAPI"

# Remove existing task if present
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false 2>$null

$NodeCmd = "npx"
$Argument = "-c `"$ProjectPath\node_modules\.bin\tsx.cmd $ProjectPath\server\src\index.ts`""
$LogPath = Join-Path $ProjectPath "server\data\freellmapi.log"

$Action = New-ScheduledTaskAction -Execute $NodeCmd -Argument $Argument -WorkingDirectory $ProjectPath

$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 0)

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -User $env:USERNAME -RunLevel Limited -Description "FreeLLMAPI server - auto-start on Windows login" | Out-Null

Write-Host "Registered scheduled task: $TaskName" -ForegroundColor Green
Write-Host ""
Write-Host "Start:      Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
Write-Host "Stop:       Stop-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
Write-Host "View log:   Get-Content '$LogPath' -Tail 20 -Wait" -ForegroundColor Yellow
Write-Host "Remove:     Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor Yellow
