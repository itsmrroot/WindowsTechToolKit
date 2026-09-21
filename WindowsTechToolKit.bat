@echo off
setlocal EnableExtensions
title Windows Technician Toolkit PRO
mode con: cols=100 lines=42

:: ============================================================
::  WINDOWS TECHNICIAN TOOLKIT PRO
::  Powered by BASHAR SALMO
::  Auto-elevates, colored menus, reports, repair and network tools
::  Supports English, Deutsch and Turkce menus.
::  Note: output from native Windows tools (systeminfo, ipconfig,
::  driverquery, etc.) is always shown in whatever language Windows
::  itself produces it in - only the toolkit's own menus/messages
::  are translated.
:: ============================================================

:: ---- Colors ----
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C=%ESC%[96m"
set "Y=%ESC%[93m"
set "G=%ESC%[92m"
set "R=%ESC%[91m"
set "W=%ESC%[97m"
set "D=%ESC%[90m"
set "N=%ESC%[0m"

:: ---- Language selection (skipped if passed in as an argument, used when re-launching elevated) ----
set "LANG=%~1"
if /i "%LANG%"=="EN" goto langready
if /i "%LANG%"=="DE" goto langready
if /i "%LANG%"=="TR" goto langready
call :SelectLanguage
:langready
call :Lang_%LANG%

:: ---- Ensure we're hosted inside Windows Terminal (needed for the live monitor split-pane) ----
:: This is gated on WT_SESSION, NOT on admin status: on some machines "net session"
:: already succeeds on a fresh launch (no elevation prompt needed), which would
:: otherwise skip this relaunch entirely and leave the monitor stuck opening as a
:: separate plain PowerShell window instead of a split pane.
if not defined WT_SESSION (
    where wt >nul 2>&1
    if not errorlevel 1 (
        net session >nul 2>&1
        if not errorlevel 1 (
            start "" wt.exe cmd /c "%~f0" %LANG%
        ) else (
            echo %T_REQADMIN%
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$q=[char]34; try { Start-Process -FilePath 'wt.exe' -ArgumentList 'cmd','/c',($q+'%~f0'+$q),'%LANG%' -Verb RunAs -ErrorAction Stop; exit 0 } catch { $_.Exception.Message | Out-File -FilePath (Join-Path $env:TEMP 'ttk_wt_relaunch_error.log') -Append; exit 1 }"
            if errorlevel 1 (
                powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '%LANG%' -Verb RunAs"
            )
        )
        exit /b
    )
)

:: ---- Auto-elevate to Administrator if still needed (e.g. wt.exe unavailable) ----
net session >nul 2>&1 || (
    echo %T_REQADMIN%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '%LANG%' -Verb RunAs"
    exit /b
)

:: ---- Reports folder and log ----
set "RPT=%USERPROFILE%\TechToolkit_Reports"
if not exist "%RPT%" md "%RPT%"
set "LOG=%RPT%\toolkit_log.txt"
call :log "Toolkit started (lang=%LANG%)"

:: ---- Version and update source ----
set "TOOLKIT_VERSION=1.1.0"
set "GITHUB_REPO=itsmrroot/WindowsTechToolKit"
set "GITHUB_FILE=WindowsTechToolKit.bat"

:: ============================================================
:main
set "MONPID="
if exist "%TEMP%\ttk_monitor.pid" for /f "usebackq delims=" %%p in ("%TEMP%\ttk_monitor.pid") do set "MONPID=%%p"
set "MONALIVE=0"
if defined MONPID (
    tasklist /FI "PID eq %MONPID%" 2>nul | findstr /I "powershell" >nul
    if not errorlevel 1 set "MONALIVE=1"
)
if "%MONALIVE%"=="0" call :LaunchMonitor
call :header "%T_H_MAIN%"
echo  %Y%[1]%N%  %T_M1%        %D%%T_M1D%%N%
echo  %Y%[2]%N%  %T_M2% %D%%T_M2D%%N%
echo  %Y%[3]%N%  %T_M3%  %D%%T_M3D%%N%
echo  %Y%[4]%N%  %T_M4%         %D%%T_M4D%%N%
echo  %Y%[5]%N%  %T_M5%               %D%%T_M5D%%N%
echo  %Y%[6]%N%  %T_M6%          %D%%T_M6D%%N%
echo  %Y%[7]%N%  %T_M7%
echo  %Y%[8]%N%  %T_M8%    %D%v%TOOLKIT_VERSION%%N%
echo  %Y%[9]%N%  %T_M9%
echo.
echo  %R%[0]%N%  %T_EXIT%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
if "%opt%"=="1" call :Flash & goto consoles
if "%opt%"=="2" call :Flash & goto sysinfo
if "%opt%"=="3" call :Flash & goto repair
if "%opt%"=="4" call :Flash & goto network
if "%opt%"=="5" call :Flash & goto cleanup
if "%opt%"=="6" call :Flash & goto power
if "%opt%"=="7" start "" explorer "%RPT%" & goto main
if "%opt%"=="8" call :Flash & goto CheckUpdate
if "%opt%"=="9" call :Flash & goto bitlocker
if "%opt%"=="0" goto quit
call :invalid
goto main

:: ============================================================
:consoles
call :header "%T_H_CONSOLES%"
echo  %Y%[1]%N%  %T_C1%                   %Y%[11]%N% %T_C11%
echo  %Y%[2]%N%  %T_C2%            %Y%[12]%N% %T_C12%
echo  %Y%[3]%N%  %T_C3%       %Y%[13]%N% %T_C13%
echo  %Y%[4]%N%  %T_C4%              %Y%[14]%N% %T_C14%
echo  %Y%[5]%N%  %T_C5%          %Y%[15]%N% %T_C15%
echo  %Y%[6]%N%  %T_C6%           %Y%[16]%N% %T_C16%
echo  %Y%[7]%N%  %T_C7%             %Y%[17]%N% %T_C17%
echo  %Y%[8]%N%  %T_C8%   %Y%[18]%N% %T_C18%
echo  %Y%[9]%N%  %T_C9%        %Y%[19]%N% %T_C19%
echo  %Y%[10]%N% %T_C10%     %Y%[20]%N% %T_C20%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt=" & set "RUN="
set /p "opt=%G% %T_SELECT% %N%"
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
echo %G% %T_LAUNCHED%%N%
timeout /t 1 >nul
goto consoles

:launchPS
where pwsh >nul 2>&1 && (start "" pwsh.exe) || (start "" powershell.exe)
call :log "Launched PowerShell"
goto consoles

:launchUsers
if exist "%windir%\System32\lusrmgr.msc" (start "" lusrmgr.msc) else (
    echo %Y% %T_C_USERSWARN%%N%
    start "" netplwiz.exe
    timeout /t 3 >nul
)
goto consoles

:launchGP
if exist "%windir%\System32\gpedit.msc" (start "" gpedit.msc) else (
    echo %Y% %T_C_GPWARN%%N%
    pause
)
goto consoles

:: ============================================================
:sysinfo
call :header "%T_H_SYSINFO%"
echo  %Y%[1]%N%  %T_S1%
echo  %Y%[2]%N%  %T_S2%          %D%%T_S2D%%N%
echo  %Y%[3]%N%  %T_S3%       %D%%T_S3D%%N%
echo  %Y%[4]%N%  %T_S4%     %D%%T_S4D%%N%
echo  %Y%[5]%N%  %T_S5%                 %D%%T_S5D%%N%
echo  %Y%[6]%N%  %T_S6%
echo  %Y%[7]%N%  %T_S7%      %D%%T_S7D%%N%
echo  %Y%[8]%N%  %T_S8%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
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
call :header "%T_H_QUICK%"
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; $c=Get-CimInstance Win32_Processor | Select-Object -First 1; $cs=Get-CimInstance Win32_ComputerSystem; $b=Get-CimInstance Win32_BIOS; $up=(Get-Date)-$o.LastBootUpTime; Write-Host (' OS        : '+$o.Caption+' (build '+$o.BuildNumber+')'); Write-Host (' Model     : '+$cs.Manufacturer+' '+$cs.Model); Write-Host (' Serial    : '+$b.SerialNumber); Write-Host (' CPU       : '+$c.Name.Trim()); Write-Host (' RAM       : {0:N1} GB total, {1:N1} GB free' -f ($cs.TotalPhysicalMemory/1GB), ($o.FreePhysicalMemory*1KB/1GB)); Write-Host (' Uptime    : {0}d {1}h {2}m' -f $up.Days,$up.Hours,$up.Minutes); Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host (' Drive {0}  : {1:N1} GB free of {2:N1} GB' -f $_.DeviceID, ($_.FreeSpace/1GB), ($_.Size/1GB)) }; Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host (' GPU       : '+$_.Name) }"
echo.
pause
goto sysinfo

:infoFull
call :stamp
set "F=%RPT%\SystemReport_%STAMP%.txt"
call :Spin T_S_BUILDING
echo %C% %T_S_BUILDING%%N%
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
powercfg /batteryreport /output "%F%" >nul 2>&1 && (start "" "%F%") || (echo %Y% %T_S_NOBATTERY%%N% & pause)
goto sysinfo

:infoApps
call :stamp
set "F=%RPT%\InstalledApps_%STAMP%.txt"
call :Spin T_S_COLLECTING
echo %C% %T_S_COLLECTING%%N%
powershell -NoProfile -Command "$p='HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'; Get-ItemProperty $p -ErrorAction SilentlyContinue | Where-Object DisplayName | Sort-Object DisplayName -Unique | Format-Table DisplayName,DisplayVersion,Publisher,InstallDate -AutoSize | Out-String -Width 250 | Set-Content -Path '%F%'"
call :log "Saved %F%"
start "" notepad "%F%"
goto sysinfo

:infoDrivers
call :stamp
set "F=%RPT%\Drivers_%STAMP%.csv"
driverquery /v /fo csv > "%F%"
call :log "Saved %F%"
echo %G% %T_S_SAVED% %F%%N%
pause
goto sysinfo

:infoDisk
call :header "%T_H_DISK%"
powershell -NoProfile -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,BusType,HealthStatus,OperationalStatus,@{n='SizeGB';e={[math]::Round($_.Size/1GB)}} -AutoSize"
pause
goto sysinfo

:infoErrors
call :header "%T_H_ERRORS%"
powershell -NoProfile -Command "try { Get-WinEvent -FilterHashtable @{LogName='System','Application';Level=1,2;StartTime=(Get-Date).AddDays(-1)} -MaxEvents 30 -ErrorAction Stop | Format-Table TimeCreated,ProviderName,Id,@{n='Message';e={($_.Message -split [Environment]::NewLine)[0]}} -AutoSize -Wrap } catch { Write-Host ' No critical errors found in the last 24 hours.' -ForegroundColor Green }"
pause
goto sysinfo

:infoLicense
call :header "%T_H_LICENSE%"
cscript //nologo "%windir%\System32\slmgr.vbs" /dli
pause
goto sysinfo

:: ============================================================
:repair
call :header "%T_H_REPAIR%"
echo  %Y%[1]%N%  %T_R1%         %D%%T_R1D%%N%
echo  %Y%[2]%N%  %T_R2%           %D%%T_R2D%%N%
echo  %Y%[3]%N%  %T_R3%                 %D%%T_R3D%%N%
echo  %Y%[4]%N%  %T_R4%      %D%%T_R4D%%N%
echo  %Y%[5]%N%  %T_R5%
echo  %Y%[6]%N%  %T_R6%
echo  %Y%[7]%N%  %T_R7%
echo  %Y%[8]%N%  %T_R8%             %D%%T_R8D%%N%
echo  %Y%[9]%N%  %T_R9%
echo  %Y%[10]%N% %T_R10%
echo  %Y%[11]%N% %T_R11%
echo  %Y%[12]%N% %T_R12%         %D%%T_R12D%%N%
echo  %Y%[13]%N% %T_R13%      %D%%T_R13D%%N%
echo  %Y%[14]%N% %T_R14%           %D%%T_R14D%%N%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
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
if "%opt%"=="10" goto repMemDiag
if "%opt%"=="11" start "" ms-settings:windowsupdate & goto repair
if "%opt%"=="12" goto repDriverExport
if "%opt%"=="13" goto repDriverImport
if "%opt%"=="14" goto repDriverRefresh
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
call :Spin T_R_STEP1
echo %C% %T_R_STEP1%%N%
DISM /Online /Cleanup-Image /RestoreHealth
echo.
call :Spin T_R_STEP2
echo %C% %T_R_STEP2%%N%
sfc /scannow
echo.
echo %G% %T_R_FULLDONE%%N%
pause
goto repair

:repChkScan
chkdsk %SystemDrive% /scan
pause
goto repair

:repChkFix
call :confirm "%T_R_CHKFIXCONFIRM% (%SystemDrive%)" || goto repair
echo Y| chkdsk %SystemDrive% /f
call :log "CHKDSK scheduled"
pause
goto repair

:repRestorePt
call :Spin T_S_BUILDING
echo %C% %T_S_BUILDING%%N%
powershell -NoProfile -Command "Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction SilentlyContinue; try { Checkpoint-Computer -Description 'TechToolkit manual restore point' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Host ' Restore point created.' -ForegroundColor Green } catch { Write-Host (' Could not create restore point: '+$_.Exception.Message) -ForegroundColor Yellow; Write-Host ' Note: Windows allows only one restore point every 24 hours by default.' }"
call :log "Restore point attempted"
pause
goto repair

:repWU
call :confirm "%T_R_WUCONFIRM%" || goto repair
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
echo %G% %T_R_WUDONE%%N%
pause
goto repair

:repWinget
where winget >nul 2>&1 || (echo %Y% %T_R_WINGETMISSING%%N% & pause & goto repair)
winget upgrade
echo.
call :confirm "%T_R_WINGETCONFIRM%" || goto repair
call :log "winget upgrade --all"
winget upgrade --all --accept-source-agreements --accept-package-agreements
pause
goto repair

:repExplorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %G% %T_R_EXPLORERDONE%%N%
timeout /t 2 >nul
goto repair

:repMemDiag
if exist "%windir%\System32\mdsched.exe" (start "" "%windir%\System32\mdsched.exe") else (echo %Y% %T_R_MEMDIAGMISSING%%N% & pause)
goto repair

:repDriverExport
call :header "%T_H_REPAIR%"
echo  %Y%[1]%N%  %T_R_DRVDESTDEFAULT%
echo  %Y%[2]%N%  %T_R_DRVDESTCUSTOM%
echo  %Y%[3]%N%  %T_R_DRVDESTSCRIPT%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "dsub="
set /p "dsub=%G% %T_SELECT% %N%"
call :stamp
if "%dsub%"=="1" set "DEST=%RPT%\DriverExport_%STAMP%" & goto repDriverExportRun
if "%dsub%"=="2" goto repDriverExportCustom
if "%dsub%"=="3" set "DEST=%~dp0DriverExport_%STAMP%" & goto repDriverExportRun
goto repair

:repDriverExportCustom
set "CUSTPATH="
set /p "CUSTPATH= %T_R_DRVDESTPROMPT% "
if not defined CUSTPATH goto repair
set "DEST=%CUSTPATH%\DriverExport_%STAMP%"

:repDriverExportRun
md "%DEST%" >nul 2>&1
call :Spin T_R_DRVEXPORTING
echo %C% %T_R_DRVEXPORTING%%N%
DISM /Online /Export-Driver /Destination:"%DEST%"
call :log "Drivers exported to %DEST%"
echo %G% %T_R_DRVEXPORTDONE% %DEST%%N%
start "" explorer "%DEST%"
pause
goto repair

:repDriverImport
set "SRC="
set /p "SRC= %T_R_DRVIMPORTPROMPT% "
if not defined SRC goto repair
if not exist "%SRC%" (echo %R% %T_R_DRVPATHNOTFOUND%%N% & pause & goto repair)
call :confirm "%T_R_DRVIMPORTCONFIRM%" || goto repair
call :Spin T_R_DRVIMPORTING
echo %C% %T_R_DRVIMPORTING%%N%
pnputil /add-driver "%SRC%\*.inf" /subdirs /install
call :log "Drivers imported from %SRC%"
echo %G% %T_R_DRVIMPORTDONE%%N%
pause
goto repair

