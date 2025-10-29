# Show-SimpleSys.ps1
# Small, non-elevated system info demo

# Basic info (no admin required)
$computerName = $env:COMPUTERNAME
$userName     = $env:USERNAME
$osName       = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -First 1 -ExpandProperty Caption) -replace '\s+',' '
$osVersion    = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -First 1 -ExpandProperty Version
) 
$dotNet       = [System.Environment]::Version.ToString()
$uptime       = (Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime((Get-CimInstance Win32_OperatingSystem).LastBootUpTime))

# Counts & small stats
$processCount = (Get-Process).Count
$logicalDrives = (Get-PSDrive -PSProvider FileSystem).Name -join ', '

# Print a compact, readable summary
Write-Host "=== Simple System Info ===" -ForegroundColor Cyan
Write-Host "Computer : $computerName"
Write-Host "User     : $userName"
Write-Host "OS       : $osName"
Write-Host "OS Ver   : $osVersion"
Write-Host ".NET Ver : $dotNet"
Write-Host "Uptime   : $($uptime.Days) days, $($uptime.Hours) hrs, $($uptime.Minutes) mins"
Write-Host "Processes: $processCount"
Write-Host "Drives   : $logicalDrives"
Write-Host "=========================="
