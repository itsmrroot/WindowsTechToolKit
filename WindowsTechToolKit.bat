@echo off
setlocal EnableExtensions
title Windows Technician Toolkit PRO
mode con: cols=90 lines=40

:: ============================================================
::  WINDOWS TECHNICIAN TOOLKIT PRO
::  Auto-elevates, colored menus, reports, repair and network tools
:: ============================================================

:: ---- Auto-elevate to Administrator ----
net session >nul 2>&1 || (
    echo Requesting administrator rights...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ---- Colors ----
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C=%ESC%[96m"
set "Y=%ESC%[93m"
set "G=%ESC%[92m"
set "R=%ESC%[91m"
set "W=%ESC%[97m"
set "D=%ESC%[90m"
set "N=%ESC%[0m"

:: ---- Reports folder and log ----
set "RPT=%USERPROFILE%\TechToolkit_Reports"
if not exist "%RPT%" md "%RPT%"
set "LOG=%RPT%\toolkit_log.txt"
call :log "Toolkit started"

:: ============================================================
:main
call :header "MAIN MENU"
echo  %Y%[1]%N%  Admin Consoles        %D%CMD, PowerShell, Registry, Services...%N%
echo  %Y%[2]%N%  System Info ^& Reports %D%Summary, battery, drivers, errors%N%
echo  %Y%[3]%N%  Repair ^& Maintenance  %D%SFC, DISM, CHKDSK, Windows Update fix%N%
echo  %Y%[4]%N%  Network Tools         %D%Diagnose, DNS, IP, Wi-Fi, reset%N%
echo  %Y%[5]%N%  Cleanup               %D%Temp files, Disk Cleanup, component store%N%
echo  %Y%[6]%N%  Power ^& Boot          %D%BIOS, Advanced Startup, Safe Mode%N%
echo  %Y%[7]%N%  Open Reports Folder
echo.
echo  %R%[0]%N%  Exit
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="1" goto consoles
if "%opt%"=="2" goto sysinfo
if "%opt%"=="3" goto repair
if "%opt%"=="4" goto network
if "%opt%"=="5" goto cleanup
if "%opt%"=="6" goto power
if "%opt%"=="7" start "" explorer "%RPT%" & goto main
if "%opt%"=="0" goto quit
call :invalid
goto main

:: ============================================================
:consoles
call :header "ADMIN CONSOLES"
echo  %Y%[1]%N%  CMD                   %Y%[11]%N% Windows Security
echo  %Y%[2]%N%  PowerShell            %Y%[12]%N% Device Manager
echo  %Y%[3]%N%  Registry Editor       %Y%[13]%N% Disk Management
echo  %Y%[4]%N%  Services              %Y%[14]%N% Task Manager
echo  %Y%[5]%N%  Event Viewer          %Y%[15]%N% Task Scheduler
echo  %Y%[6]%N%  Local Users           %Y%[16]%N% System Configuration
echo  %Y%[7]%N%  Group Policy          %Y%[17]%N% Control Panel
echo  %Y%[8]%N%  Computer Management   %Y%[18]%N% Programs and Features
echo  %Y%[9]%N%  System Restore        %Y%[19]%N% Windows Firewall
echo  %Y%[10]%N% Recovery Settings     %Y%[20]%N% Resource Monitor
echo.
echo  %R%[0]%N%  Back
echo.
set "opt=" & set "RUN="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" set "RUN=cmd.exe /k cd /d %USERPROFILE%"
if "%opt%"=="2" goto launchPS
if "%opt%"=="3" set "RUN=regedit.exe"
if "%opt%"=="4" set "RUN=services.msc"
if "%opt%"=="5" set "RUN=eventvwr.msc"
if "%opt%"=="6" goto launchUsers
if "%opt%"=="7" goto launchGP
if "%opt%"=="8" set "RUN=compmgmt.msc"
if "%opt%"=="9" set "RUN=rstrui.exe"
if "%opt%"=="10" set "RUN=ms-settings:recovery"
if "%opt%"=="11" set "RUN=windowsdefender:"
if "%opt%"=="12" set "RUN=devmgmt.msc"
if "%opt%"=="13" set "RUN=diskmgmt.msc"
if "%opt%"=="14" set "RUN=taskmgr.exe"
if "%opt%"=="15" set "RUN=taskschd.msc"
if "%opt%"=="16" set "RUN=msconfig.exe"
if "%opt%"=="17" set "RUN=control.exe"
if "%opt%"=="18" set "RUN=appwiz.cpl"
if "%opt%"=="19" set "RUN=wf.msc"
if "%opt%"=="20" set "RUN=resmon.exe"
if not defined RUN call :invalid & goto consoles
start "" %RUN%
call :log "Launched %RUN%"
echo %G% Launched.%N%
timeout /t 1 >nul
goto consoles

:launchPS
where pwsh >nul 2>&1 && (start "" pwsh.exe) || (start "" powershell.exe)
call :log "Launched PowerShell"
goto consoles

:launchUsers
if exist "%windir%\System32\lusrmgr.msc" (start "" lusrmgr.msc) else (
    echo %Y% Local Users console is not available on Windows Home. Opening User Accounts instead.%N%
    start "" netplwiz.exe
    timeout /t 3 >nul
)
goto consoles

:launchGP
if exist "%windir%\System32\gpedit.msc" (start "" gpedit.msc) else (
    echo %Y% Group Policy Editor is not available on Windows Home editions.%N%
    pause
)
goto consoles

:: ============================================================
:sysinfo
call :header "SYSTEM INFO & REPORTS"
echo  %Y%[1]%N%  Quick system summary
echo  %Y%[2]%N%  Full system report          %D%saved to file%N%
echo  %Y%[3]%N%  Battery health report       %D%laptops%N%
echo  %Y%[4]%N%  Installed software list     %D%saved to file%N%
echo  %Y%[5]%N%  Driver list                 %D%saved to file%N%
echo  %Y%[6]%N%  Disk health status
echo  %Y%[7]%N%  Recent critical errors      %D%last 24 hours%N%
echo  %Y%[8]%N%  Windows activation status
echo.
echo  %R%[0]%N%  Back
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto infoQuick
if "%opt%"=="2" goto infoFull
if "%opt%"=="3" goto infoBattery
if "%opt%"=="4" goto infoApps
if "%opt%"=="5" goto infoDrivers
if "%opt%"=="6" goto infoDisk
if "%opt%"=="7" goto infoErrors
if "%opt%"=="8" goto infoLicense
call :invalid
goto sysinfo

:infoQuick
call :header "QUICK SYSTEM SUMMARY"
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; $c=Get-CimInstance Win32_Processor | Select-Object -First 1; $cs=Get-CimInstance Win32_ComputerSystem; $b=Get-CimInstance Win32_BIOS; $up=(Get-Date)-$o.LastBootUpTime; Write-Host (' OS        : '+$o.Caption+' (build '+$o.BuildNumber+')'); Write-Host (' Model     : '+$cs.Manufacturer+' '+$cs.Model); Write-Host (' Serial    : '+$b.SerialNumber); Write-Host (' CPU       : '+$c.Name.Trim()); Write-Host (' RAM       : {0:N1} GB total, {1:N1} GB free' -f ($cs.TotalPhysicalMemory/1GB), ($o.FreePhysicalMemory*1KB/1GB)); Write-Host (' Uptime    : {0}d {1}h {2}m' -f $up.Days,$up.Hours,$up.Minutes); Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host (' Drive {0}  : {1:N1} GB free of {2:N1} GB' -f $_.DeviceID, ($_.FreeSpace/1GB), ($_.Size/1GB)) }; Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host (' GPU       : '+$_.Name) }"
echo.
pause
goto sysinfo