:repDriverRefresh
call :confirm "%T_R_DRVREFRESHCONFIRM%" || goto repair
call :stamp
set "DEST=%TEMP%\TechToolkit_DriverRefresh_%STAMP%"
md "%DEST%" >nul 2>&1
call :Spin T_R_DRVEXPORTING
echo %C% %T_R_DRVEXPORTING%%N%
DISM /Online /Export-Driver /Destination:"%DEST%"
call :Spin T_R_DRVIMPORTING
echo %C% %T_R_DRVIMPORTING%%N%
pnputil /add-driver "%DEST%\*.inf" /subdirs /install
call :log "Driver refresh: exported and reinstalled via %DEST%"
rd /s /q "%DEST%" >nul 2>&1
echo %G% %T_R_DRVREFRESHDONE%%N%
pause
goto repair

:: ============================================================
:network
call :header "%T_H_NETWORK%"
echo  %Y%[1]%N%  %T_N1%
echo  %Y%[2]%N%  %T_N2%
echo  %Y%[3]%N%  %T_N3%
echo  %Y%[4]%N%  %T_N4%
echo  %Y%[5]%N%  %T_N5%
echo  %Y%[6]%N%  %T_N6%
echo  %Y%[7]%N%  %T_N7%
echo  %Y%[8]%N%  %T_N8%
echo  %Y%[9]%N%  %T_N9%          %D%%T_N9D%%N%
echo  %Y%[10]%N% %T_N10%
echo  %Y%[11]%N% %T_N11%          %D%%T_N11D%%N%
echo  %Y%[12]%N% %T_N12%
echo  %Y%[13]%N% %T_N13%          %D%%T_N13D%%N%
echo  %Y%[14]%N% %T_N14%           %D%%T_N14D%%N%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
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
if "%opt%"=="12" goto netWifiPass
if "%opt%"=="13" goto netSpeed
if "%opt%"=="14" goto netIPConfig
call :invalid
goto network

:netDiag
call :header "%T_H_NETDIAG%"
set "GW="
for /f "usebackq delims=" %%g in (`powershell -NoProfile -Command "(Get-NetRoute -DestinationPrefix 0.0.0.0/0 -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1).NextHop"`) do set "GW=%%g"
if defined GW (
    ping -n 2 "%GW%" >nul && (echo  %G%[ OK ]%N% %T_N_ROUTEROK% %GW%) || (echo  %R%[FAIL]%N% %T_N_ROUTERFAIL% %GW%)
) else (
    echo  %R%[FAIL]%N% %T_N_NOGATEWAY%
)
ping -n 2 1.1.1.1 >nul && (echo  %G%[ OK ]%N% %T_N_INETOK%) || (echo  %R%[FAIL]%N% %T_N_INETFAIL%)
nslookup www.microsoft.com >nul 2>&1 && (echo  %G%[ OK ]%N% %T_N_DNSOK%) || (echo  %R%[FAIL]%N% %T_N_DNSFAIL%)
echo.
pause
goto network

:netPublic
powershell -NoProfile -Command "try { Write-Host (' Public IP: ' + (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 8)) -ForegroundColor Green } catch { Write-Host ' Could not reach the internet.' -ForegroundColor Red }"
pause
goto network

:netRenew
call :confirm "%T_N_RENEWCONFIRM%" || goto network
ipconfig /release >nul
ipconfig /renew
pause
goto network

:netPing
set "HOST="
set /p "HOST= %T_N_PINGPROMPT% "
if not defined HOST goto network
ping -n 6 "%HOST%"
pause
goto network

:netTrace
set "HOST="
set /p "HOST= %T_N_TRACEPROMPT% "
if not defined HOST goto network
tracert -d "%HOST%"
pause
goto network

:netConns
call :stamp
set "F=%RPT%\Connections_%STAMP%.txt"
netstat -abno > "%F%" 2>&1
start "" notepad "%F%"
goto network

:netReset
call :confirm "%T_N_RESETCONFIRM%" || goto network
call :log "Network reset"
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
echo.
echo %Y% %T_N_RESETDONE%%N%
pause
goto network

:netWifiPass
call :header "%T_H_NETWORK%"
echo %C% %T_N_WIFIGATHERING%%N%
echo.
set "WIFIDIR=%TEMP%\TechToolkit_WifiExport_%RANDOM%"
md "%WIFIDIR%" >nul 2>&1
netsh wlan export profile key=clear folder="%WIFIDIR%" >nul 2>&1
powershell -NoProfile -Command "$nopass=$env:T_N_WIFINOPASS; Get-ChildItem -Path $env:WIFIDIR -Filter *.xml -ErrorAction SilentlyContinue | ForEach-Object { [xml]$x = Get-Content -Path $_.FullName; $n = $x.WLANProfile.name; $k = $x.WLANProfile.MSM.security.sharedKey.keyMaterial; if ([string]::IsNullOrEmpty($k)) { $k = $nopass }; Write-Host $n -NoNewline -ForegroundColor White; Write-Host '   -   ' -NoNewline -ForegroundColor DarkGray; Write-Host $k -ForegroundColor Green }"
rd /s /q "%WIFIDIR%" >nul 2>&1
echo.
pause
goto network

:netSpeed
call :header "%T_H_NETWORK%"
where speedtest >nul 2>&1
if errorlevel 1 (
    where winget >nul 2>&1 || (echo %Y% %T_R_WINGETMISSING%%N% & pause & goto network)
    call :confirm "%T_N_SPEEDCONFIRM%" || goto network
    echo %C% %T_N_SPEEDINSTALLING%%N%
    winget install --id Ookla.Speedtest.CLI -e --silent --accept-source-agreements --accept-package-agreements
    where speedtest >nul 2>&1 || (echo %Y% %T_N_SPEEDRETRY%%N% & pause & goto network)
)
call :Spin T_N_SPEEDRUNNING
speedtest --accept-license --accept-gdpr
pause
goto network

:netIPConfig
call :header "%T_H_NETWORK%"
netsh interface show interface
echo.
set "ADP="
set /p "ADP= %T_N_ADAPTERPROMPT% "
if not defined ADP goto network
echo.
echo  %Y%[1]%N%  %T_N_DHCP%
echo  %Y%[2]%N%  %T_N_STATIC%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "sub="
set /p "sub=%G% %T_SELECT% %N%"
if "%sub%"=="1" goto netIPDhcpApply
if "%sub%"=="2" goto netIPStaticApply
goto network

:netIPDhcpApply
call :confirm "%T_N_DHCPCONFIRM%" || goto network
netsh interface ip set address name="%ADP%" dhcp
netsh interface ip set dns name="%ADP%" dhcp
call :log "Set %ADP% to DHCP"
call :Spin T_N_IPAPPLYING
echo %G% %T_N_IPDONE%%N%
echo.
netsh interface ip show config name="%ADP%"
pause
goto network

:netIPStaticApply
set "SIP="
set /p "SIP= %T_N_IPPROMPT% "
if not defined SIP goto network
set "SMASKIN="
set /p "SMASKIN= %T_N_MASKPROMPT% "
if not defined SMASKIN goto network
set "SGW="
set /p "SGW= %T_N_GWPROMPT% "
if not defined SGW goto network
set "SMAC="
set /p "SMAC= %T_N_MACPROMPT% "
set "MASK=%SMASKIN%"
if "%MASK:~0,1%"=="/" set "MASK=%MASK:~1%"
echo %MASK%| findstr /r "^[0-9][0-9]*$" >nul
if not errorlevel 1 call :CidrToMask %MASK%
call :confirm "%T_N_STATICCONFIRM% %SIP%" || goto network
netsh interface ip set address name="%ADP%" static %SIP% %MASK% %SGW%
call :log "Set %ADP% to static %SIP% %MASK% %SGW%"
if defined SMAC call :SetMacAddress
call :Spin T_N_IPAPPLYING
echo %G% %T_N_IPDONE%%N%
echo.
netsh interface ip show config name="%ADP%"
pause
goto network

:SetMacAddress
set "MACCLEAN=%SMAC::=%"
set "MACCLEAN=%MACCLEAN:-=%"
set "MACCLEAN=%MACCLEAN: =%"
powershell -NoProfile -Command "$m='%MACCLEAN%'; if ($m -notmatch '^[0-9A-Fa-f]{12}$') { exit 1 }; try { Set-NetAdapterAdvancedProperty -Name '%ADP%' -RegistryKeyword 'NetworkAddress' -RegistryValue $m -ErrorAction Stop; Restart-NetAdapter -Name '%ADP%' -Confirm:$false -ErrorAction Stop; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo %R% %T_N_MACINVALID%%N%
) else (
    call :log "Set MAC on %ADP% to %MACCLEAN%"
    echo %G% %T_N_MACDONE%%N%
)
exit /b

:: ============================================================
:cleanup
call :header "%T_H_CLEANUP%"
echo  %Y%[1]%N%  %T_L1%
echo  %Y%[2]%N%  %T_L2%
echo  %Y%[3]%N%  %T_L3%
echo  %Y%[4]%N%  %T_L4%
echo  %Y%[5]%N%  %T_L5%     %D%%T_L5D%%N%
echo  %Y%[6]%N%  %T_L6%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
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
call :confirm "%T_L_USERTEMPCONFIRM% (%TEMP%)" || goto cleanup
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
call :log "User temp cleared"
echo %G% %T_DONE%%N%
pause
goto cleanup

:clnWinTemp
call :confirm "%T_L_WINTEMPCONFIRM% (%windir%\Temp)" || goto cleanup
del /f /s /q "%windir%\Temp\*" >nul 2>&1
for /d %%d in ("%windir%\Temp\*") do rd /s /q "%%d" >nul 2>&1
call :log "Windows temp cleared"
echo %G% %T_DONE%%N%
pause
goto cleanup

:clnBin
call :confirm "%T_L_BINCONFIRM%" || goto cleanup
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
call :log "Recycle Bin emptied"
echo %G% %T_DONE%%N%
pause
goto cleanup

:: ============================================================
:power
call :header "%T_H_POWER%"
echo  %Y%[1]%N%  %T_P1%
echo  %Y%[2]%N%  %T_P2%
echo  %Y%[3]%N%  %T_P3%
echo  %Y%[4]%N%  %T_P4%
echo  %Y%[5]%N%  %T_P5%
echo  %Y%[6]%N%  %T_P6%
echo  %Y%[7]%N%  %T_P7%
echo  %Y%[8]%N%  %T_P8%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
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
call :confirm "%T_P_BIOSCONFIRM%" || goto power
shutdown /r /fw /t 5 || (echo %Y% %T_P_BIOSFAIL%%N% & pause)
goto power

:pwAdv
call :confirm "%T_P_ADVCONFIRM%" || goto power
shutdown /r /o /t 5
goto power

:pwSafeOn
call :confirm "%T_P_SAFEONCONFIRM%" || goto power
bcdedit /set {current} safeboot minimal
call :log "Safe Mode enabled"
echo %Y% %T_P_SAFEONNOTE%%N%
pause
goto power

:pwSafeOff
bcdedit /deletevalue {current} safeboot
call :log "Safe Mode disabled"
pause
goto power

:pwRestart
call :confirm "%T_P_RESTARTCONFIRM%" || goto power
shutdown /r /t 5
goto power

:pwShutdown
call :confirm "%T_P_SHUTDOWNCONFIRM%" || goto power
shutdown /s /t 5
goto power

:: ============================================================
::  HELPERS
:: ============================================================
:header
cls
echo %C%======================================================================%N%
echo %W%               WINDOWS TECHNICIAN TOOLKIT  PRO%N%
echo %D%                    %T_POWEREDBY%%N%
echo %C%======================================================================%N%
echo %D%  %T_PC% %COMPUTERNAME%   %T_USER% %USERNAME%   %DATE% %TIME:~0,5%%N%
echo %Y%  ^>^> %~1%N%
echo.
exit /b

:confirm
echo.
echo %R% %T_WARNING% %~1%N%
set "ans="
set /p "ans= %T_TYPEYES% "
if /i "%ans%"=="YES" exit /b 0
echo %D% %T_CANCELLED%%N%
timeout /t 2 >nul
exit /b 1

:invalid
echo %R% %T_INVALID%%N%
timeout /t 1 >nul
exit /b

:stamp
for /f "usebackq delims=" %%t in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"`) do set "STAMP=%%t"
exit /b

:log
>>"%LOG%" echo [%DATE% %TIME:~0,8%] %~1
exit /b

