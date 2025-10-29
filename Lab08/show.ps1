# Show-SimpleSys-Win7.ps1
# Compact demo compatible with PowerShell 2.0 / Windows 7

$computer = $env:COMPUTERNAME
$user     = $env:USERNAME
$os       = (Get-WmiObject Win32_OperatingSystem).Caption
$ver      = (Get-WmiObject Win32_OperatingSystem).Version
$uptime   = (Get-Date) - (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)
$cpu      = (Get-WmiObject Win32_Processor).Name
$memGB    = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)

Write-Host "=== System Info (Win7 Compatible) ===" -ForegroundColor Cyan
Write-Host "Computer : $computer"
Write-Host "User     : $user"
Write-Host "OS       : $os"
Write-Host "Version  : $ver"
Write-Host "CPU      : $cpu"
Write-Host "Memory   : $memGB GB"
Write-Host "Uptime   : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
Write-Host "======================================"