:infoFull
call :stamp
set "F=%RPT%\SystemReport_%STAMP%.txt"
echo %C% Building report, please wait...%N%
(
  echo ===== SYSTEMINFO =====
  systeminfo
  echo.
  echo ===== DISKS =====
  powershell -NoProfile -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,@{n='SizeGB';e={[math]::Round($_.Size/1GB)}} -AutoSize | Out-String -Width 200"
  echo ===== NETWORK =====
  ipconfig /all
) > "%F%" 2>&1
call :log "Saved %F%"
start "" notepad "%F%"
goto sysinfo

:infoBattery
call :stamp
set "F=%RPT%\BatteryReport_%STAMP%.html"
powercfg /batteryreport /output "%F%" >nul 2>&1 && (start "" "%F%") || (echo %Y% No battery found on this device.%N% & pause)
goto sysinfo

:infoApps
call :stamp
set "F=%RPT%\InstalledApps_%STAMP%.txt"
echo %C% Collecting installed software...%N%
powershell -NoProfile -Command "$p='HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'; Get-ItemProperty $p -ErrorAction SilentlyContinue | Where-Object DisplayName | Sort-Object DisplayName -Unique | Format-Table DisplayName,DisplayVersion,Publisher,InstallDate -AutoSize | Out-String -Width 250 | Set-Content -Path '%F%'"
call :log "Saved %F%"
start "" notepad "%F%"
goto sysinfo