:LaunchMonitor
set "MONFILE=%TEMP%\ttk_mon_%RANDOM%.b64"
set "MONPS1=%MONFILE:.b64=.ps1%"
if exist "%MONFILE%" del /f /q "%MONFILE%" >nul 2>&1
if exist "%MONPS1%" del /f /q "%MONPS1%" >nul 2>&1
>>"%MONFILE%" echo JABQAEkARAAgAHwAIABPAHUAdAAtAEYAaQBsAGUAIAAtAEYAaQBsAGUAUABhAHQAaAAgACIAJABlAG4AdgA6AFQARQBNAFAAXAB0AHQAawBfAG0AbwBuAGkAdABvAHIALgBwAGkAZAAiACAALQBFAG4AYwBvAGQAaQBuAGcAIABhAHMAYwBpAGkAIAAtAEYAbwByAGMAZQAKACQAYwBvAHIAZQBDAG8AdQBuAHQAIAA9ACAAKABHAGUAdAAtAEMAaQBtAEkAbgBzAHQAYQBuAGMAZQAgAFcAaQBuADMAMgBfAFAAcgBvAGMAZQBzAHMAbwByACAALQBFAHIAcgBvAHIAQQBjAHQAaQBvAG4AIABTAGkAbABlAG4AdABsAHkAQwBvAG4AdABpAG4A
>>"%MONFILE%" echo dQBlACAAfAAgAE0AZQBhAHMAdQByAGUALQBPAGIAagBlAGMAdAAgAC0AUAByAG8AcABlAHIAdAB5ACAATgB1AG0AYgBlAHIATwBmAEwAbwBnAGkAYwBhAGwAUAByAG8AYwBlAHMAcwBvAHIAcwAgAC0AUwB1AG0AKQAuAFMAdQBtAAoAaQBmACAAKAAtAG4AbwB0ACAAJABjAG8AcgBlAEMAbwB1AG4AdAApACAAewAgACQAYwBvAHIAZQBDAG8AdQBuAHQAIAA9ACAAMQAgAH0ACgAkAGMAcAB1AEgAaQBzAHQAIAA9ACAATgBlAHcALQBPAGIAagBlAGMAdAAgAFMAeQBzAHQAZQBtAC4AQwBvAGwAbABlAGMAdABpAG8AbgBzAC4ARwBlAG4A
>>"%MONFILE%" echo ZQByAGkAYwAuAFEAdQBlAHUAZQBbAGkAbgB0AF0ACgAkAHIAYQBtAEgAaQBzAHQAIAA9ACAATgBlAHcALQBPAGIAagBlAGMAdAAgAFMAeQBzAHQAZQBtAC4AQwBvAGwAbABlAGMAdABpAG8AbgBzAC4ARwBlAG4AZQByAGkAYwAuAFEAdQBlAHUAZQBbAGkAbgB0AF0ACgAkAHAAcgBlAHYAUAByAG8AYwAgAD0AIABAAHsAfQAKACQAcAByAGUAdgBUAGkAbQBlACAAPQAgAEcAZQB0AC0ARABhAHQAZQAKAAoAZgB1AG4AYwB0AGkAbwBuACAAQgBhAHIAKAAkAHAALAAgACQAdwApACAAewAKACAAIAAgACAAaQBmACAAKAAkAHAAIAAtAGwA
>>"%MONFILE%" echo dAAgADAAKQAgAHsAIAAkAHAAIAA9ACAAMAAgAH0ACgAgACAAIAAgAGkAZgAgACgAJABwACAALQBnAHQAIAAxADAAMAApACAAewAgACQAcAAgAD0AIAAxADAAMAAgAH0ACgAgACAAIAAgACQAZgAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAJABwACAAKgAgACQAdwAgAC8AIAAxADAAMAApAAoAIAAgACAAIAByAGUAdAB1AHIAbgAgACgAJwAjACcAIAAqACAAJABmACkAIAArACAAKAAnAC0AJwAgACoAIAAoACQAdwAgAC0AIAAkAGYAKQApAAoAfQAKAGYAdQBuAGMAdABpAG8AbgAgAEMAbwBsACgAJABwACkAIAB7AAoA
>>"%MONFILE%" echo IAAgACAAIABpAGYAIAAoACQAcAAgAC0AZwBlACAAOAA1ACkAIAB7ACAAJwBSAGUAZAAnACAAfQAgAGUAbABzAGUAaQBmACAAKAAkAHAAIAAtAGcAZQAgADYAMAApACAAewAgACcAWQBlAGwAbABvAHcAJwAgAH0AIABlAGwAcwBlACAAewAgACcARwByAGUAZQBuACcAIAB9AAoAfQAKAGYAdQBuAGMAdABpAG8AbgAgAFMAcABhAHIAawAoACQAcQApACAAewAKACAAIAAgACAAJABjAGgAYQByAHMAIAA9ACAAJwAgACcALAAgACcALgAnACwAIAAnAC0AJwAsACAAJwA9ACcALAAgACcAIwAnAAoAIAAgACAAIAAkAHMAIAA9ACAAJwAnAAoA
>>"%MONFILE%" echo IAAgACAAIABmAG8AcgBlAGEAYwBoACAAKAAkAHYAIABpAG4AIAAkAHEAKQAgAHsACgAgACAAIAAgACAAIAAgACAAJABpAGQAeAAgAD0AIABbAG0AYQB0AGgAXQA6ADoARgBsAG8AbwByACgAJAB2ACAALwAgADIAMQApAAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABpAGQAeAAgAC0AZwB0ACAANAApACAAewAgACQAaQBkAHgAIAA9ACAANAAgAH0ACgAgACAAIAAgACAAIAAgACAAaQBmACAAKAAkAGkAZAB4ACAALQBsAHQAIAAwACkAIAB7ACAAJABpAGQAeAAgAD0AIAAwACAAfQAKACAAIAAgACAAIAAgACAAIAAkAHMAIAArAD0A
>>"%MONFILE%" echo IAAkAGMAaABhAHIAcwBbACQAaQBkAHgAXQAKACAAIAAgACAAfQAKACAAIAAgACAAcgBlAHQAdQByAG4AIAAkAHMACgB9AAoAZgB1AG4AYwB0AGkAbwBuACAAUABhAGQAKAAkAHMALAAgACQAdwApACAAewAKACAAIAAgACAAaQBmACAAKAAkAHMALgBMAGUAbgBnAHQAaAAgAC0AZwBlACAAJAB3ACkAIAB7ACAAcgBlAHQAdQByAG4AIAAkAHMALgBTAHUAYgBzAHQAcgBpAG4AZwAoADAALAAgACQAdwApACAAfQAKACAAIAAgACAAcgBlAHQAdQByAG4AIAAkAHMAIAArACAAKAAnACAAJwAgACoAIAAoACQAdwAgAC0AIAAkAHMALgBMAGUA
>>"%MONFILE%" echo bgBnAHQAaAApACkACgB9AAoACgBmAHUAbgBjAHQAaQBvAG4AIABTAGUAdAAtAFQAVABLAFQAbwBwAG0AbwBzAHQAIAB7AAoAIAAgACAAIABpAGYAIAAoACQAZQBuAHYAOgBXAFQAXwBTAEUAUwBTAEkATwBOACkAIAB7ACAAcgBlAHQAdQByAG4AIAB9AAoAIAAgACAAIAB0AHIAeQAgAHsACgAgACAAIAAgACAAIAAgACAAJABzAGMAcgAgAD0AIABbAFMAeQBzAHQAZQBtAC4AVwBpAG4AZABvAHcAcwAuAEYAbwByAG0AcwAuAFMAYwByAGUAZQBuAF0AOgA6AFAAcgBpAG0AYQByAHkAUwBjAHIAZQBlAG4ALgBXAG8AcgBrAGkAbgBnAEEA
>>"%MONFILE%" echo cgBlAGEACgAgACAAIAAgACAAIAAgACAAJAB3AHcAIAA9ACAAWwBpAG4AdABdACgAJABzAGMAcgAuAFcAaQBkAHQAaAAgAC8AIAAyACkACgAgACAAIAAgACAAIAAgACAAWwBUAFQASwBOAGEAdABpAHYAZQAuAFcAaQBuADMAMgBdADoAOgBTAGUAdABXAGkAbgBkAG8AdwBQAG8AcwAoAFsAVABUAEsATgBhAHQAaQB2AGUALgBXAGkAbgAzADIAXQA6ADoARwBlAHQAQwBvAG4AcwBvAGwAZQBXAGkAbgBkAG8AdwAoACkALAAgACgATgBlAHcALQBPAGIAagBlAGMAdAAgAEkAbgB0AFAAdAByACgALQAxACkAKQAsACAAJABzAGMAcgAuAFcA
>>"%MONFILE%" echo aQBkAHQAaAAgAC0AIAAkAHcAdwAsACAAMAAsACAAJAB3AHcALAAgACQAcwBjAHIALgBIAGUAaQBnAGgAdAAsACAAMAApACAAfAAgAE8AdQB0AC0ATgB1AGwAbAAKACAAIAAgACAAfQAgAGMAYQB0AGMAaAAgAHsAfQAKAH0ACgAKAHQAcgB5ACAAewAKACAAIAAgACAAJABIAG8AcwB0AC4AVQBJAC4AUgBhAHcAVQBJAC4AVwBpAG4AZABvAHcAVABpAHQAbABlACAAPQAgACcAVABUAEsAIABMAGkAdgBlACAATQBvAG4AaQB0AG8AcgAnAAoAIAAgACAAIAAkAHEAIAA9ACAAWwBjAGgAYQByAF0AMwA0AAoAIAAgACAAIAAkAHMAaQBnACAA
>>"%MONFILE%" echo PQAgACcAWwBEAGwAbABJAG0AcABvAHIAdAAoACcAIAArACAAJABxACAAKwAgACcAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAJwAgACsAIAAkAHEAIAArACAAJwApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABJAG4AdABQAHQAcgAgAEcAZQB0AEMAbwBuAHMAbwBsAGUAVwBpAG4AZABvAHcAKAApADsAIABbAEQAbABsAEkAbQBwAG8AcgB0ACgAJwAgACsAIAAkAHEAIAArACAAJwB1AHMAZQByADMAMgAuAGQAbABsACcAIAArACAAJABxACAAKwAgACcAKQBdACAAcAB1AGIAbABpAGMAIABzAHQA
>>"%MONFILE%" echo YQB0AGkAYwAgAGUAeAB0AGUAcgBuACAAYgBvAG8AbAAgAFMAZQB0AFcAaQBuAGQAbwB3AFAAbwBzACgASQBuAHQAUAB0AHIAIABoAFcAbgBkACwAIABJAG4AdABQAHQAcgAgAGgAVwBuAGQASQBuAHMAZQByAHQAQQBmAHQAZQByACwAIABpAG4AdAAgAFgALAAgAGkAbgB0ACAAWQAsACAAaQBuAHQAIABjAHgALAAgAGkAbgB0ACAAYwB5ACwAIAB1AGkAbgB0ACAAdQBGAGwAYQBnAHMAKQA7ACcACgAgACAAIAAgAEEAZABkAC0AVAB5AHAAZQAgAC0ATgBhAG0AZQAgAFcAaQBuADMAMgAgAC0ATgBhAG0AZQBzAHAAYQBjAGUAIABUAFQA
>>"%MONFILE%" echo SwBOAGEAdABpAHYAZQAgAC0ATQBlAG0AYgBlAHIARABlAGYAaQBuAGkAdABpAG8AbgAgACQAcwBpAGcACgAgACAAIAAgAEEAZABkAC0AVAB5AHAAZQAgAC0AQQBzAHMAZQBtAGIAbAB5AE4AYQBtAGUAIABTAHkAcwB0AGUAbQAuAFcAaQBuAGQAbwB3AHMALgBGAG8AcgBtAHMACgB9ACAAYwBhAHQAYwBoACAAewB9AAoAUwBlAHQALQBUAFQASwBUAG8AcABtAG8AcwB0AAoACgBDAGwAZQBhAHIALQBIAG8AcwB0AAoACgAkAHQAdABrAEYAcgBhAG0AZQAgAD0AIAAwAAoAdwBoAGkAbABlACAAKAAtAG4AbwB0ACAAWwBDAG8AbgBzAG8A
>>"%MONFILE%" echo bABlAF0AOgA6AEsAZQB5AEEAdgBhAGkAbABhAGIAbABlACkAIAB7AAoAIAAgACAAIAAkAHQAdABrAEYAcgBhAG0AZQArACsACgAgACAAIAAgAGkAZgAgACgAJAB0AHQAawBGAHIAYQBtAGUAIAAlACAAMQAwACAALQBlAHEAIAAwACkAIAB7ACAAUwBlAHQALQBUAFQASwBUAG8AcABtAG8AcwB0ACAAfQAKACAAIAAgACAAdAByAHkAIAB7AAoAIAAgACAAIAAkAG4AbwB3ACAAPQAgAEcAZQB0AC0ARABhAHQAZQAKACAAIAAgACAAJABlAGwAYQBwAHMAZQBkACAAPQAgACgAJABuAG8AdwAgAC0AIAAkAHAAcgBlAHYAVABpAG0AZQApAC4A
>>"%MONFILE%" echo VABvAHQAYQBsAFMAZQBjAG8AbgBkAHMACgAgACAAIAAgAGkAZgAgACgAJABlAGwAYQBwAHMAZQBkACAALQBsAHQAIAAwAC4AMQApACAAewAgACQAZQBsAGEAcABzAGUAZAAgAD0AIAAwAC4AMQAgAH0ACgAKACAAIAAgACAAJABjAHAAdQBPAGIAagAgAD0AIABHAGUAdAAtAEMAaQBtAEkAbgBzAHQAYQBuAGMAZQAgAFcAaQBuADMAMgBfAFAAcgBvAGMAZQBzAHMAbwByACAALQBFAHIAcgBvAHIAQQBjAHQAaQBvAG4AIABTAGkAbABlAG4AdABsAHkAQwBvAG4AdABpAG4AdQBlACAAfAAgAE0AZQBhAHMAdQByAGUALQBPAGIAagBlAGMA
>>"%MONFILE%" echo dAAgAC0AUAByAG8AcABlAHIAdAB5ACAATABvAGEAZABQAGUAcgBjAGUAbgB0AGEAZwBlACAALQBBAHYAZQByAGEAZwBlAAoAIAAgACAAIAAkAGMAcAB1ACAAPQAgADAACgAgACAAIAAgAGkAZgAgACgAJABjAHAAdQBPAGIAagAgAC0AYQBuAGQAIAAkAGMAcAB1AE8AYgBqAC4AQQB2AGUAcgBhAGcAZQApACAAewAgACQAYwBwAHUAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACQAYwBwAHUATwBiAGoALgBBAHYAZQByAGEAZwBlACkAIAB9AAoAIAAgACAAIAAkAGMAcAB1AEgAaQBzAHQALgBFAG4AcQB1AGUAdQBlACgA
>>"%MONFILE%" echo JABjAHAAdQApAAoAIAAgACAAIABpAGYAIAAoACQAYwBwAHUASABpAHMAdAAuAEMAbwB1AG4AdAAgAC0AZwB0ACAAMgA0ACkAIAB7ACAAWwB2AG8AaQBkAF0AJABjAHAAdQBIAGkAcwB0AC4ARABlAHEAdQBlAHUAZQAoACkAIAB9AAoACgAgACAAIAAgACQAbwBzAGkAIAA9ACAARwBlAHQALQBDAGkAbQBJAG4AcwB0AGEAbgBjAGUAIABXAGkAbgAzADIAXwBPAHAAZQByAGEAdABpAG4AZwBTAHkAcwB0AGUAbQAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAKACAAIAAgACAA
>>"%MONFILE%" echo JAByAGEAbQAgAD0AIAAwAAoAIAAgACAAIAAkAHIAYQBtAFUAcwBlAGQARwBCACAAPQAgADAACgAgACAAIAAgACQAcgBhAG0AVABvAHQAYQBsAEcAQgAgAD0AIAAwAAoAIAAgACAAIABpAGYAIAAoACQAbwBzAGkAIAAtAGEAbgBkACAAJABvAHMAaQAuAFQAbwB0AGEAbABWAGkAcwBpAGIAbABlAE0AZQBtAG8AcgB5AFMAaQB6AGUAKQAgAHsACgAgACAAIAAgACAAIAAgACAAJAByAGEAbQAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAKAAoACQAbwBzAGkALgBUAG8AdABhAGwAVgBpAHMAaQBiAGwAZQBNAGUAbQBvAHIA
>>"%MONFILE%" echo eQBTAGkAegBlACAALQAgACQAbwBzAGkALgBGAHIAZQBlAFAAaAB5AHMAaQBjAGEAbABNAGUAbQBvAHIAeQApACAALwAgACQAbwBzAGkALgBUAG8AdABhAGwAVgBpAHMAaQBiAGwAZQBNAGUAbQBvAHIAeQBTAGkAegBlACkAIAAqACAAMQAwADAAKQAKACAAIAAgACAAIAAgACAAIAAkAHIAYQBtAFUAcwBlAGQARwBCACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAoACQAbwBzAGkALgBUAG8AdABhAGwAVgBpAHMAaQBiAGwAZQBNAGUAbQBvAHIAeQBTAGkAegBlACAALQAgACQAbwBzAGkALgBGAHIAZQBlAFAAaAB5AHMA
>>"%MONFILE%" echo aQBjAGEAbABNAGUAbQBvAHIAeQApACAALwAgADEATQBCACwAIAAyACkACgAgACAAIAAgACAAIAAgACAAJAByAGEAbQBUAG8AdABhAGwARwBCACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAkAG8AcwBpAC4AVABvAHQAYQBsAFYAaQBzAGkAYgBsAGUATQBlAG0AbwByAHkAUwBpAHoAZQAgAC8AIAAxAE0AQgAsACAAMgApAAoAIAAgACAAIAB9AAoAIAAgACAAIAAkAHIAYQBtAEgAaQBzAHQALgBFAG4AcQB1AGUAdQBlACgAJAByAGEAbQApAAoAIAAgACAAIABpAGYAIAAoACQAcgBhAG0ASABpAHMAdAAuAEMAbwB1AG4A
>>"%MONFILE%" echo dAAgAC0AZwB0ACAAMgA0ACkAIAB7ACAAWwB2AG8AaQBkAF0AJAByAGEAbQBIAGkAcwB0AC4ARABlAHEAdQBlAHUAZQAoACkAIAB9AAoACgAgACAAIAAgACQAZABpAHMAawBzACAAPQAgAEAAKABHAGUAdAAtAEMAaQBtAEkAbgBzAHQAYQBuAGMAZQAgAFcAaQBuADMAMgBfAEwAbwBnAGkAYwBhAGwARABpAHMAawAgAC0ARgBpAGwAdABlAHIAIAAnAEQAcgBpAHYAZQBUAHkAcABlAD0AMwAnACAALQBFAHIAcgBvAHIAQQBjAHQAaQBvAG4AIABTAGkAbABlAG4AdABsAHkAQwBvAG4AdABpAG4AdQBlACAAfAAgAFMAbwByAHQALQBPAGIA
>>"%MONFILE%" echo agBlAGMAdAAgAEQAZQB2AGkAYwBlAEkARAAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAA0ACkACgAKACAAIAAgACAAJABuAGMAIAA9ACAARwBlAHQALQBDAG8AdQBuAHQAZQByACAAJwBcAE4AZQB0AHcAbwByAGsAIABJAG4AdABlAHIAZgBhAGMAZQAoACoAKQBcAEIAeQB0AGUAcwAgAFIAZQBjAGUAaQB2AGUAZAAvAHMAZQBjACcALAAgACcAXABOAGUAdAB3AG8AcgBrACAASQBuAHQAZQByAGYAYQBjAGUAKAAqACkAXABCAHkAdABlAHMAIABTAGUAbgB0AC8AcwBlAGMAJwAgAC0ARQByAHIA
>>"%MONFILE%" echo bwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAKACAAIAAgACAAJAByAHgAQgAgAD0AIAAwAAoAIAAgACAAIAAkAHQAeABCACAAPQAgADAACgAgACAAIAAgAGkAZgAgACgAJABuAGMAKQAgAHsACgAgACAAIAAgACAAIAAgACAAZgBvAHIAZQBhAGMAaAAgACgAJABzACAAaQBuACAAJABuAGMALgBDAG8AdQBuAHQAZQByAFMAYQBtAHAAbABlAHMAKQAgAHsACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAcwAuAEkAbgBzAHQAYQBuAGMAZQBOAGEAbQBlACAALQBuAG8AdABtAGEA
>>"%MONFILE%" echo dABjAGgAIAAnAGwAbwBvAHAAYgBhAGMAawB8AGkAcwBhAHQAYQBwACcAKQAgAHsACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABzAC4AUABhAHQAaAAgAC0AbQBhAHQAYwBoACAAJwByAGUAYwBlAGkAdgBlAGQAJwApACAAewAgACQAcgB4AEIAIAArAD0AIAAkAHMALgBDAG8AbwBrAGUAZABWAGEAbAB1AGUAIAB9ACAAZQBsAHMAZQAgAHsAIAAkAHQAeABCACAAKwA9ACAAJABzAC4AQwBvAG8AawBlAGQAVgBhAGwAdQBlACAAfQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAH0ACgAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgACAAfQAKACAAIAAgACAAfQAKACAAIAAgACAAJAByAHgATQBiAHAAcwAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAJAByAHgAQgAgACoAIAA4ACAALwAgADEATQBCACwAIAAyACkACgAgACAAIAAgACQAdAB4AE0AYgBwAHMAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACQAdAB4AEIAIAAqACAAOAAgAC8AIAAxAE0AQgAsACAAMgApAAoACgAgACAAIAAgACQAbgBpAGMAIAA9ACAAJABuAHUAbABsAAoAIAAgACAAIAAkAGQAZQBmAFIAbwB1AHQAZQAgAD0AIABHAGUAdAAtAE4AZQB0AFIAbwB1AHQA
>>"%MONFILE%" echo ZQAgAC0ARABlAHMAdABpAG4AYQB0AGkAbwBuAFAAcgBlAGYAaQB4ACAAJwAwAC4AMAAuADAALgAwAC8AMAAnACAALQBFAHIAcgBvAHIAQQBjAHQAaQBvAG4AIABTAGkAbABlAG4AdABsAHkAQwBvAG4AdABpAG4AdQBlACAAfAAgAFMAbwByAHQALQBPAGIAagBlAGMAdAAgAFIAbwB1AHQAZQBNAGUAdAByAGkAYwAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAAxAAoAIAAgACAAIABpAGYAIAAoACQAZABlAGYAUgBvAHUAdABlACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACQAbgBpAGMAIAA9ACAA
>>"%MONFILE%" echo RwBlAHQALQBDAGkAbQBJAG4AcwB0AGEAbgBjAGUAIABXAGkAbgAzADIAXwBOAGUAdAB3AG8AcgBrAEEAZABhAHAAdABlAHIAQwBvAG4AZgBpAGcAdQByAGEAdABpAG8AbgAgAC0ARgBpAGwAdABlAHIAIAAiAEkAUABFAG4AYQBiAGwAZQBkAD0AVAByAHUAZQAgAGEAbgBkACAASQBuAHQAZQByAGYAYQBjAGUASQBuAGQAZQB4AD0AJAAoACQAZABlAGYAUgBvAHUAdABlAC4ASQBuAHQAZQByAGYAYQBjAGUASQBuAGQAZQB4ACkAIgAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUA
>>"%MONFILE%" echo ZQAKACAAIAAgACAAfQAKACAAIAAgACAAaQBmACAAKAAtAG4AbwB0ACAAJABuAGkAYwApACAAewAKACAAIAAgACAAIAAgACAAIAAkAG4AaQBjACAAPQAgAEcAZQB0AC0AQwBpAG0ASQBuAHMAdABhAG4AYwBlACAAVwBpAG4AMwAyAF8ATgBlAHQAdwBvAHIAawBBAGQAYQBwAHQAZQByAEMAbwBuAGYAaQBnAHUAcgBhAHQAaQBvAG4AIAAtAEYAaQBsAHQAZQByACAAJwBJAFAARQBuAGEAYgBsAGUAZAA9AFQAcgB1AGUAJwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAgAHwA
>>"%MONFILE%" echo IABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAAxAAoAIAAgACAAIAB9AAoAIAAgACAAIAAkAGkAcABBAGQAZAByACAAPQAgACcATgAvAEEAJwAKACAAIAAgACAAJABpAHAATQBhAHMAawAgAD0AIAAnAE4ALwBBACcACgAgACAAIAAgACQAaQBwAEcAdwAgAD0AIAAnAE4ALwBBACcACgAgACAAIAAgAGkAZgAgACgAJABuAGkAYwApACAAewAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAbgBpAGMALgBJAFAAQQBkAGQAcgBlAHMAcwApACAAewAgACQAaQBwAEEAZABkAHIAIAA9ACAAJABuAGkAYwAuAEkA
>>"%MONFILE%" echo UABBAGQAZAByAGUAcwBzAFsAMABdACAAfQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAbgBpAGMALgBJAFAAUwB1AGIAbgBlAHQAKQAgAHsAIAAkAGkAcABNAGEAcwBrACAAPQAgACQAbgBpAGMALgBJAFAAUwB1AGIAbgBlAHQAWwAwAF0AIAB9AAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABuAGkAYwAuAEQAZQBmAGEAdQBsAHQASQBQAEcAYQB0AGUAdwBhAHkAKQAgAHsAIAAkAGkAcABHAHcAIAA9ACAAJABuAGkAYwAuAEQAZQBmAGEAdQBsAHQASQBQAEcAYQB0AGUAdwBhAHkAWwAwAF0AIAB9AAoAIAAgACAAIAB9AAoA
>>"%MONFILE%" echo CgAgACAAIAAgACQAcAByAG8AYwBzACAAPQAgAEcAZQB0AC0AUAByAG8AYwBlAHMAcwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAKACAAIAAgACAAJABjAHUAcgBDAHAAdQAgAD0AIABAAHsAfQAKACAAIAAgACAAZgBvAHIAZQBhAGMAaAAgACgAJABwACAAaQBuACAAJABwAHIAbwBjAHMAKQAgAHsAIAAkAGMAdQByAEMAcAB1AFsAJABwAC4ASQBkAF0AIAA9ACAAJABwAC4AQwBQAFUAIAB9AAoAIAAgACAAIAAkAHcAaQB0AGgAUABjAHQAIAA9ACAAZgBvAHIAZQBhAGMA
>>"%MONFILE%" echo aAAgACgAJABwACAAaQBuACAAJABwAHIAbwBjAHMAKQAgAHsACgAgACAAIAAgACAAIAAgACAAJABwAGMAdAAgAD0AIAAwAAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABwAHIAZQB2AFAAcgBvAGMALgBDAG8AbgB0AGEAaQBuAHMASwBlAHkAKAAkAHAALgBJAGQAKQAgAC0AYQBuAGQAIAAkAHAALgBDAFAAVQApACAAewAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABlAGwAdABhACAAPQAgACQAcAAuAEMAUABVACAALQAgACQAcAByAGUAdgBQAHIAbwBjAFsAJABwAC4ASQBkAF0ACgAgACAAIAAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IABpAGYAIAAoACQAZABlAGwAdABhACAALQBsAHQAIAAwACkAIAB7ACAAJABkAGUAbAB0AGEAIAA9ACAAMAAgAH0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAHAAYwB0ACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAoACQAZABlAGwAdABhACAALwAgACQAZQBsAGEAcABzAGUAZAAgAC8AIAAkAGMAbwByAGUAQwBvAHUAbgB0ACkAIAAqACAAMQAwADAALAAgADEAKQAKACAAIAAgACAAIAAgACAAIAB9AAoAIAAgACAAIAAgACAAIAAgACQAcABuAGEAbQBlACAAPQAgACQAcAAuAFAAcgBvAGMAZQBzAHMATgBhAG0A
>>"%MONFILE%" echo ZQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAcABuAGEAbQBlAC4ATABlAG4AZwB0AGgAIAAtAGcAdAAgADIAMAApACAAewAgACQAcABuAGEAbQBlACAAPQAgACQAcABuAGEAbQBlAC4AUwB1AGIAcwB0AHIAaQBuAGcAKAAwACwAIAAyADAAKQAgAH0ACgAgACAAIAAgACAAIAAgACAAWwBQAFMAQwB1AHMAdABvAG0ATwBiAGoAZQBjAHQAXQBAAHsAIABJAGQAIAA9ACAAJABwAC4ASQBkADsAIABOAGEAbQBlACAAPQAgACQAcABuAGEAbQBlADsAIABQAGMAdAAgAD0AIAAkAHAAYwB0ADsAIABNAGUAbQBNAEIAIAA9ACAAWwBtAGEA
>>"%MONFILE%" echo dABoAF0AOgA6AFIAbwB1AG4AZAAoACQAcAAuAFcAbwByAGsAaQBuAGcAUwBlAHQANgA0ACAALwAgADEATQBCACwAIAAxACkAIAB9AAoAIAAgACAAIAB9AAoAIAAgACAAIAAkAHQAbwBwACAAPQAgACQAdwBpAHQAaABQAGMAdAAgAHwAIABTAG8AcgB0AC0ATwBiAGoAZQBjAHQAIABQAGMAdAAgAC0ARABlAHMAYwBlAG4AZABpAG4AZwAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAA1AAoAIAAgACAAIAAkAHAAcgBlAHYAUAByAG8AYwAgAD0AIAAkAGMAdQByAEMAcAB1AAoAIAAgACAAIAAkAHAA
>>"%MONFILE%" echo cgBlAHYAVABpAG0AZQAgAD0AIAAkAG4AbwB3AAoACgAgACAAIAAgACQAVwAgAD0AIABbAEMAbwBuAHMAbwBsAGUAXQA6ADoAVwBpAG4AZABvAHcAVwBpAGQAdABoACAALQAgADEACgAgACAAIAAgAGkAZgAgACgAJABXACAALQBsAHQAIAA0ADAAKQAgAHsAIAAkAFcAIAA9ACAANAAwACAAfQAKACAAIAAgACAAJABiAGEAcgBXACAAPQAgAFsATQBhAHQAaABdADoAOgBNAGEAeAAoADgALAAgAFsAaQBuAHQAXQAoADIANAAgACoAIAAkAFcAIAAvACAAOQA2ACkAKQAKACAAIAAgACAAJABzAHAAYQByAGsAVwAgAD0AIABbAE0AYQB0AGgA
>>"%MONFILE%" echo XQA6ADoATQBhAHgAKAA4ACwAIABbAGkAbgB0AF0AKAAzADQAIAAqACAAJABXACAALwAgADkANgApACkACgAgACAAIAAgACQAZABpAHMAawBCAGEAcgBXACAAPQAgAFsATQBhAHQAaABdADoAOgBNAGEAeAAoADYALAAgAFsAaQBuAHQAXQAoADIAMAAgACoAIAAkAFcAIAAvACAAOQA2ACkAKQAKACAAIAAgACAAJABkAGkAcwBrAFAAYQBkAFcAIAA9ACAAWwBNAGEAdABoAF0AOgA6AE0AYQB4ACgAMQA4ACwAIABbAGkAbgB0AF0AKAA0ADAAIAAqACAAJABXACAALwAgADkANgApACkACgAKACAAIAAgACAAQwBsAGUAYQByAC0ASABvAHMA
>>"%MONFILE%" echo dAAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAkAGUAbgB2ADoAVABfAE0ATwBOAF8AVABJAFQATABFACAAJABXACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAQwB5AGEAbgAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAJwBDAFAAVQAgAFUAUwBBAEcARQAgACAAIAAgACAAIAB7ADAALAAzAH0AJQAgACAAWwAnACAALQBmACAAJABjAHAAdQApACAALQBOAG8ATgBlAHcAbABpAG4AZQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABXAGgAaQB0AGUA
>>"%MONFILE%" echo CgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAEIAYQByACAAJABjAHAAdQAgACQAYgBhAHIAVwApACAALQBOAG8ATgBlAHcAbABpAG4AZQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIAAoAEMAbwBsACAAJABjAHAAdQApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwBdACAAIAAnACAAKwAgACgAUwBwAGEAcgBrACAAJABjAHAAdQBIAGkAcwB0ACkAKQAgACQAcwBwAGEAcgBrAFcAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcA
>>"%MONFILE%" echo cgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnACAAIABDAG8AcgBlAHMAOgAgACcAIAArACAAJABjAG8AcgBlAEMAbwB1AG4AdAApACAAJABXACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBHAHIAYQB5AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgACQAVwApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKAAnAFIAQQBNACAAVQBTAEEARwBFACAAIAAgACAAIAAgAHsAMAAsADMAfQAlACAAIABbACcA
>>"%MONFILE%" echo IAAtAGYAIAAkAHIAYQBtACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAQgBhAHIAIAAkAHIAYQBtACAAJABiAGEAcgBXACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgACgAQwBvAGwAIAAkAHIAYQBtACkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAF0AIAAgACcAIAArACAAKABTAHAAYQByAGsA
>>"%MONFILE%" echo IAAkAHIAYQBtAEgAaQBzAHQAKQApACAAJABzAHAAYQByAGsAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsARwByAGEAeQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAoACcAIAAgAFUAcwBlAGQAOgAgACcAIAArACAAJAByAGEAbQBVAHMAZQBkAEcAQgAgACsAIAAnACAARwBCACAALwAgACcAIAArACAAJAByAGEAbQBUAG8AdABhAGwARwBCACAAKwAgACcAIABHAEIAJwApACAAJABXACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIA
>>"%MONFILE%" echo awBHAHIAYQB5AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgACQAVwApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcARABJAFMASwAgAFUAUwBBAEcARQAnACAAJABXACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoAIAAgACAAIABmAG8AcgAgACgAJABkAGkAIAA9ACAAMAA7ACAAJABkAGkAIAAtAGwAdAAgADQAOwAgACQAZABpACsAKwApACAAewAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAZABpACAALQBsAHQA
>>"%MONFILE%" echo IAAkAGQAaQBzAGsAcwAuAEMAbwB1AG4AdAApACAAewAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZAAgAD0AIAAkAGQAaQBzAGsAcwBbACQAZABpAF0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAGQAUABjAHQAIAA9ACAAMAAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABVAHMAZQBkACAAPQAgADAACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAGQAVABvAHQAYQBsACAAPQAgADAACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAZAAuAFMAaQB6AGUAKQAgAHsACgAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgACAAIAAgACAAIAAgACQAZABQAGMAdAAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAKAAoACQAZAAuAFMAaQB6AGUAIAAtACAAJABkAC4ARgByAGUAZQBTAHAAYQBjAGUAKQAgAC8AIAAkAGQALgBTAGkAegBlACkAIAAqACAAMQAwADAAKQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABkAFUAcwBlAGQAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACgAJABkAC4AUwBpAHoAZQAgAC0AIAAkAGQALgBGAHIAZQBlAFMAcABhAGMAZQApACAALwAgADEARwBCACwAIAAxACkACgAgACAA
>>"%MONFILE%" echo IAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABUAG8AdABhAGwAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACQAZAAuAFMAaQB6AGUAIAAvACAAMQBHAEIALAAgADEAKQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAH0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKAAnACAAIAB7ADAALAAtADMAfQAgAHsAMQAsADMAfQAlACAAIABbACcAIAAtAGYAIAAkAGQALgBEAGUAdgBpAGMAZQBJAEQALAAgACQAZABQAGMAdAApACAALQBOAG8ATgBlAHcAbABpAG4AZQAgAC0A
>>"%MONFILE%" echo RgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABXAGgAaQB0AGUACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABCAGEAcgAgACQAZABQAGMAdAAgACQAZABpAHMAawBCAGEAcgBXACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgACgAQwBvAGwAIAAkAGQAUABjAHQAKQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAF0AIAAgACcAIAArACAAJABkAFUAcwBlAGQA
>>"%MONFILE%" echo IAArACAAJwAgAEcAQgAgAC8AIAAnACAAKwAgACQAZABUAG8AdABhAGwAIAArACAAJwAgAEcAQgAnACkAIAAkAGQAaQBzAGsAUABhAGQAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsARwByAGEAeQAKACAAIAAgACAAIAAgACAAIAB9ACAAZQBsAHMAZQAgAHsACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgACQAVwApAAoAIAAgACAAIAAgACAAIAAgAH0ACgAgACAAIAAgAH0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQA
>>"%MONFILE%" echo IAAoAFAAYQBkACAAJwAnACAAJABXACkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAE4ARQBUAFcATwBSAEsAIAAgACAAIAAgACAAIAAgAEQAbwB3AG4AOgAgACcAIAArACAAJAByAHgATQBiAHAAcwAgACsAIAAnACAATQBiAHAAcwAgACAAIABVAHAAOgAgACcAIAArACAAJAB0AHgATQBiAHAAcwAgACsAIAAnACAATQBiAHAAcwAnACkAIAAkAFcAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABDAHkAYQBuAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEA
>>"%MONFILE%" echo ZAAgACgAJwAgACAASQBQACAAJwAgACsAIAAkAGkAcABBAGQAZAByACAAKwAgACcAIAAgACAATQBhAHMAawAgACcAIAArACAAJABpAHAATQBhAHMAawAgACsAIAAnACAAIAAgAEcAVwAgACcAIAArACAAJABpAHAARwB3ACkAIAAkAFcAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAJwAnACAAJABXACkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAC0AJwAgACoAIAAkAFcA
>>"%MONFILE%" echo KQAgACQAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsARwByAGEAeQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAnACAAIABUAE8AUAAgAFAAUgBPAEMARQBTAFMARQBTACAAQgBZACAAQwBQAFUAJwAgACQAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEMAeQBhAG4ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnACAAIAB7ADAALAAtADgAfQB7ADEALAAtADIAMgB9AHsAMgAsADgAfQB7ADMALAAxADAA
>>"%MONFILE%" echo fQAnACAALQBmACAAJwBQAEkARAAnACwAIAAnAE4AQQBNAEUAJwAsACAAJwBDAFAAVQAlACcALAAgACcATQBFAE0AKABNAEIAKQAnACkAIAAkAFcAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABXAGgAaQB0AGUACgAgACAAIAAgAGYAbwByACAAKAAkAGkAIAA9ACAAMAA7ACAAJABpACAALQBsAHQAIAA1ADsAIAAkAGkAKwArACkAIAB7AAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABpACAALQBsAHQAIAAkAHQAbwBwAC4AQwBvAHUAbgB0ACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJAByAG8A
>>"%MONFILE%" echo dwAgAD0AIAAkAHQAbwBwAFsAJABpAF0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwAgACAAewAwACwALQA4AH0AewAxACwALQAyADIAfQB7ADIALAA4ADoARgAxAH0AewAzACwAMQAwADoARgAxAH0AJwAgAC0AZgAgACQAcgBvAHcALgBJAGQALAAgACQAcgBvAHcALgBOAGEAbQBlACwAIAAkAHIAbwB3AC4AUABjAHQALAAgACQAcgBvAHcALgBNAGUAbQBNAEIAKQAgACQAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKACAA
>>"%MONFILE%" echo IAAgACAAIAAgACAAIAB9ACAAZQBsAHMAZQAgAHsACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgACQAVwApAAoAIAAgACAAIAAgACAAIAAgAH0ACgAgACAAIAAgAH0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAC0AJwAgACoAIAAkAFcAKQAgACQAVwApACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsARwByAGEAeQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAoACcA
>>"%MONFILE%" echo IAAgAEwAYQBzAHQAIAB1AHAAZABhAHQAZQBkADoAIAAnACAAKwAgACQAbgBvAHcALgBUAG8AUwB0AHIAaQBuAGcAKAAnAEgASAA6AG0AbQA6AHMAcwAnACkAIAArACAAJwAgACAAIAAgACAAJwAgACsAIAAkAGUAbgB2ADoAVABfAE0ATwBOAF8ARQBYAEkAVABIAEkATgBUACkAIAAkAFcAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAH0AIABjAGEAdABjAGgAIAB7AH0ACgAKACAAIAAgACAAUwB0AGEAcgB0AC0AUwBsAGUAZQBwACAALQBNAGkAbABsAGkAcwBlAGMA
>>"%MONFILE%" echo bwBuAGQAcwAgADEAMAAwADAACgB9AAoAWwBDAG8AbgBzAG8AbABlAF0AOgA6AFIAZQBhAGQASwBlAHkAKAAkAHQAcgB1AGUAKQAgAHwAIABPAHUAdAAtAE4AdQBsAGwACgAKAAoACgA=
powershell -NoProfile -Command "[System.IO.File]::WriteAllText($env:MONPS1, [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String(((Get-Content -Path $env:MONFILE -Raw) -replace '\s',''))))"
if defined WT_SESSION (
    wt -w 0 split-pane -V -s 0.42 powershell -NoProfile -ExecutionPolicy Bypass -File "%MONPS1%"
) else (
    start "" powershell -NoProfile -ExecutionPolicy Bypass -File "%MONPS1%"
)
exit /b

