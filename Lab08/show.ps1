<#
.SYNOPSIS
  Gather common system properties and display them in a readable report.

.DESCRIPTION
  Collects OS, CPU, memory, disk, network, BIOS, uptime and a few other items.
  Use -AsHtml to write an HTML report to the current folder (SystemInfo_Report.html).

.EXAMPLE
  .\Show-SystemInfo.ps1
  .\Show-SystemInfo.ps1 -AsHtml
#>

param(
    [switch] $AsHtml
)

# Helper: friendly size
function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1TB) { "{0:N2} TB" -f ($Bytes / 1TB) }
    elseif ($Bytes -ge 1GB) { "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { "{0:N2} KB" -f ($Bytes / 1KB) }
    else { "$Bytes B" }
}

# Collect info
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cs = Get-CimInstance -ClassName Win32_ComputerSystem
$cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
$bios = Get-CimInstance -ClassName Win32_BIOS
$memModules = Get-CimInstance -ClassName Win32_PhysicalMemory
$logicalDisks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
$netAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
$lastBoot = $os.LastBootUpTime
$uptime = (Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime($lastBoot))

# Build summary object
$summary = [pscustomobject]@{
    "ComputerName"       = $env:COMPUTERNAME
    "Domain"             = $cs.Domain
    "Manufacturer"       = $cs.Manufacturer
    "Model"              = $cs.Model
    "OS"                 = "$($os.Caption) (Build $($os.BuildNumber))"
    "OSVersion"          = $os.Version
    "InstallDate"        = ([Management.ManagementDateTimeConverter]::ToDateTime($os.InstallDate)).ToString('u')
    "LastBootUpTime"     = ([Management.ManagementDateTimeConverter]::ToDateTime($lastBoot)).ToString('u')
    "Uptime"             = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    "CPU"                = "$($cpu.Name) (Cores: $($cpu.NumberOfCores), Logical: $($cpu.NumberOfLogicalProcessors))"
    "TotalPhysicalMemory"= (Format-Size $cs.TotalPhysicalMemory)
    "BIOS"               = "$($bios.Manufacturer) $($bios.SMBIOSBIOSVersion) ($($bios.ReleaseDate -as [string]))"
    "Timestamp"          = (Get-Date).ToString('u')
}

# Memory modules details
$mem = $memModules | Select-Object @{n='Bank';e={$_.BankLabel}}, @{n='Capacity';e={Format-Size $_.Capacity}}, @{n='SpeedMHz';e={$_.Speed}}, Manufacturer

# Disks
$disks = $logicalDisks | Select-Object DeviceID, @{n='Size';e={Format-Size $_.Size}}, @{n='FreeSpace';e={Format-Size $_.FreeSpace}}, FileSystem, @{n='PercentFree';e={[math]::Round(($_.FreeSpace / $_.Size * 100),2)}}

# Network (IP, MAC, DNS)
$net = $netAdapters | Select-Object Description, MACAddress, IPAddress, DefaultIPGateway, DNSServerSearchOrder

# Top processes by memory
$topProcs = Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 10 -Property Id, ProcessName, @{n='WorkingSet';e={Format-Size $_.WS}}

# Services (optional sample)
$topServices = Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 10 Name, DisplayName, Status

# Construct report object
$report = [pscustomobject]@{
    Summary      = $summary
    MemoryModules= $mem
    Disks        = $disks
    Network      = $net
    TopProcesses = $topProcs
    RunningServices = $topServices
}

# Output to console nicely
Write-Host "==== System Information Report ====" -ForegroundColor Cyan
$summary | Format-List
Write-Host "`n--- Memory Modules ---"
$mem | Format-Table -AutoSize
Write-Host "`n--- Disks ---"
$disks | Format-Table -AutoSize
Write-Host "`n--- Network Adapters (IP-enabled) ---"
$net | Format-Table -AutoSize
Write-Host "`n--- Top Processes (by memory) ---"
$topProcs | Format-Table -AutoSize
Write-Host "`n--- Running Services (sample) ---"
$topServices | Format-Table -AutoSize

# Optionally write HTML report
if ($AsHtml) {
    $outFile = Join-Path -Path (Get-Location) -ChildPath "SystemInfo_Report.html"
    $html = @()
    $html += "<html><head><meta charset='utf-8'><title>System Info Report - $($summary.ComputerName)</title></head><body>"
    $html += "<h1>System Info Report - $($summary.ComputerName)</h1>"
    $html += "<h2>Summary</h2>"
    $html += "<pre>$((($summary | Out-String)))</pre>"
    $html += "<h2>Memory Modules</h2>"
    $html += $mem | ConvertTo-Html -Fragment
    $html += "<h2>Disks</h2>"
    $html += $disks | ConvertTo-Html -Fragment
    $html += "<h2>Network Adapters</h2>"
    $html += $net | ConvertTo-Html -Fragment
    $html += "<h2>Top Processes</h2>"
    $html += $topProcs | ConvertTo-Html -Fragment
    $html += "</body></html>"
    $html -join "`n" | Out-File -FilePath $outFile -Encoding UTF8
    Write-Host "`nHTML report written to: $outFile" -ForegroundColor Green
}