:infoDrivers
call :stamp
set "F=%RPT%\Drivers_%STAMP%.csv"
driverquery /v /fo csv > "%F%"
call :log "Saved %F%"
echo %G% Saved: %F%%N%
pause
goto sysinfo

:infoDisk
call :header "DISK HEALTH"
powershell -NoProfile -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,BusType,HealthStatus,OperationalStatus,@{n='SizeGB';e={[math]::Round($_.Size/1GB)}} -AutoSize"
pause
goto sysinfo

:infoErrors
call :header "CRITICAL AND ERROR EVENTS - LAST 24 HOURS"
powershell -NoProfile -Command "try { Get-WinEvent -FilterHashtable @{LogName='System','Application';Level=1,2;StartTime=(Get-Date).AddDays(-1)} -MaxEvents 30 -ErrorAction Stop | Format-Table TimeCreated,ProviderName,Id,@{n='Message';e={($_.Message -split [Environment]::NewLine)[0]}} -AutoSize -Wrap } catch { Write-Host ' No critical errors found in the last 24 hours.' -ForegroundColor Green }"
pause
goto sysinfo

:infoLicense
call :header "ACTIVATION STATUS"
cscript //nologo "%windir%\System32\slmgr.vbs" /dli
pause
goto sysinfo

:: ============================================================
:repair
call :header "REPAIR & MAINTENANCE"
echo  %Y%[1]%N%  System File Checker         %D%sfc /scannow%N%
echo  %Y%[2]%N%  DISM image repair           %D%RestoreHealth%N%
echo  %Y%[3]%N%  Full repair                 %D%DISM then SFC - recommended%N%
echo  %Y%[4]%N%  Check disk - scan only      %D%safe, no reboot%N%
echo  %Y%[5]%N%  Check disk - fix on reboot
echo  %Y%[6]%N%  Create a restore point
echo  %Y%[7]%N%  Reset Windows Update components
echo  %Y%[8]%N%  Update all apps             %D%winget%N%
echo  %Y%[9]%N%  Restart Windows Explorer
echo  %Y%[10]%N% Memory diagnostic
echo  %Y%[11]%N% Open Windows Update
echo.
echo  %R%[0]%N%  Back
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto repSFC
if "%opt%"=="2" goto repDISM
if "%opt%"=="3" goto repFull
if "%opt%"=="4" goto repChkScan
if "%opt%"=="5" goto repChkFix
if "%opt%"=="6" goto repRestorePt
if "%opt%"=="7" goto repWU
if "%opt%"=="8" goto repWinget
if "%opt%"=="9" goto repExplorer
if "%opt%"=="10" start "" mdsched.exe & goto repair
if "%opt%"=="11" start "" ms-settings:windowsupdate & goto repair
call :invalid
goto repair

:repSFC
call :log "SFC started"
sfc /scannow
pause
goto repair

:repDISM
call :log "DISM started"
DISM /Online /Cleanup-Image /RestoreHealth
pause
goto repair

:repFull
call :log "Full repair started"
echo %C% Step 1 of 2: DISM...%N%
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo %C% Step 2 of 2: SFC...%N%
sfc /scannow
echo.
echo %G% Full repair finished. A restart is recommended.%N%
pause
goto repair

:repChkScan
chkdsk %SystemDrive% /scan
pause
goto repair

:repChkFix
call :confirm "CHKDSK will run on %SystemDrive% at next restart and may take a while." || goto repair
echo Y| chkdsk %SystemDrive% /f
call :log "CHKDSK scheduled"
pause
goto repair

:repRestorePt
echo %C% Creating restore point...%N%
powershell -NoProfile -Command "Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction SilentlyContinue; try { Checkpoint-Computer -Description 'TechToolkit manual restore point' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Host ' Restore point created.' -ForegroundColor Green } catch { Write-Host (' Could not create restore point: '+$_.Exception.Message) -ForegroundColor Yellow; Write-Host ' Note: Windows allows only one restore point every 24 hours by default.' }"
call :log "Restore point attempted"
pause
goto repair

:repWU
call :confirm "This stops update services and clears the Windows Update cache." || goto repair
call :log "Windows Update reset"
net stop wuauserv /y
net stop bits /y
net stop cryptsvc /y
if exist "%windir%\SoftwareDistribution.old" rd /s /q "%windir%\SoftwareDistribution.old"
ren "%windir%\SoftwareDistribution" SoftwareDistribution.old
if exist "%windir%\System32\catroot2.old" rd /s /q "%windir%\System32\catroot2.old"
ren "%windir%\System32\catroot2" catroot2.old
net start cryptsvc
net start bits
net start wuauserv
echo %G% Windows Update components reset. Restart, then check for updates.%N%
pause
goto repair