:CidrToMask
if "%~1"=="0" set "MASK=0.0.0.0" & exit /b
if "%~1"=="1" set "MASK=128.0.0.0" & exit /b
if "%~1"=="2" set "MASK=192.0.0.0" & exit /b
if "%~1"=="3" set "MASK=224.0.0.0" & exit /b
if "%~1"=="4" set "MASK=240.0.0.0" & exit /b
if "%~1"=="5" set "MASK=248.0.0.0" & exit /b
if "%~1"=="6" set "MASK=252.0.0.0" & exit /b
if "%~1"=="7" set "MASK=254.0.0.0" & exit /b
if "%~1"=="8" set "MASK=255.0.0.0" & exit /b
if "%~1"=="9" set "MASK=255.128.0.0" & exit /b
if "%~1"=="10" set "MASK=255.192.0.0" & exit /b
if "%~1"=="11" set "MASK=255.224.0.0" & exit /b
if "%~1"=="12" set "MASK=255.240.0.0" & exit /b
if "%~1"=="13" set "MASK=255.248.0.0" & exit /b
if "%~1"=="14" set "MASK=255.252.0.0" & exit /b
if "%~1"=="15" set "MASK=255.254.0.0" & exit /b
if "%~1"=="16" set "MASK=255.255.0.0" & exit /b
if "%~1"=="17" set "MASK=255.255.128.0" & exit /b
if "%~1"=="18" set "MASK=255.255.192.0" & exit /b
if "%~1"=="19" set "MASK=255.255.224.0" & exit /b
if "%~1"=="20" set "MASK=255.255.240.0" & exit /b
if "%~1"=="21" set "MASK=255.255.248.0" & exit /b
if "%~1"=="22" set "MASK=255.255.252.0" & exit /b
if "%~1"=="23" set "MASK=255.255.254.0" & exit /b
if "%~1"=="24" set "MASK=255.255.255.0" & exit /b
if "%~1"=="25" set "MASK=255.255.255.128" & exit /b
if "%~1"=="26" set "MASK=255.255.255.192" & exit /b
if "%~1"=="27" set "MASK=255.255.255.224" & exit /b
if "%~1"=="28" set "MASK=255.255.255.240" & exit /b
if "%~1"=="29" set "MASK=255.255.255.248" & exit /b
if "%~1"=="30" set "MASK=255.255.255.252" & exit /b
if "%~1"=="31" set "MASK=255.255.255.254" & exit /b
if "%~1"=="32" set "MASK=255.255.255.255" & exit /b
exit /b

:: ============================================================
::  ANIMATIONS
:: ============================================================
:Spin
setlocal
set "MSGVAR=%~1"
powershell -NoProfile -Command "$msg=$env:%MSGVAR%; $f='|','/','-','\'; for($i=0;$i -lt 14;$i++){ Write-Host ([char]13+'  '+$f[$i%%4]+'  '+$msg) -NoNewline -ForegroundColor Cyan; Start-Sleep -Milliseconds 90 }; Write-Host ([char]13+(' '*120)+[char]13) -NoNewline"
endlocal
exit /b

:Flash
powershell -NoProfile -Command "$f=' >','>> ','>>>','>>>>'; foreach($s in $f){ Write-Host ([char]13+'  '+$s) -NoNewline -ForegroundColor Cyan; Start-Sleep -Milliseconds 60 }; Write-Host ([char]13+(' '*40)+[char]13) -NoNewline"
exit /b

:: ============================================================
::  LANGUAGE SELECTION AND TEXT TABLES
:: ============================================================
:SelectLanguage
cls
echo %C%======================================================================%N%
echo %W%               WINDOWS TECHNICIAN TOOLKIT  PRO%N%
echo %C%======================================================================%N%
echo.
echo  %Y%[1]%N%  English
echo  %Y%[2]%N%  Deutsch
echo  %Y%[3]%N%  Turkce
echo.
set "langopt="
set /p "langopt=%G% Select / Waehlen / Secin (1-3): %N%"
if "%langopt%"=="1" set "LANG=EN" & exit /b
if "%langopt%"=="2" set "LANG=DE" & exit /b
if "%langopt%"=="3" set "LANG=TR" & exit /b
echo %R% Invalid choice / Ungueltige Eingabe / Gecersiz secim - please enter 1, 2 or 3%N%
timeout /t 2 >nul
goto SelectLanguage

:Lang_EN
set "T_SELECT=Select option:"
set "T_BACK=Back"
set "T_EXIT=Exit"
set "T_INVALID=Invalid option, try again."
set "T_GOODBYE=Goodbye!"
set "T_DONE=Done."
set "T_CANCELLED=Cancelled."
set "T_WARNING=WARNING:"
set "T_TYPEYES=Type YES to continue:"
set "T_LAUNCHED=Launched."
set "T_PC=PC:"
set "T_USER=User:"
set "T_REQADMIN=Requesting administrator rights..."
set "T_POWEREDBY=Powered by BASHAR SALMO"
set "T_H_MAIN=MAIN MENU"
set "T_H_CONSOLES=ADMIN CONSOLES"
set "T_H_SYSINFO=SYSTEM INFO AND REPORTS"
set "T_H_QUICK=QUICK SYSTEM SUMMARY"
set "T_H_DISK=DISK HEALTH"
set "T_H_ERRORS=CRITICAL AND ERROR EVENTS - LAST 24 HOURS"
set "T_H_LICENSE=ACTIVATION STATUS"
set "T_H_REPAIR=REPAIR AND MAINTENANCE"
set "T_H_NETWORK=NETWORK TOOLS"
set "T_H_NETDIAG=CONNECTION DIAGNOSIS"
set "T_H_CLEANUP=CLEANUP"
set "T_H_POWER=POWER AND BOOT"
set "T_M1=Admin Consoles"
set "T_M1D=CMD, PowerShell, Registry, Services..."
set "T_M2=System Info and Reports"
set "T_M2D=Summary, battery, drivers, errors"
set "T_M3=Repair and Maintenance"
set "T_M3D=SFC, DISM, CHKDSK, Windows Update fix"
set "T_M4=Network Tools"
set "T_M4D=Diagnose, DNS, IP, Wi-Fi, reset"
set "T_M5=Cleanup"
set "T_M5D=Temp files, Disk Cleanup, component store"
set "T_M6=Power and Boot"
set "T_M6D=BIOS, Advanced Startup, Safe Mode"
set "T_M7=Open Reports Folder"
set "T_M8=Check for Toolkit Updates"
set "T_U_CHECKING=Checking GitHub for a newer version..."
set "T_U_UNREACHABLE=Couldn't reach GitHub. Check your internet connection."
set "T_U_NOVERSION=Couldn't read a version number from the downloaded file."
set "T_U_INSTALLED=Installed"
set "T_U_LATEST=Latest on GitHub"
set "T_U_UPTODATE=You're already on the latest version."
set "T_U_AVAILABLE=A newer version is available. Install it now?"
set "T_U_SANITYFAIL=The downloaded file failed a safety check, nothing was changed."
set "T_U_UPDATING=Installing the update. The toolkit will restart in a new window..."
set "T_M9=BitLocker Disk Encryption"
set "T_H_BITLOCKER=BITLOCKER DISK ENCRYPTION"
set "T_BL_M1=Show BitLocker status"
set "T_BL_M2=Turn on BitLocker for a drive"
set "T_BL_M3=Unlock a BitLocker-protected drive"
set "T_BL_M4=Lock a BitLocker-protected drive"
set "T_BL_NOTAVAILABLE=BitLocker is not available on this edition of Windows."
set "T_BL_DRIVEPROMPT=Drive letter, e.g. D, blank to cancel:"
set "T_BL_SYSDRIVEBLOCK=Refusing, that is the system drive."
set "T_BL_BADDRIVE=That drive letter does not exist."
set "T_BL_ENCRYPTCONFIRM=This turns on BitLocker for drive"
set "T_BL_PWHINT=You will be asked to set and confirm a password for this drive."
set "T_BL_ENCRYPTFAIL=Could not turn on BitLocker for that drive."
set "T_BL_ENCRYPTDONE=BitLocker is turning on. Encryption continues in the background, check status from this menu to see progress."
set "T_BL_METHPW=Unlock with the drive's password"
set "T_BL_METHRECOVERY=Unlock with the 48-digit recovery key"
set "T_BL_RECOVERYPROMPT=48-digit recovery key:"
set "T_BL_UNLOCKFAIL=Unlock failed, wrong password or recovery key."
set "T_BL_UNLOCKDONE=Drive unlocked."
set "T_BL_LOCKFAIL=Could not lock that drive, files may still be open on it."
set "T_BL_LOCKDONE=Drive locked."
set "T_MON_TITLE=LIVE SYSTEM MONITOR"
set "T_MON_EXITHINT=Press any key to exit..."
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Registry Editor"
set "T_C4=Services"
set "T_C5=Event Viewer"
set "T_C6=Local Users"
set "T_C7=Group Policy"
set "T_C8=Computer Management"
set "T_C9=System Restore"
set "T_C10=Recovery Settings"
set "T_C11=Windows Security"
set "T_C12=Device Manager"
set "T_C13=Disk Management"
set "T_C14=Task Manager"
set "T_C15=Task Scheduler"
set "T_C16=System Configuration"
set "T_C17=Control Panel"
set "T_C18=Programs and Features"
set "T_C19=Windows Firewall"
set "T_C20=Resource Monitor"
set "T_C_USERSWARN=Local Users console is not available on Windows Home. Opening User Accounts instead."
set "T_C_GPWARN=Group Policy Editor is not available on Windows Home editions."
set "T_S1=Quick system summary"
set "T_S2=Full system report"
set "T_S2D=saved to file"
set "T_S3=Battery health report"
set "T_S3D=laptops"
set "T_S4=Installed software list"
set "T_S4D=saved to file"
set "T_S5=Driver list"
set "T_S5D=saved to file"
set "T_S6=Disk health status"
set "T_S7=Recent critical errors"
set "T_S7D=last 24 hours"
set "T_S8=Windows activation status"
set "T_S_BUILDING=Building report, please wait..."
set "T_S_NOBATTERY=No battery found on this device."
set "T_S_COLLECTING=Collecting installed software..."
set "T_S_SAVED=Saved:"
set "T_R1=System File Checker"
set "T_R1D=sfc /scannow"
set "T_R2=DISM image repair"
set "T_R2D=RestoreHealth"
set "T_R3=Full repair"
set "T_R3D=DISM then SFC - recommended"
set "T_R4=Check disk - scan only"
set "T_R4D=safe, no reboot"
set "T_R5=Check disk - fix on reboot"
set "T_R6=Create a restore point"
set "T_R7=Reset Windows Update components"
set "T_R8=Update all apps"
set "T_R8D=winget"
set "T_R9=Restart Windows Explorer"
set "T_R10=Memory diagnostic"
set "T_R_MEMDIAGMISSING=Windows Memory Diagnostic - mdsched.exe - was not found on this system."
set "T_R12=Export drivers"
set "T_R12D=DISM, back up to a folder"
set "T_R13=Import drivers from a folder"
set "T_R13D=pnputil, install for this PC"
set "T_R_DRVEXPORTING=Exporting drivers, please wait..."
set "T_R_DRVEXPORTDONE=Drivers exported to:"
set "T_R_DRVDESTDEFAULT=Default location - TechToolkit_Reports"
set "T_R_DRVDESTCUSTOM=Choose a custom folder"
set "T_R_DRVDESTSCRIPT=Same folder as this script - handy when running from USB"
set "T_R_DRVDESTPROMPT=Destination folder:"
set "T_R_DRVIMPORTPROMPT=Folder with exported drivers:"
set "T_R_DRVPATHNOTFOUND=That folder was not found."
set "T_R_DRVIMPORTCONFIRM=This installs every driver found in that folder for matching hardware on this PC. Continue?"
set "T_R_DRVIMPORTING=Importing and installing drivers, please wait..."
set "T_R_DRVIMPORTDONE=Drivers imported. Check Device Manager if anything still needs a manual install."
set "T_R14=Refresh all drivers"
set "T_R14D=export and reinstall in one step"
set "T_R_DRVREFRESHCONFIRM=This re-exports and reinstalls every driver currently on this PC. It can take a few minutes and will not remove any hardware. Continue?"
set "T_R_DRVREFRESHDONE=Drivers refreshed. Restart the PC if any device still looks off."
set "T_R11=Open Windows Update"
set "T_R_STEP1=Step 1 of 2: DISM..."
set "T_R_STEP2=Step 2 of 2: SFC..."
set "T_R_FULLDONE=Full repair finished. A restart is recommended."
set "T_R_CHKFIXCONFIRM=CHKDSK will run on the system drive at next restart and may take a while."
set "T_R_WUCONFIRM=This stops update services and clears the Windows Update cache."
set "T_R_WUDONE=Windows Update components reset. Restart, then check for updates."
set "T_R_WINGETMISSING=winget is not installed. Get App Installer from the Microsoft Store."
set "T_R_WINGETCONFIRM=Install all the updates listed above?"
set "T_R_EXPLORERDONE=Explorer restarted."
set "T_N1=Quick connection diagnosis"
set "T_N2=Show IP configuration"
set "T_N3=Show public IP address"
set "T_N4=Flush DNS cache"
set "T_N5=Release and renew IP"
set "T_N6=Ping a host"
set "T_N7=Trace route to a host"
set "T_N8=Saved Wi-Fi networks"
set "T_N9=Active connections"
set "T_N9D=saved to file"
set "T_N10=Open Network Adapters"
set "T_N11=Full network reset"
set "T_N11D=needs restart"
set "T_N12=Show saved Wi-Fi passwords"
set "T_N13=Internet speed test"
set "T_N13D=download, upload, ping"
set "T_N_WIFIGATHERING=Reading saved Wi-Fi profiles..."
set "T_N_WIFINOPASS=No password stored / open network"
set "T_N_SPEEDCONFIRM=This installs Ookla's official Speedtest CLI, about 15 MB, via winget, then runs a real speed test. Continue?"
set "T_N_SPEEDINSTALLING=Installing Speedtest CLI, one-time via winget..."
set "T_N_SPEEDRETRY=Installed. Please close and reopen this toolkit, then run the speed test again."
set "T_N_SPEEDRUNNING=Running speed test..."
set "T_N14=Configure IP address"
set "T_N14D=DHCP or manual static IP"
set "T_N_ADAPTERPROMPT=Adapter name, exactly as shown above:"
set "T_N_DHCP=Automatic, DHCP"
set "T_N_STATIC=Manual, static IP"
set "T_N_DHCPCONFIRM=This switches the adapter back to automatic addressing. Continue?"
set "T_N_IPAPPLYING=Applying network settings..."
set "T_N_IPDONE=Done."
set "T_N_IPPROMPT=IP address:"
set "T_N_MASKPROMPT=Subnet mask, e.g. 255.255.255.0, or a prefix like /24:"
set "T_N_GWPROMPT=Default gateway:"
set "T_N_MACPROMPT=MAC address, 12 hex characters with or without : or - , e.g. 00:11:22:33:44:55 , or press Enter to leave it as is:"
set "T_N_MACINVALID=That is not a valid MAC address, so it was skipped. The IP settings above were still applied."
set "T_N_MACDONE=MAC address changed. The adapter was restarted to apply it."
set "T_N_STATICCONFIRM=This sets a static IP address on that adapter:"
set "T_N_ROUTEROK=Router reachable -"
set "T_N_ROUTERFAIL=Router not responding -"
set "T_N_NOGATEWAY=No default gateway - check cable or Wi-Fi"
set "T_N_INETOK=Internet reachable"
set "T_N_INETFAIL=Internet not reachable"
set "T_N_DNSOK=DNS resolving names"
set "T_N_DNSFAIL=DNS not working - try Flush DNS or Network reset"
set "T_N_RENEWCONFIRM=Your connection will drop for a few seconds."
set "T_N_PINGPROMPT=Host or IP to ping:"
set "T_N_TRACEPROMPT=Host or IP to trace:"
set "T_N_RESETCONFIRM=This resets Winsock and TCP/IP. VPN and custom network settings may need to be set up again."
set "T_N_RESETDONE=Done. Please restart your computer to finish."
set "T_L1=Clear my temp files"
set "T_L2=Clear Windows temp files"
set "T_L3=Empty Recycle Bin"
set "T_L4=Disk Cleanup"
set "T_L5=Component store cleanup"
set "T_L5D=DISM, frees update leftovers"
set "T_L6=Storage Sense settings"
set "T_L_USERTEMPCONFIRM=Delete temporary files in your Temp folder? Files in use will be skipped."
set "T_L_WINTEMPCONFIRM=Delete files in the Windows Temp folder? Files in use will be skipped."
set "T_L_BINCONFIRM=Permanently delete everything in the Recycle Bin?"
set "T_P1=Restart into BIOS / UEFI"
set "T_P2=Restart into Advanced Startup"
set "T_P3=Boot into Safe Mode next restart"
set "T_P4=Turn OFF Safe Mode boot"
set "T_P5=Startup apps"
set "T_P6=Power plans"
set "T_P7=Restart now"
set "T_P8=Shut down now"
set "T_P_BIOSCONFIRM=Save your work. The PC will restart into firmware settings."
set "T_P_BIOSFAIL=This PC does not support restarting into firmware from Windows."
set "T_P_ADVCONFIRM=Save your work. The PC will restart into Advanced Startup."
set "T_P_SAFEONCONFIRM=The PC will boot into Safe Mode until you turn it off with option 4."
set "T_P_SAFEONNOTE=Remember: run this toolkit in Safe Mode and choose option 4 to go back to normal."
set "T_P_RESTARTCONFIRM=Restart the computer now?"
set "T_P_SHUTDOWNCONFIRM=Shut down the computer now?"
exit /b