:repWinget
where winget >nul 2>&1 || (echo %Y% winget is not installed. Get App Installer from the Microsoft Store.%N% & pause & goto repair)
winget upgrade
echo.
call :confirm "Install all the updates listed above?" || goto repair
call :log "winget upgrade --all"
winget upgrade --all --accept-source-agreements --accept-package-agreements
pause
goto repair

:repExplorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %G% Explorer restarted.%N%
timeout /t 2 >nul
goto repair

:: ============================================================
:network
call :header "NETWORK TOOLS"
echo  %Y%[1]%N%  Quick connection diagnosis
echo  %Y%[2]%N%  Show IP configuration
echo  %Y%[3]%N%  Show public IP address
echo  %Y%[4]%N%  Flush DNS cache
echo  %Y%[5]%N%  Release and renew IP
echo  %Y%[6]%N%  Ping a host
echo  %Y%[7]%N%  Trace route to a host
echo  %Y%[8]%N%  Saved Wi-Fi networks
echo  %Y%[9]%N%  Active connections          %D%saved to file%N%
echo  %Y%[10]%N% Open Network Adapters
echo  %Y%[11]%N% Full network reset          %D%needs restart%N%
echo.
echo  %R%[0]%N%  Back
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto netDiag
if "%opt%"=="2" ipconfig /all | more & pause & goto network
if "%opt%"=="3" goto netPublic
if "%opt%"=="4" ipconfig /flushdns & pause & goto network
if "%opt%"=="5" goto netRenew
if "%opt%"=="6" goto netPing
if "%opt%"=="7" goto netTrace
if "%opt%"=="8" netsh wlan show profiles & pause & goto network
if "%opt%"=="9" goto netConns
if "%opt%"=="10" start "" ncpa.cpl & goto network
if "%opt%"=="11" goto netReset
call :invalid
goto network

:netDiag
call :header "CONNECTION DIAGNOSIS"
set "GW="
for /f "usebackq delims=" %%g in (`powershell -NoProfile -Command "(Get-NetRoute -DestinationPrefix 0.0.0.0/0 -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1).NextHop"`) do set "GW=%%g"
if defined GW (
    ping -n 2 %GW% >nul && (echo  %G%[ OK ]%N% Router reachable - %GW%) || (echo  %R%[FAIL]%N% Router not responding - %GW%)
) else (
    echo  %R%[FAIL]%N% No default gateway - check cable or Wi-Fi
)
ping -n 2 1.1.1.1 >nul && (echo  %G%[ OK ]%N% Internet reachable) || (echo  %R%[FAIL]%N% Internet not reachable)
nslookup www.microsoft.com >nul 2>&1 && (echo  %G%[ OK ]%N% DNS resolving names) || (echo  %R%[FAIL]%N% DNS not working - try Flush DNS or Network reset)
echo.
pause
goto network

:netPublic
powershell -NoProfile -Command "try { Write-Host (' Public IP: ' + (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 8)) -ForegroundColor Green } catch { Write-Host ' Could not reach the internet.' -ForegroundColor Red }"
pause
goto network

:netRenew
call :confirm "Your connection will drop for a few seconds." || goto network
ipconfig /release >nul
ipconfig /renew
pause
goto network

:netPing
set "HOST="
set /p "HOST= Host or IP to ping: "
if not defined HOST goto network
ping -n 6 %HOST%
pause
goto network

:netTrace
set "HOST="
set /p "HOST= Host or IP to trace: "
if not defined HOST goto network
tracert -d %HOST%
pause
goto network

:netConns
call :stamp
set "F=%RPT%\Connections_%STAMP%.txt"
netstat -abno > "%F%" 2>&1
start "" notepad "%F%"
goto network

:netReset
call :confirm "This resets Winsock and TCP/IP. VPN and custom network settings may need to be set up again." || goto network
call :log "Network reset"
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
echo.
echo %Y% Done. Please restart your computer to finish.%N%
pause
goto network