:Lang_DE
set "T_SELECT=Option waehlen:"
set "T_BACK=Zurueck"
set "T_EXIT=Beenden"
set "T_INVALID=Ungueltige Option, bitte erneut versuchen."
set "T_GOODBYE=Auf Wiedersehen!"
set "T_DONE=Fertig."
set "T_CANCELLED=Abgebrochen."
set "T_WARNING=WARNUNG:"
set "T_TYPEYES=Geben Sie YES ein, um fortzufahren:"
set "T_LAUNCHED=Gestartet."
set "T_PC=PC:"
set "T_USER=Benutzer:"
set "T_REQADMIN=Administratorrechte werden angefordert..."
set "T_POWEREDBY=Bereitgestellt von BASHAR SALMO"
set "T_H_MAIN=HAUPTMENUE"
set "T_H_CONSOLES=ADMIN-KONSOLEN"
set "T_H_SYSINFO=SYSTEMINFO UND BERICHTE"
set "T_H_QUICK=SCHNELLE SYSTEMUEBERSICHT"
set "T_H_DISK=DATENTRAEGERZUSTAND"
set "T_H_ERRORS=KRITISCHE EREIGNISSE UND FEHLER - LETZTE 24 STUNDEN"
set "T_H_LICENSE=AKTIVIERUNGSSTATUS"
set "T_H_REPAIR=REPARATUR UND WARTUNG"
set "T_H_NETWORK=NETZWERKTOOLS"
set "T_H_NETDIAG=VERBINDUNGSDIAGNOSE"
set "T_H_CLEANUP=BEREINIGUNG"
set "T_H_POWER=ENERGIE UND START"
set "T_M1=Admin-Konsolen"
set "T_M1D=CMD, PowerShell, Registrierung, Dienste..."
set "T_M2=Systeminfo und Berichte"
set "T_M2D=Uebersicht, Akku, Treiber, Fehler"
set "T_M3=Reparatur und Wartung"
set "T_M3D=SFC, DISM, CHKDSK, Windows Update-Reparatur"
set "T_M4=Netzwerktools"
set "T_M4D=Diagnose, DNS, IP, WLAN, Zuruecksetzen"
set "T_M5=Bereinigung"
set "T_M5D=Temp-Dateien, Datentraegerbereinigung, Komponentenspeicher"
set "T_M6=Energie und Start"
set "T_M6D=BIOS, Erweiterter Start, Abgesicherter Modus"
set "T_M7=Berichtsordner oeffnen"
set "T_M8=Nach Toolkit-Updates suchen"
set "T_U_CHECKING=GitHub wird auf eine neuere Version geprueft..."
set "T_U_UNREACHABLE=GitHub konnte nicht erreicht werden. Pruefen Sie Ihre Internetverbindung."
set "T_U_NOVERSION=Aus der heruntergeladenen Datei konnte keine Versionsnummer gelesen werden."
set "T_U_INSTALLED=Installiert"
set "T_U_LATEST=Neueste Version auf GitHub"
set "T_U_UPTODATE=Sie verwenden bereits die neueste Version."
set "T_U_AVAILABLE=Eine neuere Version ist verfuegbar. Jetzt installieren?"
set "T_U_SANITYFAIL=Die heruntergeladene Datei hat die Sicherheitspruefung nicht bestanden, es wurde nichts geaendert."
set "T_U_UPDATING=Update wird installiert. Das Toolkit startet gleich in einem neuen Fenster neu..."
set "T_M9=BitLocker-Laufwerksverschluesselung"
set "T_H_BITLOCKER=BITLOCKER-LAUFWERKSVERSCHLUESSELUNG"
set "T_BL_M1=BitLocker-Status anzeigen"
set "T_BL_M2=BitLocker fuer ein Laufwerk aktivieren"
set "T_BL_M3=Ein BitLocker-geschuetztes Laufwerk entsperren"
set "T_BL_M4=Ein BitLocker-geschuetztes Laufwerk sperren"
set "T_BL_NOTAVAILABLE=BitLocker ist in dieser Windows-Edition nicht verfuegbar."
set "T_BL_DRIVEPROMPT=Laufwerksbuchstabe, z. B. D, leer lassen zum Abbrechen:"
set "T_BL_SYSDRIVEBLOCK=Abgelehnt, das ist das Systemlaufwerk."
set "T_BL_BADDRIVE=Diesen Laufwerksbuchstaben gibt es nicht."
set "T_BL_ENCRYPTCONFIRM=Dies aktiviert BitLocker fuer Laufwerk"
set "T_BL_PWHINT=Sie werden gebeten, ein Passwort fuer dieses Laufwerk festzulegen und zu bestaetigen."
set "T_BL_ENCRYPTFAIL=BitLocker konnte fuer dieses Laufwerk nicht aktiviert werden."
set "T_BL_ENCRYPTDONE=BitLocker wird aktiviert. Die Verschluesselung laeuft im Hintergrund weiter, den Fortschritt sehen Sie im Status in diesem Menue."
set "T_BL_METHPW=Mit dem Passwort des Laufwerks entsperren"
set "T_BL_METHRECOVERY=Mit dem 48-stelligen Wiederherstellungsschluessel entsperren"
set "T_BL_RECOVERYPROMPT=48-stelliger Wiederherstellungsschluessel:"
set "T_BL_UNLOCKFAIL=Entsperren fehlgeschlagen, falsches Passwort oder falscher Wiederherstellungsschluessel."
set "T_BL_UNLOCKDONE=Laufwerk entsperrt."
set "T_BL_LOCKFAIL=Laufwerk konnte nicht gesperrt werden, moeglicherweise sind noch Dateien darauf geoeffnet."
set "T_BL_LOCKDONE=Laufwerk gesperrt."
set "T_MON_TITLE=LIVE-SYSTEMMONITOR"
set "T_MON_EXITHINT=Beliebige Taste druecken zum Beenden..."
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Registrierungs-Editor"
set "T_C4=Dienste"
set "T_C5=Ereignisanzeige"
set "T_C6=Lokale Benutzer"
set "T_C7=Gruppenrichtlinie"
set "T_C8=Computerverwaltung"
set "T_C9=Systemwiederherstellung"
set "T_C10=Wiederherstellungseinstellungen"
set "T_C11=Windows-Sicherheit"
set "T_C12=Geraete-Manager"
set "T_C13=Datentraegerverwaltung"
set "T_C14=Task-Manager"
set "T_C15=Aufgabenplanung"
set "T_C16=Systemkonfiguration"
set "T_C17=Systemsteuerung"
set "T_C18=Programme und Features"
set "T_C19=Windows-Firewall"
set "T_C20=Ressourcenmonitor"
set "T_C_USERSWARN=Die Konsole 'Lokale Benutzer' ist unter Windows Home nicht verfuegbar. Stattdessen werden die Benutzerkonten geoeffnet."
set "T_C_GPWARN=Der Gruppenrichtlinien-Editor ist in Windows Home-Editionen nicht verfuegbar."
set "T_S1=Schnelle Systemuebersicht"
set "T_S2=Vollstaendiger Systembericht"
set "T_S2D=wird in Datei gespeichert"
set "T_S3=Akku-Zustandsbericht"
set "T_S3D=Laptops"
set "T_S4=Liste installierter Software"
set "T_S4D=wird in Datei gespeichert"
set "T_S5=Treiberliste"
set "T_S5D=wird in Datei gespeichert"
set "T_S6=Datentraeger-Zustand"
set "T_S7=Aktuelle kritische Fehler"
set "T_S7D=letzte 24 Stunden"
set "T_S8=Windows-Aktivierungsstatus"
set "T_S_BUILDING=Bericht wird erstellt, bitte warten..."
set "T_S_NOBATTERY=Auf diesem Geraet wurde kein Akku gefunden."
set "T_S_COLLECTING=Installierte Software wird erfasst..."
set "T_S_SAVED=Gespeichert:"
set "T_R1=Systemdateipruefung"
set "T_R1D=sfc /scannow"
set "T_R2=DISM-Image-Reparatur"
set "T_R2D=RestoreHealth"
set "T_R3=Vollstaendige Reparatur"
set "T_R3D=DISM, dann SFC - empfohlen"
set "T_R4=Datentraegerpruefung - nur Scan"
set "T_R4D=sicher, kein Neustart"
set "T_R5=Datentraegerpruefung - Reparatur beim Neustart"
set "T_R6=Wiederherstellungspunkt erstellen"
set "T_R7=Windows Update-Komponenten zuruecksetzen"
set "T_R8=Alle Apps aktualisieren"
set "T_R8D=winget"
set "T_R9=Windows-Explorer neu starten"
set "T_R10=Speicherdiagnose"
set "T_R_MEMDIAGMISSING=Windows-Speicherdiagnose - mdsched.exe - wurde auf diesem System nicht gefunden."
set "T_R12=Treiber exportieren"
set "T_R12D=DISM, Sicherung in einen Ordner"
set "T_R13=Treiber aus einem Ordner importieren"
set "T_R13D=pnputil, installiert fuer diesen PC"
set "T_R_DRVEXPORTING=Treiber werden exportiert, bitte warten..."
set "T_R_DRVEXPORTDONE=Treiber exportiert nach:"
set "T_R_DRVDESTDEFAULT=Standardordner - TechToolkit_Reports"
set "T_R_DRVDESTCUSTOM=Eigenen Ordner waehlen"
set "T_R_DRVDESTSCRIPT=Gleicher Ordner wie dieses Skript - praktisch bei einem USB-Stick"
set "T_R_DRVDESTPROMPT=Zielordner:"
set "T_R_DRVIMPORTPROMPT=Ordner mit den exportierten Treibern:"
set "T_R_DRVPATHNOTFOUND=Dieser Ordner wurde nicht gefunden."
set "T_R_DRVIMPORTCONFIRM=Dies installiert jeden in diesem Ordner gefundenen Treiber fuer passende Hardware auf diesem PC. Fortfahren?"
set "T_R_DRVIMPORTING=Treiber werden importiert und installiert, bitte warten..."
set "T_R_DRVIMPORTDONE=Treiber importiert. Pruefen Sie den Geraete-Manager, falls noch etwas manuell installiert werden muss."
set "T_R14=Alle Treiber auffrischen"
set "T_R14D=Export und Neuinstallation in einem Schritt"
set "T_R_DRVREFRESHCONFIRM=Dies exportiert und installiert jeden derzeit auf diesem PC vorhandenen Treiber neu. Es kann einige Minuten dauern und entfernt keine Hardware. Fortfahren?"
set "T_R_DRVREFRESHDONE=Treiber aufgefrischt. Starten Sie den PC neu, falls ein Geraet noch immer nicht richtig funktioniert."
set "T_R11=Windows Update oeffnen"
set "T_R_STEP1=Schritt 1 von 2: DISM..."
set "T_R_STEP2=Schritt 2 von 2: SFC..."
set "T_R_FULLDONE=Vollstaendige Reparatur abgeschlossen. Ein Neustart wird empfohlen."
set "T_R_CHKFIXCONFIRM=CHKDSK wird beim naechsten Neustart auf dem Systemlaufwerk ausgefuehrt und kann eine Weile dauern."
set "T_R_WUCONFIRM=Dies stoppt die Update-Dienste und leert den Windows Update-Cache."
set "T_R_WUDONE=Windows Update-Komponenten wurden zurueckgesetzt. Starten Sie neu und suchen Sie dann nach Updates."
set "T_R_WINGETMISSING=winget ist nicht installiert. Laden Sie App Installer aus dem Microsoft Store herunter."
set "T_R_WINGETCONFIRM=Sollen alle oben aufgefuehrten Updates installiert werden?"
set "T_R_EXPLORERDONE=Explorer wurde neu gestartet."
set "T_N1=Schnelle Verbindungsdiagnose"
set "T_N2=IP-Konfiguration anzeigen"
set "T_N3=Oeffentliche IP-Adresse anzeigen"
set "T_N4=DNS-Cache leeren"
set "T_N5=IP freigeben und erneuern"
set "T_N6=Host anpingen"
set "T_N7=Route zu einem Host verfolgen"
set "T_N8=Gespeicherte WLAN-Netzwerke"
set "T_N9=Aktive Verbindungen"
set "T_N9D=wird in Datei gespeichert"
set "T_N10=Netzwerkadapter oeffnen"
set "T_N11=Vollstaendiges Netzwerk-Reset"
set "T_N11D=erfordert Neustart"
set "T_N12=Gespeicherte WLAN-Passwoerter anzeigen"
set "T_N13=Internet-Geschwindigkeitstest"
set "T_N13D=Download, Upload, Ping"
set "T_N_WIFIGATHERING=Gespeicherte WLAN-Profile werden gelesen..."
set "T_N_WIFINOPASS=Kein Passwort gespeichert / offenes Netzwerk"
set "T_N_SPEEDCONFIRM=Dies installiert Ooklas offizielle Speedtest-CLI, etwa 15 MB, ueber winget, und fuehrt dann einen echten Geschwindigkeitstest durch. Fortfahren?"
set "T_N_SPEEDINSTALLING=Speedtest-CLI wird installiert, einmalig ueber winget..."
set "T_N_SPEEDRETRY=Installiert. Bitte schliessen Sie dieses Toolkit und starten Sie es erneut, dann fuehren Sie den Geschwindigkeitstest noch einmal aus."
set "T_N_SPEEDRUNNING=Geschwindigkeitstest laeuft..."
set "T_N14=IP-Adresse konfigurieren"
set "T_N14D=DHCP oder manuelle statische IP"
set "T_N_ADAPTERPROMPT=Adaptername, genau wie oben angezeigt:"
set "T_N_DHCP=Automatisch, DHCP"
set "T_N_STATIC=Manuell, statische IP"
set "T_N_DHCPCONFIRM=Dies stellt den Adapter zurueck auf automatische Adressierung. Fortfahren?"
set "T_N_IPAPPLYING=Netzwerkeinstellungen werden angewendet..."
set "T_N_IPDONE=Fertig."
set "T_N_IPPROMPT=IP-Adresse:"
set "T_N_MASKPROMPT=Subnetzmaske, z. B. 255.255.255.0, oder ein Prefix wie /24:"
set "T_N_GWPROMPT=Standardgateway:"
set "T_N_MACPROMPT=MAC-Adresse, 12 Hexadezimalzeichen mit oder ohne : oder - , z. B. 00:11:22:33:44:55 , oder Eingabetaste druecken, um sie unveraendert zu lassen:"
set "T_N_MACINVALID=Das ist keine gueltige MAC-Adresse, sie wurde uebersprungen. Die obigen IP-Einstellungen wurden trotzdem angewendet."
set "T_N_MACDONE=MAC-Adresse geaendert. Der Adapter wurde neu gestartet, um sie zu uebernehmen."
set "T_N_STATICCONFIRM=Dies setzt eine statische IP-Adresse auf diesem Adapter:"
set "T_N_ROUTEROK=Router erreichbar -"
set "T_N_ROUTERFAIL=Router antwortet nicht -"
set "T_N_NOGATEWAY=Kein Standardgateway - Kabel oder WLAN pruefen"
set "T_N_INETOK=Internet erreichbar"
set "T_N_INETFAIL=Internet nicht erreichbar"
set "T_N_DNSOK=DNS loest Namen auf"
set "T_N_DNSFAIL=DNS funktioniert nicht - versuchen Sie DNS leeren oder Netzwerk-Reset"
set "T_N_RENEWCONFIRM=Ihre Verbindung wird fuer einige Sekunden unterbrochen."
set "T_N_PINGPROMPT=Host oder IP zum Anpingen:"
set "T_N_TRACEPROMPT=Host oder IP zum Verfolgen:"
set "T_N_RESETCONFIRM=Dies setzt Winsock und TCP/IP zurueck. VPN- und benutzerdefinierte Netzwerkeinstellungen muessen eventuell neu eingerichtet werden."
set "T_N_RESETDONE=Fertig. Bitte starten Sie Ihren Computer neu, um den Vorgang abzuschliessen."
set "T_L1=Meine Temp-Dateien loeschen"
set "T_L2=Windows-Temp-Dateien loeschen"
set "T_L3=Papierkorb leeren"
set "T_L4=Datentraegerbereinigung"
set "T_L5=Komponentenspeicher-Bereinigung"
set "T_L5D=DISM, gibt Update-Reste frei"
set "T_L6=Speicheroptimierung-Einstellungen"
set "T_L_USERTEMPCONFIRM=Temporaere Dateien in Ihrem Temp-Ordner loeschen? Dateien in Verwendung werden uebersprungen."
set "T_L_WINTEMPCONFIRM=Dateien im Windows-Temp-Ordner loeschen? Dateien in Verwendung werden uebersprungen."
set "T_L_BINCONFIRM=Alles im Papierkorb endgueltig loeschen?"
set "T_P1=Neustart ins BIOS / UEFI"
set "T_P2=Neustart in erweiterten Start"
set "T_P3=Beim naechsten Neustart in den abgesicherten Modus starten"
set "T_P4=Abgesicherten-Modus-Start ausschalten"
set "T_P5=Autostart-Apps"
set "T_P6=Energiesparplaene"
set "T_P7=Jetzt neu starten"
set "T_P8=Jetzt herunterfahren"
set "T_P_BIOSCONFIRM=Speichern Sie Ihre Arbeit. Der PC wird in die Firmware-Einstellungen neu gestartet."
set "T_P_BIOSFAIL=Dieser PC unterstuetzt keinen Neustart in die Firmware aus Windows heraus."
set "T_P_ADVCONFIRM=Speichern Sie Ihre Arbeit. Der PC wird in den erweiterten Start neu gestartet."
set "T_P_SAFEONCONFIRM=Der PC startet im abgesicherten Modus, bis Sie diesen mit Option 4 wieder ausschalten."
set "T_P_SAFEONNOTE=Hinweis: Fuehren Sie dieses Toolkit im abgesicherten Modus aus und waehlen Sie Option 4, um zum Normalmodus zurueckzukehren."
set "T_P_RESTARTCONFIRM=Computer jetzt neu starten?"
set "T_P_SHUTDOWNCONFIRM=Computer jetzt herunterfahren?"
exit /b

:Lang_TR
set "T_SELECT=Secenek secin:"
set "T_BACK=Geri"
set "T_EXIT=Cikis"
set "T_INVALID=Gecersiz secenek, tekrar deneyin."
set "T_GOODBYE=Hosca kalin!"
set "T_DONE=Tamamlandi."
set "T_CANCELLED=Iptal edildi."
set "T_WARNING=UYARI:"
set "T_TYPEYES=Devam etmek icin YES yazin:"
set "T_LAUNCHED=Baslatildi."
set "T_PC=PC:"
set "T_USER=Kullanici:"
set "T_REQADMIN=Yonetici izinleri isteniyor..."
set "T_POWEREDBY=BASHAR SALMO tarafindan gelistirildi"
set "T_H_MAIN=ANA MENU"
set "T_H_CONSOLES=YONETIM KONSOLLARI"
set "T_H_SYSINFO=SISTEM BILGISI VE RAPORLAR"
set "T_H_QUICK=HIZLI SISTEM OZETI"
set "T_H_DISK=DISK SAGLIGI"
set "T_H_ERRORS=KRITIK VE HATA OLAYLARI - SON 24 SAAT"
set "T_H_LICENSE=ETKINLESTIRME DURUMU"
set "T_H_REPAIR=ONARIM VE BAKIM"
set "T_H_NETWORK=AG ARACLARI"
set "T_H_NETDIAG=BAGLANTI TANILAMA"
set "T_H_CLEANUP=TEMIZLIK"
set "T_H_POWER=GUC VE ONYUKLEME"
set "T_M1=Yonetim Konsollari"
set "T_M1D=CMD, PowerShell, Kayit Defteri, Hizmetler..."
set "T_M2=Sistem Bilgisi ve Raporlar"
set "T_M2D=Ozet, pil, suruculer, hatalar"
set "T_M3=Onarim ve Bakim"
set "T_M3D=SFC, DISM, CHKDSK, Windows Update onarimi"
set "T_M4=Ag Araclari"
set "T_M4D=Tanilama, DNS, IP, Wi-Fi, sifirlama"
set "T_M5=Temizlik"
set "T_M5D=Gecici dosyalar, Disk Temizleme, bilesen deposu"
set "T_M6=Guc ve Onyukleme"
set "T_M6D=BIOS, Gelismis Baslangic, Guvenli Mod"
set "T_M7=Raporlar Klasorunu Ac"
set "T_M8=Arac Seti Guncellemelerini Kontrol Et"
set "T_U_CHECKING=Daha yeni bir surum icin GitHub kontrol ediliyor..."
set "T_U_UNREACHABLE=GitHub'a ulasilamadi. Internet baglantinizi kontrol edin."
set "T_U_NOVERSION=Indirilen dosyadan bir surum numarasi okunamadi."
set "T_U_INSTALLED=Yuklu"
set "T_U_LATEST=GitHub'daki en son surum"
set "T_U_UPTODATE=Zaten en son surumu kullaniyorsunuz."
set "T_U_AVAILABLE=Daha yeni bir surum mevcut. Simdi yuklensin mi?"
set "T_U_SANITYFAIL=Indirilen dosya guvenlik kontrolunden gecemedi, hicbir sey degistirilmedi."
set "T_U_UPDATING=Guncelleme yukleniyor. Arac seti yeni bir pencerede yeniden baslayacak..."
set "T_M9=BitLocker Disk Sifreleme"
set "T_H_BITLOCKER=BITLOCKER DISK SIFRELEME"
set "T_BL_M1=BitLocker durumunu goster"
set "T_BL_M2=Bir surucu icin BitLocker'i etkinlestir"
set "T_BL_M3=BitLocker korumali bir surucunun kilidini ac"
set "T_BL_M4=BitLocker korumali bir surucuyu kilitle"
set "T_BL_NOTAVAILABLE=BitLocker bu Windows surumunde kullanilamaz."
set "T_BL_DRIVEPROMPT=Surucu harfi, orn. D, iptal icin bos birakin:"
set "T_BL_SYSDRIVEBLOCK=Reddedildi, bu sistem surucusu."
set "T_BL_BADDRIVE=Bu surucu harfi mevcut degil."
set "T_BL_ENCRYPTCONFIRM=Bu, su surucu icin BitLocker'i etkinlestirir"
set "T_BL_PWHINT=Bu surucu icin bir parola belirlemeniz ve onaylamaniz istenecek."
set "T_BL_ENCRYPTFAIL=Bu surucu icin BitLocker etkinlestirilemedi."
set "T_BL_ENCRYPTDONE=BitLocker etkinlestiriliyor. Sifreleme arka planda devam eder, ilerlemeyi bu menudeki durumdan kontrol edin."
set "T_BL_METHPW=Surucunun parolasiyla kilidini ac"
set "T_BL_METHRECOVERY=48 haneli kurtarma anahtariyla kilidini ac"
set "T_BL_RECOVERYPROMPT=48 haneli kurtarma anahtari:"
set "T_BL_UNLOCKFAIL=Kilit acma basarisiz, yanlis parola veya kurtarma anahtari."
set "T_BL_UNLOCKDONE=Surucunun kilidi acildi."
set "T_BL_LOCKFAIL=Surucu kilitlenemedi, uzerinde hala acik dosyalar olabilir."
set "T_BL_LOCKDONE=Surucu kilitlendi."
set "T_MON_TITLE=CANLI SISTEM IZLEYICI"
set "T_MON_EXITHINT=Cikmak icin herhangi bir tusa basin..."
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Kayit Defteri Duzenleyicisi"
set "T_C4=Hizmetler"
set "T_C5=Olay Goruntuleyici"
set "T_C6=Yerel Kullanicilar"
set "T_C7=Grup Ilkesi"
set "T_C8=Bilgisayar Yonetimi"
set "T_C9=Sistem Geri Yukleme"
set "T_C10=Kurtarma Ayarlari"
set "T_C11=Windows Guvenligi"
set "T_C12=Aygit Yoneticisi"
set "T_C13=Disk Yonetimi"
set "T_C14=Gorev Yoneticisi"
set "T_C15=Gorev Zamanlayici"
set "T_C16=Sistem Yapilandirmasi"
set "T_C17=Denetim Masasi"
set "T_C18=Programlar ve Ozellikler"
set "T_C19=Windows Guvenlik Duvari"
set "T_C20=Kaynak Izleyici"
set "T_C_USERSWARN=Yerel Kullanicilar konsolu Windows Home surumunde kullanilamaz. Bunun yerine Kullanici Hesaplari aciliyor."
set "T_C_GPWARN=Grup Ilkesi Duzenleyicisi Windows Home surumlerinde kullanilamaz."
set "T_S1=Hizli sistem ozeti"
set "T_S2=Tam sistem raporu"
set "T_S2D=dosyaya kaydedilir"
set "T_S3=Pil sagligi raporu"
set "T_S3D=dizustu bilgisayarlar"
set "T_S4=Yuklu yazilim listesi"
set "T_S4D=dosyaya kaydedilir"
set "T_S5=Surucu listesi"
set "T_S5D=dosyaya kaydedilir"
set "T_S6=Disk saglik durumu"
set "T_S7=Son kritik hatalar"
set "T_S7D=son 24 saat"
set "T_S8=Windows etkinlestirme durumu"
set "T_S_BUILDING=Rapor olusturuluyor, lutfen bekleyin..."
set "T_S_NOBATTERY=Bu cihazda pil bulunamadi."
set "T_S_COLLECTING=Yuklu yazilimlar toplaniyor..."
set "T_S_SAVED=Kaydedildi:"
set "T_R1=Sistem Dosyasi Denetleyicisi"
set "T_R1D=sfc /scannow"
set "T_R2=DISM goruntu onarimi"
set "T_R2D=RestoreHealth"
set "T_R3=Tam onarim"
set "T_R3D=Once DISM, sonra SFC - onerilir"
set "T_R4=Disk denetimi - yalnizca tarama"
set "T_R4D=guvenli, yeniden baslatma yok"
set "T_R5=Disk denetimi - yeniden baslatmada onar"
set "T_R6=Geri yukleme noktasi olustur"
set "T_R7=Windows Update bilesenlerini sifirla"
set "T_R8=Tum uygulamalari guncelle"
set "T_R8D=winget"
set "T_R9=Windows Gezgini'ni yeniden baslat"
set "T_R10=Bellek tanilamasi"
set "T_R_MEMDIAGMISSING=Windows Bellek Tanilama araci - mdsched.exe - bu sistemde bulunamadi."
set "T_R12=Suruculeri disa aktar"
set "T_R12D=DISM, bir klasore yedekle"
set "T_R13=Bir klasorden suruculeri ice aktar"
set "T_R13D=pnputil, bu PC icin yukler"
set "T_R_DRVEXPORTING=Suruculer disa aktariliyor, lutfen bekleyin..."
set "T_R_DRVEXPORTDONE=Suruculer su konuma aktarildi:"
set "T_R_DRVDESTDEFAULT=Varsayilan konum - TechToolkit_Reports"
set "T_R_DRVDESTCUSTOM=Ozel bir klasor sec"
set "T_R_DRVDESTSCRIPT=Bu betikle ayni klasor - USB'den calistirirken pratik"
set "T_R_DRVDESTPROMPT=Hedef klasor:"
set "T_R_DRVIMPORTPROMPT=Disa aktarilan suruculerin bulundugu klasor:"
set "T_R_DRVPATHNOTFOUND=Bu klasor bulunamadi."
set "T_R_DRVIMPORTCONFIRM=Bu islem, o klasorde bulunan ve bu PC'deki uyumlu donanima ait tum suruculeri yukler. Devam edilsin mi?"
set "T_R_DRVIMPORTING=Suruculer ice aktariliyor ve yukleniyor, lutfen bekleyin..."
set "T_R_DRVIMPORTDONE=Suruculer ice aktarildi. Hala manuel yukleme gerektiren bir sey varsa Aygit Yoneticisi'ni kontrol edin."
set "T_R14=Tum suruculeri yenile"
set "T_R14D=tek adimda disa aktar ve yeniden yukle"
set "T_R_DRVREFRESHCONFIRM=Bu islem, bu PC'de su anda bulunan her suruculeru yeniden disa aktarir ve yeniden yukler. Birkac dakika surebilir ve hicbir donanimi kaldirmaz. Devam edilsin mi?"
set "T_R_DRVREFRESHDONE=Suruculer yenilendi. Herhangi bir cihaz hala sorunlu gorunuyorsa PC'yi yeniden baslatin."
set "T_R11=Windows Update'i ac"
set "T_R_STEP1=Adim 1/2: DISM..."
set "T_R_STEP2=Adim 2/2: SFC..."
set "T_R_FULLDONE=Tam onarim tamamlandi. Yeniden baslatma onerilir."
set "T_R_CHKFIXCONFIRM=CHKDSK bir sonraki yeniden baslatmada sistem surucusunde calisacak ve biraz zaman alabilir."
set "T_R_WUCONFIRM=Bu, guncelleme hizmetlerini durdurur ve Windows Update onbellegini temizler."
set "T_R_WUDONE=Windows Update bilesenleri sifirlandi. Yeniden baslatin, ardindan guncellemeleri denetleyin."
set "T_R_WINGETMISSING=winget yuklu degil. Microsoft Store'dan App Installer'i edinin."
set "T_R_WINGETCONFIRM=Yukarida listelenen tum guncellemeler yuklensin mi?"
set "T_R_EXPLORERDONE=Gezgin yeniden baslatildi."
set "T_N1=Hizli baglanti tanilamasi"
set "T_N2=IP yapilandirmasini goster"
set "T_N3=Genel IP adresini goster"
set "T_N4=DNS onbellegini temizle"
set "T_N5=IP'yi serbest birak ve yenile"
set "T_N6=Bir sunucuyu ping'le"
set "T_N7=Bir sunucuya rota izle"
set "T_N8=Kayitli Wi-Fi aglari"
set "T_N9=Etkin baglantilar"
set "T_N9D=dosyaya kaydedilir"
set "T_N10=Ag Bagdastiricilarini Ac"
set "T_N11=Tam ag sifirlama"
set "T_N11D=yeniden baslatma gerektirir"
set "T_N12=Kayitli Wi-Fi sifrelerini goster"
set "T_N13=Internet hiz testi"
set "T_N13D=indirme, yukleme, ping"
set "T_N_WIFIGATHERING=Kayitli Wi-Fi profilleri okunuyor..."
set "T_N_WIFINOPASS=Sifre kayitli degil / acik ag"
set "T_N_SPEEDCONFIRM=Bu islem, winget araciligiyla Ookla'nin resmi Speedtest CLI aracini, yaklasik 15 MB, yukler ve ardindan gercek bir hiz testi calistirir. Devam edilsin mi?"
set "T_N_SPEEDINSTALLING=Speedtest CLI yukleniyor, winget araciligiyla tek seferlik..."
set "T_N_SPEEDRETRY=Yuklendi. Lutfen bu arac setini kapatip yeniden acin, ardindan hiz testini tekrar calistirin."
set "T_N_SPEEDRUNNING=Hiz testi calisiyor..."
set "T_N14=IP adresini yapilandir"
set "T_N14D=DHCP veya manuel statik IP"
set "T_N_ADAPTERPROMPT=Adaptor adi, yukarida gosterildigi gibi:"
set "T_N_DHCP=Otomatik, DHCP"
set "T_N_STATIC=Manuel, statik IP"
set "T_N_DHCPCONFIRM=Bu islem, adaptoru otomatik adreslemeye geri dondurur. Devam edilsin mi?"
set "T_N_IPAPPLYING=Ag ayarlari uygulaniyor..."
set "T_N_IPDONE=Tamamlandi."
set "T_N_IPPROMPT=IP adresi:"
set "T_N_MASKPROMPT=Alt ag maskesi, orn. 255.255.255.0, veya /24 gibi bir prefix:"
set "T_N_GWPROMPT=Varsayilan ag gecidi:"
set "T_N_MACPROMPT=MAC adresi, : veya - ile veya onlarsiz 12 onaltilik karakter, orn. 00:11:22:33:44:55 , veya degistirmeden birakmak icin Enter'a basin:"
set "T_N_MACINVALID=Bu gecerli bir MAC adresi degil, bu yuzden atlandi. Yukaridaki IP ayarlari yine de uygulandi."
set "T_N_MACDONE=MAC adresi degistirildi. Uygulamak icin adaptor yeniden baslatildi."
set "T_N_STATICCONFIRM=Bu islem, bu adaptorde statik bir IP adresi ayarlar:"
set "T_N_ROUTEROK=Yonlendiriciye ulasilabiliyor -"
set "T_N_ROUTERFAIL=Yonlendirici yanit vermiyor -"
set "T_N_NOGATEWAY=Varsayilan ag gecidi yok - kabloyu veya Wi-Fi'yi kontrol edin"
set "T_N_INETOK=Internete ulasilabiliyor"
set "T_N_INETFAIL=Internete ulasilamiyor"
set "T_N_DNSOK=DNS isimleri cozumluyor"
set "T_N_DNSFAIL=DNS calismiyor - DNS Temizleme veya Ag Sifirlama deneyin"
set "T_N_RENEWCONFIRM=Baglantiniz birkac saniyeligine kesilecek."
set "T_N_PINGPROMPT=Ping atilacak sunucu veya IP:"
set "T_N_TRACEPROMPT=Izlenecek sunucu veya IP:"
set "T_N_RESETCONFIRM=Bu, Winsock ve TCP/IP'yi sifirlar. VPN ve ozel ag ayarlarinin yeniden yapilandirilmasi gerekebilir."
set "T_N_RESETDONE=Tamamlandi. Islemi bitirmek icin lutfen bilgisayarinizi yeniden baslatin."
set "T_L1=Gecici dosyalarimi temizle"
set "T_L2=Windows gecici dosyalarini temizle"
set "T_L3=Geri Donusum Kutusunu bosalt"
set "T_L4=Disk Temizleme"
set "T_L5=Bilesen deposu temizligi"
set "T_L5D=DISM, guncelleme artiklarini temizler"
set "T_L6=Depolama Duyarliligi ayarlari"
set "T_L_USERTEMPCONFIRM=Temp klasorunuzdeki gecici dosyalar silinsin mi? Kullanimda olan dosyalar atlanacaktir."
set "T_L_WINTEMPCONFIRM=Windows Temp klasorundeki dosyalar silinsin mi? Kullanimda olan dosyalar atlanacaktir."
set "T_L_BINCONFIRM=Geri Donusum Kutusundaki her sey kalici olarak silinsin mi?"
set "T_P1=BIOS / UEFI'ye yeniden baslat"
set "T_P2=Gelismis Baslangic'a yeniden baslat"
set "T_P3=Bir sonraki yeniden baslatmada Guvenli Mod'a gir"
set "T_P4=Guvenli Mod onyuklemesini kapat"
set "T_P5=Baslangic uygulamalari"
set "T_P6=Guc planlari"
set "T_P7=Simdi yeniden baslat"
set "T_P8=Simdi kapat"
set "T_P_BIOSCONFIRM=Calismanizi kaydedin. Bilgisayar urun yazilimi ayarlarina yeniden baslatilacak."
set "T_P_BIOSFAIL=Bu bilgisayar Windows'tan urun yazilimina yeniden baslatmayi desteklemiyor."
set "T_P_ADVCONFIRM=Calismanizi kaydedin. Bilgisayar Gelismis Baslangic'a yeniden baslatilacak."
set "T_P_SAFEONCONFIRM=Bilgisayar, siz secenek 4 ile kapatana kadar Guvenli Mod'da acilacak."
set "T_P_SAFEONNOTE=Unutmayin: Normal moda donmek icin bu arac setini Guvenli Mod'da calistirin ve secenek 4'u secin."
set "T_P_RESTARTCONFIRM=Bilgisayar simdi yeniden baslatilsin mi?"
set "T_P_SHUTDOWNCONFIRM=Bilgisayar simdi kapatilsin mi?"
exit /b