:: ============================================================
:cleanup
call :header "CLEANUP"
echo  %Y%[1]%N%  Clear my temp files
echo  %Y%[2]%N%  Clear Windows temp files
echo  %Y%[3]%N%  Empty Recycle Bin
echo  %Y%[4]%N%  Disk Cleanup
echo  %Y%[5]%N%  Component store cleanup     %D%DISM, frees update leftovers%N%
echo  %Y%[6]%N%  Storage Sense settings
echo.
echo  %R%[0]%N%  Back
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto clnUserTemp
if "%opt%"=="2" goto clnWinTemp
if "%opt%"=="3" goto clnBin
if "%opt%"=="4" start "" cleanmgr.exe & goto cleanup
if "%opt%"=="5" DISM /Online /Cleanup-Image /StartComponentCleanup & pause & goto cleanup
if "%opt%"=="6" start "" ms-settings:storagesense & goto cleanup
call :invalid
goto cleanup

:clnUserTemp
call :confirm "Delete temporary files in %TEMP%? Files in use will be skipped." || goto cleanup
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
call :log "User temp cleared"
echo %G% Done.%N%
pause
goto cleanup

:clnWinTemp
call :confirm "Delete files in %windir%\Temp? Files in use will be skipped." || goto cleanup
del /f /s /q "%windir%\Temp\*" >nul 2>&1
for /d %%d in ("%windir%\Temp\*") do rd /s /q "%%d" >nul 2>&1
call :log "Windows temp cleared"
echo %G% Done.%N%
pause
goto cleanup

:clnBin
call :confirm "Permanently delete everything in the Recycle Bin?" || goto cleanup
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
call :log "Recycle Bin emptied"
echo %G% Done.%N%
pause
goto cleanup

:: ============================================================
:power
call :header "POWER & BOOT"
echo  %Y%[1]%N%  Restart into BIOS / UEFI
echo  %Y%[2]%N%  Restart into Advanced Startup
echo  %Y%[3]%N%  Boot into Safe Mode next restart
echo  %Y%[4]%N%  Turn OFF Safe Mode boot
echo  %Y%[5]%N%  Startup apps
echo  %Y%[6]%N%  Power plans
echo  %Y%[7]%N%  Restart now
echo  %Y%[8]%N%  Shut down now
echo.
echo  %R%[0]%N%  Back
echo.
set "opt="
set /p "opt=%G% Select option: %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto pwBios
if "%opt%"=="2" goto pwAdv
if "%opt%"=="3" goto pwSafeOn
if "%opt%"=="4" goto pwSafeOff
if "%opt%"=="5" start "" ms-settings:startupapps & goto power
if "%opt%"=="6" powercfg /list & pause & goto power
if "%opt%"=="7" goto pwRestart
if "%opt%"=="8" goto pwShutdown
call :invalid
goto power

:pwBios
call :confirm "Save your work. The PC will restart into firmware settings." || goto power
shutdown /r /fw /t 5 || (echo %Y% This PC does not support restarting into firmware from Windows.%N% & pause)
goto power

:pwAdv
call :confirm "Save your work. The PC will restart into Advanced Startup." || goto power
shutdown /r /o /t 5
goto power

:pwSafeOn
call :confirm "The PC will boot into Safe Mode until you turn it off with option 4." || goto power
bcdedit /set {current} safeboot minimal
call :log "Safe Mode enabled"
echo %Y% Remember: run this toolkit in Safe Mode and choose option 4 to go back to normal.%N%
pause
goto power

:pwSafeOff
bcdedit /deletevalue {current} safeboot
call :log "Safe Mode disabled"
pause
goto power

:pwRestart
call :confirm "Restart the computer now?" || goto power
shutdown /r /t 5
goto power

:pwShutdown
call :confirm "Shut down the computer now?" || goto power
shutdown /s /t 5
goto power

:: ============================================================
::  HELPERS
:: ============================================================
:header
cls
echo %C%==================================================================%N%
echo %W%               WINDOWS TECHNICIAN TOOLKIT  PRO%N%
echo %C%==================================================================%N%
echo %D%  PC: %COMPUTERNAME%   User: %USERNAME%   %DATE% %TIME:~0,5%%N%
echo %Y%  ^>^> %~1%N%
echo.
exit /b

:confirm
echo.
echo %R% WARNING: %~1%N%
set "ans="
set /p "ans= Type YES to continue: "
if /i "%ans%"=="YES" exit /b 0
echo %D% Cancelled.%N%
timeout /t 2 >nul
exit /b 1

:invalid
echo %R% Invalid option, try again.%N%
timeout /t 1 >nul
exit /b

:stamp
for /f "usebackq delims=" %%t in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"`) do set "STAMP=%%t"
exit /b

:log
>>"%LOG%" echo [%DATE% %TIME:~0,8%] %~1
exit /b

:quit
call :log "Toolkit closed"
echo %G% Goodbye!%N%
timeout /t 1 >nul
endlocal
exit /b