:: ============================================================
:VerGt
:: %1 = version a, %2 = version b -- exit /b 0 if a is greater, else exit /b 1
set "A1=" & set "A2=" & set "A3="
set "B1=" & set "B2=" & set "B3="
for /f "tokens=1,2,3 delims=." %%a in ("%~1") do (
    set "A1=%%a" & set "A2=%%b" & set "A3=%%c"
)
for /f "tokens=1,2,3 delims=." %%a in ("%~2") do (
    set "B1=%%a" & set "B2=%%b" & set "B3=%%c"
)
if not defined A1 set "A1=0"
if not defined A2 set "A2=0"
if not defined A3 set "A3=0"
if not defined B1 set "B1=0"
if not defined B2 set "B2=0"
if not defined B3 set "B3=0"
if %A1% gtr %B1% exit /b 0
if %A1% lss %B1% exit /b 1
if %A2% gtr %B2% exit /b 0
if %A2% lss %B2% exit /b 1
if %A3% gtr %B3% exit /b 0
exit /b 1

:CheckUpdate
call :header "%T_M8%"
echo %D% %T_U_CHECKING%%N%
set "UPDFILE=%TEMP%\ttk_update_%RANDOM%.bat"
if exist "%UPDFILE%" del /f /q "%UPDFILE%" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/%GITHUB_REPO%/main/%GITHUB_FILE%' -OutFile '%UPDFILE%' -TimeoutSec 15 -ErrorAction Stop; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    echo %R% %T_U_UNREACHABLE%%N%
    del /f /q "%UPDFILE%" >nul 2>&1
    pause
    goto main
)
set "REMOTEVER="
for /f "usebackq delims=" %%v in (`powershell -NoProfile -Command "$m = Select-String -Path '%UPDFILE%' -Pattern 'TOOLKIT_VERSION=([0-9]+\.[0-9]+\.[0-9]+).' -List; if ($m) { $m.Matches[0].Groups[1].Value }"`) do set "REMOTEVER=%%v"
if not defined REMOTEVER (
    echo %R% %T_U_NOVERSION%%N%
    del /f /q "%UPDFILE%" >nul 2>&1
    pause
    goto main
)
echo  %T_U_INSTALLED%: %TOOLKIT_VERSION%
echo  %T_U_LATEST%: %REMOTEVER%
call :VerGt "%REMOTEVER%" "%TOOLKIT_VERSION%"
if errorlevel 1 (
    echo.
    echo %G% %T_U_UPTODATE%%N%
    del /f /q "%UPDFILE%" >nul 2>&1
    pause
    goto main
)
echo.
call :confirm "%T_U_AVAILABLE%" || (del /f /q "%UPDFILE%" >nul 2>&1 & goto main)
for %%A in ("%UPDFILE%") do set "UPDSIZE=%%~zA"
set "UPDOK=1"
if %UPDSIZE% lss 20000 set "UPDOK=0"
findstr /b /c:"@echo off" "%UPDFILE%" >nul || set "UPDOK=0"
findstr /i /c:"<html" "%UPDFILE%" >nul && set "UPDOK=0"
if "%UPDOK%"=="0" (
    echo %R% %T_U_SANITYFAIL%%N%
    del /f /q "%UPDFILE%" >nul 2>&1
    pause
    goto main
)
set "UPDATER=%TEMP%\ttk_updater_%RANDOM%.bat"
if exist "%UPDATER%" del /f /q "%UPDATER%" >nul 2>&1
> "%UPDATER%" echo @echo off
>>"%UPDATER%" echo timeout /t 2 /nobreak ^>nul
>>"%UPDATER%" echo copy /y "%UPDFILE%" "%~f0" ^>nul
>>"%UPDATER%" echo del /f /q "%UPDFILE%"
>>"%UPDATER%" echo start "" "%~f0" %LANG%
>>"%UPDATER%" echo del /f /q "%UPDATER%"
call :log "Self-update to %REMOTEVER% started"
echo %G% %T_U_UPDATING%%N%
start "TTK Updater" cmd /c "%UPDATER%"
timeout /t 2 >nul
goto quit

:: ============================================================
:bitlocker
if not exist "%windir%\System32\manage-bde.exe" (
    call :header "%T_H_BITLOCKER%"
    echo %Y% %T_BL_NOTAVAILABLE%%N%
    pause
    goto main
)
call :header "%T_H_BITLOCKER%"
echo  %Y%[1]%N%  %T_BL_M1%
echo  %Y%[2]%N%  %T_BL_M2%
echo  %Y%[3]%N%  %T_BL_M3%
echo  %Y%[4]%N%  %T_BL_M4%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto bitStatus
if "%opt%"=="2" goto bitEncrypt
if "%opt%"=="3" goto bitUnlock
if "%opt%"=="4" goto bitLock
call :invalid
goto bitlocker

:bitStatus
call :header "%T_H_BITLOCKER%"
manage-bde -status
call :log "Viewed BitLocker status"
pause
goto bitlocker

:bitEncrypt
call :header "%T_H_BITLOCKER%"
manage-bde -status
echo.
set "BDRV="
set /p "BDRV= %T_BL_DRIVEPROMPT% "
if not defined BDRV goto bitlocker
set "BDRV=%BDRV::=%"
set "BDRV=%BDRV: =%"
if /i "%BDRV%"=="%SystemDrive:~0,1%" (
    echo %R% %T_BL_SYSDRIVEBLOCK%%N%
    pause
    goto bitlocker
)
if not exist "%BDRV%:\" (
    echo %R% %T_BL_BADDRIVE%%N%
    pause
    goto bitlocker
)
call :confirm "%T_BL_ENCRYPTCONFIRM% %BDRV%:" || goto bitlocker
echo %D% %T_BL_PWHINT%%N%
manage-bde -on %BDRV%: -Password
if errorlevel 1 (
    echo %R% %T_BL_ENCRYPTFAIL%%N%
) else (
    call :log "BitLocker turned on for %BDRV%:"
    echo %G% %T_BL_ENCRYPTDONE%%N%
)
pause
goto bitlocker

:bitUnlock
call :header "%T_H_BITLOCKER%"
manage-bde -status
echo.
set "BDRV="
set /p "BDRV= %T_BL_DRIVEPROMPT% "
if not defined BDRV goto bitlocker
set "BDRV=%BDRV::=%"
set "BDRV=%BDRV: =%"
if not exist "%BDRV%:\" (
    echo %R% %T_BL_BADDRIVE%%N%
    pause
    goto bitlocker
)
echo  %Y%[1]%N% %T_BL_METHPW%
echo  %Y%[2]%N% %T_BL_METHRECOVERY%
set "meth="
set /p "meth=%G% %T_SELECT% %N%"
set "RECKEY="
if "%meth%"=="2" set /p "RECKEY= %T_BL_RECOVERYPROMPT% "
if "%meth%"=="2" if not defined RECKEY goto bitlocker
if "%meth%"=="2" (manage-bde -unlock %BDRV%: -RecoveryPassword %RECKEY%) else (manage-bde -unlock %BDRV%: -Password)
if errorlevel 1 (
    echo %R% %T_BL_UNLOCKFAIL%%N%
) else (
    call :log "Unlocked BitLocker drive %BDRV%:"
    echo %G% %T_BL_UNLOCKDONE%%N%
)
pause
goto bitlocker

:bitLock
call :header "%T_H_BITLOCKER%"
manage-bde -status
echo.
set "BDRV="
set /p "BDRV= %T_BL_DRIVEPROMPT% "
if not defined BDRV goto bitlocker
set "BDRV=%BDRV::=%"
set "BDRV=%BDRV: =%"
if not exist "%BDRV%:\" (
    echo %R% %T_BL_BADDRIVE%%N%
    pause
    goto bitlocker
)
manage-bde -lock %BDRV%:
if errorlevel 1 (
    echo %R% %T_BL_LOCKFAIL%%N%
) else (
    call :log "Locked BitLocker drive %BDRV%:"
    echo %G% %T_BL_LOCKDONE%%N%
)
pause
goto bitlocker

:quit
call :log "Toolkit closed"
if exist "%TEMP%\ttk_monitor.pid" (
    for /f "usebackq delims=" %%p in ("%TEMP%\ttk_monitor.pid") do taskkill /PID %%p /F >nul 2>&1
    del /f /q "%TEMP%\ttk_monitor.pid" >nul 2>&1
)
del /f /q "%TEMP%\ttk_mon_*.b64" >nul 2>&1
del /f /q "%TEMP%\ttk_mon_*.ps1" >nul 2>&1
echo %G% %T_GOODBYE%%N%
timeout /t 1 >nul
endlocal
exit /b
