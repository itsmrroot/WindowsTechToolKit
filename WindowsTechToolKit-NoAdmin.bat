@echo off
setlocal EnableExtensions
title Windows Technician Toolkit PRO - No Admin
mode con: cols=100 lines=42

:: ============================================================
::  WINDOWS TECHNICIAN TOOLKIT PRO - STANDARD USER EDITION
::  Powered by BASHAR SALMO
::  Runs entirely without administrator rights - deliberately does
::  NOT auto-elevate. Only includes tools/actions that work for a
::  standard Windows user. For repair tools (SFC/DISM/CHKDSK),
::  driver management, network reset, static IP configuration, and
::  Safe Mode toggling, use the full WindowsTechToolKit.bat instead -
::  those genuinely require administrator rights on Windows.
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

:: ---- Language selection (skipped if passed in as an argument) ----
set "LANG=%~1"
if /i "%LANG%"=="EN" goto langready
if /i "%LANG%"=="DE" goto langready
if /i "%LANG%"=="TR" goto langready
call :SelectLanguage
:langready
call :Lang_%LANG%

:: ---- One-time notice: what this edition intentionally leaves out ----
cls
echo %C%======================================================================%N%
echo %W%               WINDOWS TECHNICIAN TOOLKIT  PRO%N%
echo %Y%                    %T_NOADMIN_TAG%%N%
echo %C%======================================================================%N%
echo.
echo %D%%T_NOADMIN_NOTE%%N%
echo.
echo %Y%%T_NOADMIN_CONTINUE%%N%
pause >nul

:: ---- Reports folder and log (no elevation - this edition never requests it) ----
set "RPT=%USERPROFILE%\TechToolkit_Reports"
if not exist "%RPT%" md "%RPT%"
set "LOG=%RPT%\toolkit_log.txt"
call :log "Toolkit (No Admin edition) started (lang=%LANG%)"

:: ============================================================
:: ---- Launch the live System Monitor in its own window ----
set "MONFILE=%TEMP%\ttk_mon_%RANDOM%.b64"
if exist "%MONFILE%" del /f /q "%MONFILE%" >nul 2>&1
>>"%MONFILE%" echo JABjAG8AcgBlAEMAbwB1AG4AdAAgAD0AIAAoAEcAZQB0AC0AQwBpAG0ASQBuAHMAdABhAG4AYwBlACAAVwBpAG4AMwAyAF8AUAByAG8AYwBlAHMAcwBvAHIAIAAtAEUAcgByAG8AcgBBAGMAdABpAG8AbgAgAFMAaQBsAGUAbgB0AGwAeQBDAG8AbgB0AGkAbgB1AGUAIAB8ACAATQBlAGEAcwB1AHIAZQAtAE8AYgBqAGUAYwB0ACAALQBQAHIAbwBwAGUAcgB0AHkAIABOAHUAbQBiAGUAcgBPAGYATABvAGcAaQBjAGEAbABQAHIAbwBjAGUAcwBzAG8AcgBzACAALQBTAHUAbQApAC4AUwB1AG0ACgBpAGYAIAAoAC0AbgBvAHQAIAAkAGMA
>>"%MONFILE%" echo bwByAGUAQwBvAHUAbgB0ACkAIAB7ACAAJABjAG8AcgBlAEMAbwB1AG4AdAAgAD0AIAAxACAAfQAKACQAYwBwAHUASABpAHMAdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBDAG8AbABsAGUAYwB0AGkAbwBuAHMALgBHAGUAbgBlAHIAaQBjAC4AUQB1AGUAdQBlAFsAaQBuAHQAXQAKACQAcgBhAG0ASABpAHMAdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBDAG8AbABsAGUAYwB0AGkAbwBuAHMALgBHAGUAbgBlAHIAaQBjAC4AUQB1AGUAdQBlAFsAaQBuAHQAXQAKACQA
>>"%MONFILE%" echo cAByAGUAdgBQAHIAbwBjACAAPQAgAEAAewB9AAoAJABwAHIAZQB2AFQAaQBtAGUAIAA9ACAARwBlAHQALQBEAGEAdABlAAoACgBmAHUAbgBjAHQAaQBvAG4AIABCAGEAcgAoACQAcAAsACAAJAB3ACkAIAB7AAoAIAAgACAAIABpAGYAIAAoACQAcAAgAC0AbAB0ACAAMAApACAAewAgACQAcAAgAD0AIAAwACAAfQAKACAAIAAgACAAaQBmACAAKAAkAHAAIAAtAGcAdAAgADEAMAAwACkAIAB7ACAAJABwACAAPQAgADEAMAAwACAAfQAKACAAIAAgACAAJABmACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAkAHAAIAAqACAA
>>"%MONFILE%" echo JAB3ACAALwAgADEAMAAwACkACgAgACAAIAAgAHIAZQB0AHUAcgBuACAAKAAnACMAJwAgACoAIAAkAGYAKQAgACsAIAAoACcALQAnACAAKgAgACgAJAB3ACAALQAgACQAZgApACkACgB9AAoAZgB1AG4AYwB0AGkAbwBuACAAQwBvAGwAKAAkAHAAKQAgAHsACgAgACAAIAAgAGkAZgAgACgAJABwACAALQBnAGUAIAA4ADUAKQAgAHsAIAAnAFIAZQBkACcAIAB9ACAAZQBsAHMAZQBpAGYAIAAoACQAcAAgAC0AZwBlACAANgAwACkAIAB7ACAAJwBZAGUAbABsAG8AdwAnACAAfQAgAGUAbABzAGUAIAB7ACAAJwBHAHIAZQBlAG4AJwAgAH0A
>>"%MONFILE%" echo CgB9AAoAZgB1AG4AYwB0AGkAbwBuACAAUwBwAGEAcgBrACgAJABxACkAIAB7AAoAIAAgACAAIAAkAGMAaABhAHIAcwAgAD0AIAAnACAAJwAsACAAJwAuACcALAAgACcALQAnACwAIAAnAD0AJwAsACAAJwAjACcACgAgACAAIAAgACQAcwAgAD0AIAAnACcACgAgACAAIAAgAGYAbwByAGUAYQBjAGgAIAAoACQAdgAgAGkAbgAgACQAcQApACAAewAKACAAIAAgACAAIAAgACAAIAAkAGkAZAB4ACAAPQAgAFsAbQBhAHQAaABdADoAOgBGAGwAbwBvAHIAKAAkAHYAIAAvACAAMgAxACkACgAgACAAIAAgACAAIAAgACAAaQBmACAAKAAkAGkA
>>"%MONFILE%" echo ZAB4ACAALQBnAHQAIAA0ACkAIAB7ACAAJABpAGQAeAAgAD0AIAA0ACAAfQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAaQBkAHgAIAAtAGwAdAAgADAAKQAgAHsAIAAkAGkAZAB4ACAAPQAgADAAIAB9AAoAIAAgACAAIAAgACAAIAAgACQAcwAgACsAPQAgACQAYwBoAGEAcgBzAFsAJABpAGQAeABdAAoAIAAgACAAIAB9AAoAIAAgACAAIAByAGUAdAB1AHIAbgAgACQAcwAKAH0ACgBmAHUAbgBjAHQAaQBvAG4AIABQAGEAZAAoACQAcwAsACAAJAB3ACkAIAB7AAoAIAAgACAAIABpAGYAIAAoACQAcwAuAEwAZQBuAGcAdABoACAA
>>"%MONFILE%" echo LQBnAGUAIAAkAHcAKQAgAHsAIAByAGUAdAB1AHIAbgAgACQAcwAuAFMAdQBiAHMAdAByAGkAbgBnACgAMAAsACAAJAB3ACkAIAB9AAoAIAAgACAAIAByAGUAdAB1AHIAbgAgACQAcwAgACsAIAAoACcAIAAnACAAKgAgACgAJAB3ACAALQAgACQAcwAuAEwAZQBuAGcAdABoACkAKQAKAH0ACgAKAHQAcgB5ACAAewAKACAAIAAgACAAJABIAG8AcwB0AC4AVQBJAC4AUgBhAHcAVQBJAC4AVwBpAG4AZABvAHcAVABpAHQAbABlACAAPQAgACcAVABUAEsAIABMAGkAdgBlACAATQBvAG4AaQB0AG8AcgAnAAoAIAAgACAAIAAkAHEAIAA9ACAA
>>"%MONFILE%" echo WwBjAGgAYQByAF0AMwA0AAoAIAAgACAAIAAkAHMAaQBnACAAPQAgACcAWwBEAGwAbABJAG0AcABvAHIAdAAoACcAIAArACAAJABxACAAKwAgACcAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAJwAgACsAIAAkAHEAIAArACAAJwApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABJAG4AdABQAHQAcgAgAEcAZQB0AEMAbwBuAHMAbwBsAGUAVwBpAG4AZABvAHcAKAApADsAIABbAEQAbABsAEkAbQBwAG8AcgB0ACgAJwAgACsAIAAkAHEAIAArACAAJwB1AHMAZQByADMAMgAuAGQAbABsACcAIAArACAA
>>"%MONFILE%" echo JABxACAAKwAgACcAKQBdACAAcAB1AGIAbABpAGMAIABzAHQAYQB0AGkAYwAgAGUAeAB0AGUAcgBuACAAYgBvAG8AbAAgAE0AbwB2AGUAVwBpAG4AZABvAHcAKABJAG4AdABQAHQAcgAgAGgAVwBuAGQALAAgAGkAbgB0ACAAWAAsACAAaQBuAHQAIABZACwAIABpAG4AdAAgAG4AVwBpAGQAdABoACwAIABpAG4AdAAgAG4ASABlAGkAZwBoAHQALAAgAGIAbwBvAGwAIABiAFIAZQBwAGEAaQBuAHQAKQA7ACcACgAgACAAIAAgAEEAZABkAC0AVAB5AHAAZQAgAC0ATgBhAG0AZQAgAFcAaQBuADMAMgAgAC0ATgBhAG0AZQBzAHAAYQBjAGUA
>>"%MONFILE%" echo IABUAFQASwBOAGEAdABpAHYAZQAgAC0ATQBlAG0AYgBlAHIARABlAGYAaQBuAGkAdABpAG8AbgAgACQAcwBpAGcACgAgACAAIAAgAEEAZABkAC0AVAB5AHAAZQAgAC0AQQBzAHMAZQBtAGIAbAB5AE4AYQBtAGUAIABTAHkAcwB0AGUAbQAuAFcAaQBuAGQAbwB3AHMALgBGAG8AcgBtAHMACgAgACAAIAAgACQAcwBjAHIAIAA9ACAAWwBTAHkAcwB0AGUAbQAuAFcAaQBuAGQAbwB3AHMALgBGAG8AcgBtAHMALgBTAGMAcgBlAGUAbgBdADoAOgBQAHIAaQBtAGEAcgB5AFMAYwByAGUAZQBuAC4AVwBvAHIAawBpAG4AZwBBAHIAZQBhAAoA
>>"%MONFILE%" echo IAAgACAAIAAkAHcAdwAgAD0AIABbAGkAbgB0AF0AKAAkAHMAYwByAC4AVwBpAGQAdABoACAALwAgADIAKQAKACAAIAAgACAAWwBUAFQASwBOAGEAdABpAHYAZQAuAFcAaQBuADMAMgBdADoAOgBNAG8AdgBlAFcAaQBuAGQAbwB3ACgAWwBUAFQASwBOAGEAdABpAHYAZQAuAFcAaQBuADMAMgBdADoAOgBHAGUAdABDAG8AbgBzAG8AbABlAFcAaQBuAGQAbwB3ACgAKQAsACAAJABzAGMAcgAuAFcAaQBkAHQAaAAgAC0AIAAkAHcAdwAsACAAMAAsACAAJAB3AHcALAAgACQAcwBjAHIALgBIAGUAaQBnAGgAdAAsACAAJAB0AHIAdQBlACkA
>>"%MONFILE%" echo IAB8ACAATwB1AHQALQBOAHUAbABsAAoAfQAgAGMAYQB0AGMAaAAgAHsAfQAKAAoAQwBsAGUAYQByAC0ASABvAHMAdAAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAkAGUAbgB2ADoAVABfAE0ATwBOAF8AVABJAFQATABFACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEMAeQBhAG4ACgAKAHcAaABpAGwAZQAgACgALQBuAG8AdAAgAFsAQwBvAG4AcwBvAGwAZQBdADoAOgBLAGUAeQBBAHYAYQBpAGwAYQBiAGwAZQApACAAewAKACAAIAAgACAAJABuAG8AdwAgAD0AIABHAGUAdAAtAEQAYQB0AGUACgAgACAAIAAgACQA
>>"%MONFILE%" echo ZQBsAGEAcABzAGUAZAAgAD0AIAAoACQAbgBvAHcAIAAtACAAJABwAHIAZQB2AFQAaQBtAGUAKQAuAFQAbwB0AGEAbABTAGUAYwBvAG4AZABzAAoAIAAgACAAIABpAGYAIAAoACQAZQBsAGEAcABzAGUAZAAgAC0AbAB0ACAAMAAuADEAKQAgAHsAIAAkAGUAbABhAHAAcwBlAGQAIAA9ACAAMAAuADEAIAB9AAoACgAgACAAIAAgACQAYwBwAHUATwBiAGoAIAA9ACAARwBlAHQALQBDAGkAbQBJAG4AcwB0AGEAbgBjAGUAIABXAGkAbgAzADIAXwBQAHIAbwBjAGUAcwBzAG8AcgAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwA
>>"%MONFILE%" echo ZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAgAHwAIABNAGUAYQBzAHUAcgBlAC0ATwBiAGoAZQBjAHQAIAAtAFAAcgBvAHAAZQByAHQAeQAgAEwAbwBhAGQAUABlAHIAYwBlAG4AdABhAGcAZQAgAC0AQQB2AGUAcgBhAGcAZQAKACAAIAAgACAAJABjAHAAdQAgAD0AIAAwAAoAIAAgACAAIABpAGYAIAAoACQAYwBwAHUATwBiAGoAIAAtAGEAbgBkACAAJABjAHAAdQBPAGIAagAuAEEAdgBlAHIAYQBnAGUAKQAgAHsAIAAkAGMAcAB1ACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAkAGMAcAB1AE8AYgBqAC4AQQB2AGUA
>>"%MONFILE%" echo cgBhAGcAZQApACAAfQAKACAAIAAgACAAJABjAHAAdQBIAGkAcwB0AC4ARQBuAHEAdQBlAHUAZQAoACQAYwBwAHUAKQAKACAAIAAgACAAaQBmACAAKAAkAGMAcAB1AEgAaQBzAHQALgBDAG8AdQBuAHQAIAAtAGcAdAAgADIANAApACAAewAgAFsAdgBvAGkAZABdACQAYwBwAHUASABpAHMAdAAuAEQAZQBxAHUAZQB1AGUAKAApACAAfQAKAAoAIAAgACAAIAAkAG8AcwBpACAAPQAgAEcAZQB0AC0AQwBpAG0ASQBuAHMAdABhAG4AYwBlACAAVwBpAG4AMwAyAF8ATwBwAGUAcgBhAHQAaQBuAGcAUwB5AHMAdABlAG0AIAAtAEUAcgByAG8A
>>"%MONFILE%" echo cgBBAGMAdABpAG8AbgAgAFMAaQBsAGUAbgB0AGwAeQBDAG8AbgB0AGkAbgB1AGUACgAgACAAIAAgACQAcgBhAG0AIAA9ACAAMAAKACAAIAAgACAAJAByAGEAbQBVAHMAZQBkAEcAQgAgAD0AIAAwAAoAIAAgACAAIAAkAHIAYQBtAFQAbwB0AGEAbABHAEIAIAA9ACAAMAAKACAAIAAgACAAaQBmACAAKAAkAG8AcwBpACAALQBhAG4AZAAgACQAbwBzAGkALgBUAG8AdABhAGwAVgBpAHMAaQBiAGwAZQBNAGUAbQBvAHIAeQBTAGkAegBlACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACQAcgBhAG0AIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIA
>>"%MONFILE%" echo bwB1AG4AZAAoACgAKAAkAG8AcwBpAC4AVABvAHQAYQBsAFYAaQBzAGkAYgBsAGUATQBlAG0AbwByAHkAUwBpAHoAZQAgAC0AIAAkAG8AcwBpAC4ARgByAGUAZQBQAGgAeQBzAGkAYwBhAGwATQBlAG0AbwByAHkAKQAgAC8AIAAkAG8AcwBpAC4AVABvAHQAYQBsAFYAaQBzAGkAYgBsAGUATQBlAG0AbwByAHkAUwBpAHoAZQApACAAKgAgADEAMAAwACkACgAgACAAIAAgACAAIAAgACAAJAByAGEAbQBVAHMAZQBkAEcAQgAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAKAAkAG8AcwBpAC4AVABvAHQAYQBsAFYAaQBzAGkA
>>"%MONFILE%" echo YgBsAGUATQBlAG0AbwByAHkAUwBpAHoAZQAgAC0AIAAkAG8AcwBpAC4ARgByAGUAZQBQAGgAeQBzAGkAYwBhAGwATQBlAG0AbwByAHkAKQAgAC8AIAAxAE0AQgAsACAAMgApAAoAIAAgACAAIAAgACAAIAAgACQAcgBhAG0AVABvAHQAYQBsAEcAQgAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAJABvAHMAaQAuAFQAbwB0AGEAbABWAGkAcwBpAGIAbABlAE0AZQBtAG8AcgB5AFMAaQB6AGUAIAAvACAAMQBNAEIALAAgADIAKQAKACAAIAAgACAAfQAKACAAIAAgACAAJAByAGEAbQBIAGkAcwB0AC4ARQBuAHEAdQBlAHUA
>>"%MONFILE%" echo ZQAoACQAcgBhAG0AKQAKACAAIAAgACAAaQBmACAAKAAkAHIAYQBtAEgAaQBzAHQALgBDAG8AdQBuAHQAIAAtAGcAdAAgADIANAApACAAewAgAFsAdgBvAGkAZABdACQAcgBhAG0ASABpAHMAdAAuAEQAZQBxAHUAZQB1AGUAKAApACAAfQAKAAoAIAAgACAAIAAkAGQAaQBzAGsAcwAgAD0AIABAACgARwBlAHQALQBDAGkAbQBJAG4AcwB0AGEAbgBjAGUAIABXAGkAbgAzADIAXwBMAG8AZwBpAGMAYQBsAEQAaQBzAGsAIAAtAEYAaQBsAHQAZQByACAAJwBEAHIAaQB2AGUAVAB5AHAAZQA9ADMAJwAgAC0ARQByAHIAbwByAEEAYwB0AGkA
>>"%MONFILE%" echo bwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAgAHwAIABTAG8AcgB0AC0ATwBiAGoAZQBjAHQAIABEAGUAdgBpAGMAZQBJAEQAIAB8ACAAUwBlAGwAZQBjAHQALQBPAGIAagBlAGMAdAAgAC0ARgBpAHIAcwB0ACAANAApAAoACgAgACAAIAAgACQAbgBjACAAPQAgAEcAZQB0AC0AQwBvAHUAbgB0AGUAcgAgACcAXABOAGUAdAB3AG8AcgBrACAASQBuAHQAZQByAGYAYQBjAGUAKAAqACkAXABCAHkAdABlAHMAIABSAGUAYwBlAGkAdgBlAGQALwBzAGUAYwAnACwAIAAnAFwATgBlAHQAdwBvAHIAawAgAEkAbgB0AGUA
>>"%MONFILE%" echo cgBmAGEAYwBlACgAKgApAFwAQgB5AHQAZQBzACAAUwBlAG4AdAAvAHMAZQBjACcAIAAtAEUAcgByAG8AcgBBAGMAdABpAG8AbgAgAFMAaQBsAGUAbgB0AGwAeQBDAG8AbgB0AGkAbgB1AGUACgAgACAAIAAgACQAcgB4AEIAIAA9ACAAMAAKACAAIAAgACAAJAB0AHgAQgAgAD0AIAAwAAoAIAAgACAAIABpAGYAIAAoACQAbgBjACkAIAB7AAoAIAAgACAAIAAgACAAIAAgAGYAbwByAGUAYQBjAGgAIAAoACQAcwAgAGkAbgAgACQAbgBjAC4AQwBvAHUAbgB0AGUAcgBTAGEAbQBwAGwAZQBzACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgACAAaQBmACAAKAAkAHMALgBJAG4AcwB0AGEAbgBjAGUATgBhAG0AZQAgAC0AbgBvAHQAbQBhAHQAYwBoACAAJwBsAG8AbwBwAGIAYQBjAGsAfABpAHMAYQB0AGEAcAAnACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAcwAuAFAAYQB0AGgAIAAtAG0AYQB0AGMAaAAgACcAcgBlAGMAZQBpAHYAZQBkACcAKQAgAHsAIAAkAHIAeABCACAAKwA9ACAAJABzAC4AQwBvAG8AawBlAGQAVgBhAGwAdQBlACAAfQAgAGUAbABzAGUAIAB7ACAAJAB0AHgAQgAgACsAPQAgACQAcwAuAEMAbwBvAGsA
>>"%MONFILE%" echo ZQBkAFYAYQBsAHUAZQAgAH0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AAoAIAAgACAAIAAgACAAIAAgAH0ACgAgACAAIAAgAH0ACgAgACAAIAAgACQAcgB4AE0AYgBwAHMAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACQAcgB4AEIAIAAqACAAOAAgAC8AIAAxAE0AQgAsACAAMgApAAoAIAAgACAAIAAkAHQAeABNAGIAcABzACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAkAHQAeABCACAAKgAgADgAIAAvACAAMQBNAEIALAAgADIAKQAKAAoAIAAgACAAIAAkAG4AaQBjACAAPQAgAEcAZQB0AC0A
>>"%MONFILE%" echo QwBpAG0ASQBuAHMAdABhAG4AYwBlACAAVwBpAG4AMwAyAF8ATgBlAHQAdwBvAHIAawBBAGQAYQBwAHQAZQByAEMAbwBuAGYAaQBnAHUAcgBhAHQAaQBvAG4AIAAtAEYAaQBsAHQAZQByACAAJwBJAFAARQBuAGEAYgBsAGUAZAA9AFQAcgB1AGUAJwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAAxAAoAIAAgACAAIAAkAGkAcABBAGQAZAByACAAPQAgACcATgAvAEEAJwAKACAAIAAgACAA
>>"%MONFILE%" echo JABpAHAATQBhAHMAawAgAD0AIAAnAE4ALwBBACcACgAgACAAIAAgACQAaQBwAEcAdwAgAD0AIAAnAE4ALwBBACcACgAgACAAIAAgAGkAZgAgACgAJABuAGkAYwApACAAewAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAbgBpAGMALgBJAFAAQQBkAGQAcgBlAHMAcwApACAAewAgACQAaQBwAEEAZABkAHIAIAA9ACAAJABuAGkAYwAuAEkAUABBAGQAZAByAGUAcwBzAFsAMABdACAAfQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAbgBpAGMALgBJAFAAUwB1AGIAbgBlAHQAKQAgAHsAIAAkAGkAcABNAGEAcwBrACAAPQAgACQA
>>"%MONFILE%" echo bgBpAGMALgBJAFAAUwB1AGIAbgBlAHQAWwAwAF0AIAB9AAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABuAGkAYwAuAEQAZQBmAGEAdQBsAHQASQBQAEcAYQB0AGUAdwBhAHkAKQAgAHsAIAAkAGkAcABHAHcAIAA9ACAAJABuAGkAYwAuAEQAZQBmAGEAdQBsAHQASQBQAEcAYQB0AGUAdwBhAHkAWwAwAF0AIAB9AAoAIAAgACAAIAB9AAoACgAgACAAIAAgACQAcAByAG8AYwBzACAAPQAgAEcAZQB0AC0AUAByAG8AYwBlAHMAcwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUA
>>"%MONFILE%" echo ZQAKACAAIAAgACAAJABjAHUAcgBDAHAAdQAgAD0AIABAAHsAfQAKACAAIAAgACAAZgBvAHIAZQBhAGMAaAAgACgAJABwACAAaQBuACAAJABwAHIAbwBjAHMAKQAgAHsAIAAkAGMAdQByAEMAcAB1AFsAJABwAC4ASQBkAF0AIAA9ACAAJABwAC4AQwBQAFUAIAB9AAoAIAAgACAAIAAkAHcAaQB0AGgAUABjAHQAIAA9ACAAZgBvAHIAZQBhAGMAaAAgACgAJABwACAAaQBuACAAJABwAHIAbwBjAHMAKQAgAHsACgAgACAAIAAgACAAIAAgACAAJABwAGMAdAAgAD0AIAAwAAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABwAHIAZQB2AFAA
>>"%MONFILE%" echo cgBvAGMALgBDAG8AbgB0AGEAaQBuAHMASwBlAHkAKAAkAHAALgBJAGQAKQAgAC0AYQBuAGQAIAAkAHAALgBDAFAAVQApACAAewAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABlAGwAdABhACAAPQAgACQAcAAuAEMAUABVACAALQAgACQAcAByAGUAdgBQAHIAbwBjAFsAJABwAC4ASQBkAF0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAZABlAGwAdABhACAALQBsAHQAIAAwACkAIAB7ACAAJABkAGUAbAB0AGEAIAA9ACAAMAAgAH0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAkAHAAYwB0ACAAPQAgAFsA
>>"%MONFILE%" echo bQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAoACQAZABlAGwAdABhACAALwAgACQAZQBsAGEAcABzAGUAZAAgAC8AIAAkAGMAbwByAGUAQwBvAHUAbgB0ACkAIAAqACAAMQAwADAALAAgADEAKQAKACAAIAAgACAAIAAgACAAIAB9AAoAIAAgACAAIAAgACAAIAAgACQAcABuAGEAbQBlACAAPQAgACQAcAAuAFAAcgBvAGMAZQBzAHMATgBhAG0AZQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAcABuAGEAbQBlAC4ATABlAG4AZwB0AGgAIAAtAGcAdAAgADIAMAApACAAewAgACQAcABuAGEAbQBlACAAPQAgACQAcABuAGEAbQBlAC4A
>>"%MONFILE%" echo UwB1AGIAcwB0AHIAaQBuAGcAKAAwACwAIAAyADAAKQAgAH0ACgAgACAAIAAgACAAIAAgACAAWwBQAFMAQwB1AHMAdABvAG0ATwBiAGoAZQBjAHQAXQBAAHsAIABJAGQAIAA9ACAAJABwAC4ASQBkADsAIABOAGEAbQBlACAAPQAgACQAcABuAGEAbQBlADsAIABQAGMAdAAgAD0AIAAkAHAAYwB0ADsAIABNAGUAbQBNAEIAIAA9ACAAWwBtAGEAdABoAF0AOgA6AFIAbwB1AG4AZAAoACQAcAAuAFcAbwByAGsAaQBuAGcAUwBlAHQANgA0ACAALwAgADEATQBCACwAIAAxACkAIAB9AAoAIAAgACAAIAB9AAoAIAAgACAAIAAkAHQAbwBwACAA
>>"%MONFILE%" echo PQAgACQAdwBpAHQAaABQAGMAdAAgAHwAIABTAG8AcgB0AC0ATwBiAGoAZQBjAHQAIABQAGMAdAAgAC0ARABlAHMAYwBlAG4AZABpAG4AZwAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBGAGkAcgBzAHQAIAA1AAoAIAAgACAAIAAkAHAAcgBlAHYAUAByAG8AYwAgAD0AIAAkAGMAdQByAEMAcAB1AAoAIAAgACAAIAAkAHAAcgBlAHYAVABpAG0AZQAgAD0AIAAkAG4AbwB3AAoACgAgACAAIAAgAFsAQwBvAG4AcwBvAGwAZQBdADoAOgBTAGUAdABDAHUAcgBzAG8AcgBQAG8AcwBpAHQAaQBvAG4AKAAwACwAIAAyACkA
>>"%MONFILE%" echo CgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoACcAQwBQAFUAIABVAFMAQQBHAEUAIAAgACAAIAAgACAAewAwACwAMwB9ACUAIAAgAFsAJwAgAC0AZgAgACQAYwBwAHUAKQAgAC0ATgBvAE4AZQB3AGwAaQBuAGUAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABCAGEAcgAgACQAYwBwAHUAIAAyADQAKQAgAC0ATgBvAE4AZQB3AGwAaQBuAGUAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAKABDAG8AbAAgACQA
>>"%MONFILE%" echo YwBwAHUAKQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAoACcAXQAgACAAJwAgACsAIAAoAFMAcABhAHIAawAgACQAYwBwAHUASABpAHMAdAApACkAIAAzADQAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnACAAIABDAG8AcgBlAHMAOgAgACcAIAArACAAJABjAG8AcgBlAEMAbwB1AG4AdAApACAAOQA2ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAA
>>"%MONFILE%" echo RABhAHIAawBHAHIAYQB5AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgADkANgApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKAAnAFIAQQBNACAAVQBTAEEARwBFACAAIAAgACAAIAAgAHsAMAAsADMAfQAlACAAIABbACcAIAAtAGYAIAAkAHIAYQBtACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAQgBhAHIAIAAkAHIAYQBtACAAMgA0ACkA
>>"%MONFILE%" echo IAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgACgAQwBvAGwAIAAkAHIAYQBtACkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAF0AIAAgACcAIAArACAAKABTAHAAYQByAGsAIAAkAHIAYQBtAEgAaQBzAHQAKQApACAAMwA0ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBHAHIAYQB5AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwAgACAAVQBzAGUAZAA6ACAAJwAgACsA
>>"%MONFILE%" echo IAAkAHIAYQBtAFUAcwBlAGQARwBCACAAKwAgACcAIABHAEIAIAAvACAAJwAgACsAIAAkAHIAYQBtAFQAbwB0AGEAbABHAEIAIAArACAAJwAgAEcAQgAnACkAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAJwAnACAAOQA2ACkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAJwBEAEkAUwBLACAAVQBTAEEARwBFACcAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4A
>>"%MONFILE%" echo ZABDAG8AbABvAHIAIABXAGgAaQB0AGUACgAgACAAIAAgAGYAbwByACAAKAAkAGQAaQAgAD0AIAAwADsAIAAkAGQAaQAgAC0AbAB0ACAANAA7ACAAJABkAGkAKwArACkAIAB7AAoAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABkAGkAIAAtAGwAdAAgACQAZABpAHMAawBzAC4AQwBvAHUAbgB0ACkAIAB7AAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABkACAAPQAgACQAZABpAHMAawBzAFsAJABkAGkAXQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABQAGMAdAAgAD0AIAAwAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo JABkAFUAcwBlAGQAIAA9ACAAMAAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAZABUAG8AdABhAGwAIAA9ACAAMAAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAJABkAC4AUwBpAHoAZQApACAAewAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABkAFAAYwB0ACAAPQAgAFsAbQBhAHQAaABdADoAOgBSAG8AdQBuAGQAKAAoACgAJABkAC4AUwBpAHoAZQAgAC0AIAAkAGQALgBGAHIAZQBlAFMAcABhAGMAZQApACAALwAgACQAZAAuAFMAaQB6AGUAKQAgACoAIAAxADAAMAApAAoAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgACAAIAAgACAAIAAgACAAIAAkAGQAVQBzAGUAZAAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAKAAkAGQALgBTAGkAegBlACAALQAgACQAZAAuAEYAcgBlAGUAUwBwAGEAYwBlACkAIAAvACAAMQBHAEIALAAgADEAKQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAJABkAFQAbwB0AGEAbAAgAD0AIABbAG0AYQB0AGgAXQA6ADoAUgBvAHUAbgBkACgAJABkAC4AUwBpAHoAZQAgAC8AIAAxAEcAQgAsACAAMQApAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQAKACAAIAAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoACcAIAAgAHsAMAAsAC0AMwB9ACAAewAxACwAMwB9ACUAIAAgAFsAJwAgAC0AZgAgACQAZAAuAEQAZQB2AGkAYwBlAEkARAAsACAAJABkAFAAYwB0ACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAEIAYQByACAAJABkAFAAYwB0ACAAMgAwACkAIAAtAE4AbwBOAGUAdwBsAGkAbgBlACAALQBGAG8AcgBlAGcAcgBvAHUA
>>"%MONFILE%" echo bgBkAEMAbwBsAG8AcgAgACgAQwBvAGwAIAAkAGQAUABjAHQAKQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnAF0AIAAgACcAIAArACAAJABkAFUAcwBlAGQAIAArACAAJwAgAEcAQgAgAC8AIAAnACAAKwAgACQAZABUAG8AdABhAGwAIAArACAAJwAgAEcAQgAnACkAIAA0ADAAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgACAAIAAgACAAfQAgAGUAbABzAGUAIAB7AAoAIAAgACAAIAAgACAAIAAgACAA
>>"%MONFILE%" echo IAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAnACcAIAA5ADYAKQAKACAAIAAgACAAIAAgACAAIAB9AAoAIAAgACAAIAB9AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgADkANgApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwBOAEUAVABXAE8AUgBLACAAIAAgACAAIAAgACAAIABEAG8AdwBuADoAIAAnACAAKwAgACQAcgB4AE0AYgBwAHMAIAArACAAJwAgAE0AYgBwAHMAIAAgACAAVQBwADoAIAAnACAAKwAgACQAdAB4AE0AYgBwAHMA
>>"%MONFILE%" echo IAArACAAJwAgAE0AYgBwAHMAJwApACAAOQA2ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAQwB5AGEAbgAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAoACcAIAAgAEkAUAAgACcAIAArACAAJABpAHAAQQBkAGQAcgAgACsAIAAnACAAIAAgAE0AYQBzAGsAIAAnACAAKwAgACQAaQBwAE0AYQBzAGsAIAArACAAJwAgACAAIABHAFcAIAAnACAAKwAgACQAaQBwAEcAdwApACAAOQA2ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBHAHIAYQB5AAoA
>>"%MONFILE%" echo IAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACcAJwAgADkANgApAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwAtACcAIAAqACAAOQA2ACkAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAJwAgACAAVABPAFAAIABQAFIATwBDAEUAUwBTAEUAUwAgAEIAWQAgAEMAUABVACcAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8A
>>"%MONFILE%" echo bABvAHIAIABDAHkAYQBuAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwAgACAAewAwACwALQA4AH0AewAxACwALQAyADIAfQB7ADIALAA4AH0AewAzACwAMQAwAH0AJwAgAC0AZgAgACcAUABJAEQAJwAsACAAJwBOAEEATQBFACcALAAgACcAQwBQAFUAJQAnACwAIAAnAE0ARQBNACgATQBCACkAJwApACAAOQA2ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoAIAAgACAAIABmAG8AcgAgACgAJABpACAAPQAgADAAOwAgACQAaQAgAC0AbAB0ACAANQA7ACAA
>>"%MONFILE%" echo JABpACsAKwApACAAewAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACQAaQAgAC0AbAB0ACAAJAB0AG8AcAAuAEMAbwB1AG4AdAApACAAewAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACQAcgBvAHcAIAA9ACAAJAB0AG8AcABbACQAaQBdAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAoACcAIAAgAHsAMAAsAC0AOAB9AHsAMQAsAC0AMgAyAH0AewAyACwAOAA6AEYAMQB9AHsAMwAsADEAMAA6AEYAMQB9ACcAIAAtAGYAIAAkAHIAbwB3AC4ASQBkACwAIAAkAHIAbwB3AC4A
>>"%MONFILE%" echo TgBhAG0AZQAsACAAJAByAG8AdwAuAFAAYwB0ACwAIAAkAHIAbwB3AC4ATQBlAG0ATQBCACkAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABXAGgAaQB0AGUACgAgACAAIAAgACAAIAAgACAAfQAgAGUAbABzAGUAIAB7AAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACgAUABhAGQAIAAnACcAIAA5ADYAKQAKACAAIAAgACAAIAAgACAAIAB9AAoAIAAgACAAIAB9AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAKABQAGEAZAAgACgAJwAtACcAIAAqACAA
>>"%MONFILE%" echo OQA2ACkAIAA5ADYAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoAFAAYQBkACAAKAAnACAAIABMAGEAcwB0ACAAdQBwAGQAYQB0AGUAZAA6ACAAJwAgACsAIAAkAG4AbwB3AC4AVABvAFMAdAByAGkAbgBnACgAJwBIAEgAOgBtAG0AOgBzAHMAJwApACAAKwAgACcAIAAgACAAIAAgACcAIAArACAAJABlAG4AdgA6AFQAXwBNAE8ATgBfAEUAWABJAFQASABJAE4AVAApACAAOQA2ACkAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQA
>>"%MONFILE%" echo QwBvAGwAbwByACAARABhAHIAawBHAHIAYQB5AAoACgAgACAAIAAgAFMAdABhAHIAdAAtAFMAbABlAGUAcAAgAC0ATQBpAGwAbABpAHMAZQBjAG8AbgBkAHMAIAAxADAAMAAwAAoAfQAKAFsAQwBvAG4AcwBvAGwAZQBdADoAOgBSAGUAYQBkAEsAZQB5ACgAJAB0AHIAdQBlACkAIAB8ACAATwB1AHQALQBOAHUAbABsAAoA
start "TTK Live Monitor" powershell -NoProfile -Command "$b64=((Get-Content -Path $env:MONFILE -Raw) -replace '\s',''); $bytes=[Convert]::FromBase64String($b64); $script=[System.Text.Encoding]::Unicode.GetString($bytes); Invoke-Expression $script"

:main
call :header "%T_H_MAIN%"
echo  %Y%[1]%N%  %T_M1%        %D%%T_M1D%%N%
echo  %Y%[2]%N%  %T_M2% %D%%T_M2D%%N%
echo  %Y%[3]%N%  %T_M3%  %D%%T_M3D%%N%
echo  %Y%[4]%N%  %T_M4%         %D%%T_M4D%%N%
echo  %Y%[5]%N%  %T_M5%               %D%%T_M5D%%N%
echo  %Y%[6]%N%  %T_M6%          %D%%T_M6D%%N%
echo  %Y%[7]%N%  %T_M7%
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
if "%opt%"=="0" goto quit
call :invalid
goto main

:consoles
call :header "%T_H_CONSOLES%"
echo  %Y%[1]%N%  %T_C1%
echo  %Y%[2]%N%  %T_C2%
echo  %Y%[3]%N%  %T_C3%
echo  %Y%[4]%N%  %T_C4%
echo  %Y%[5]%N%  %T_C5%
echo  %Y%[6]%N%  %T_C10%
echo  %Y%[7]%N%  %T_C11%
echo  %Y%[8]%N%  %T_C12%
echo  %Y%[9]%N%  %T_C14%
echo  %Y%[10]%N% %T_C15%
echo  %Y%[11]%N% %T_C17%
echo  %Y%[12]%N% %T_C18%
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
if "%opt%"=="6" set "RUN=ms-settings:recovery"
if "%opt%"=="7" set "RUN=windowsdefender:"
if "%opt%"=="8" set "RUN=devmgmt.msc"
if "%opt%"=="9" set "RUN=taskmgr.exe"
if "%opt%"=="10" set "RUN=taskschd.msc"
if "%opt%"=="11" set "RUN=control.exe"
if "%opt%"=="12" set "RUN=appwiz.cpl"
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

:repair
call :header "%T_H_REPAIR%"
echo  %Y%[1]%N%  %T_R9%
echo  %Y%[2]%N%  %T_R8%             %D%%T_R8D%%N%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto repExplorer
if "%opt%"=="2" goto repWinget
call :invalid
goto repair

:repExplorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %G% %T_R_EXPLORERDONE%%N%
timeout /t 2 >nul
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

:network
call :header "%T_H_NETWORK%"
echo  %Y%[1]%N%  %T_N1%
echo  %Y%[2]%N%  %T_N2%
echo  %Y%[3]%N%  %T_N3%
echo  %Y%[4]%N%  %T_N4%
echo  %Y%[5]%N%  %T_N6%
echo  %Y%[6]%N%  %T_N7%
echo  %Y%[7]%N%  %T_N8%          %D%%T_N8D%%N%
echo  %Y%[8]%N%  %T_N9%          %D%%T_N9D%%N%
echo  %Y%[9]%N%  %T_N10%
echo  %Y%[10]%N% %T_N13%          %D%%T_N13D%%N%
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
if "%opt%"=="5" goto netPing
if "%opt%"=="6" goto netTrace
if "%opt%"=="7" netsh wlan show profiles & pause & goto network
if "%opt%"=="8" goto netConns
if "%opt%"=="9" start "" ncpa.cpl & goto network
if "%opt%"=="10" goto netSpeed
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
netstat -ano > "%F%" 2>&1
start "" notepad "%F%"
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

:cleanup
call :header "%T_H_CLEANUP%"
echo  %Y%[1]%N%  %T_L1%
echo  %Y%[2]%N%  %T_L3%
echo  %Y%[3]%N%  %T_L4%
echo  %Y%[4]%N%  %T_L6%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto clnUserTemp
if "%opt%"=="2" goto clnBin
if "%opt%"=="3" start "" cleanmgr.exe & goto cleanup
if "%opt%"=="4" start "" ms-settings:storagesense & goto cleanup
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

:clnBin
call :confirm "%T_L_BINCONFIRM%" || goto cleanup
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
call :log "Recycle Bin emptied"
echo %G% %T_DONE%%N%
pause
goto cleanup

:power
call :header "%T_H_POWER%"
echo  %Y%[1]%N%  %T_P1%
echo  %Y%[2]%N%  %T_P2%
echo  %Y%[3]%N%  %T_P6%
echo  %Y%[4]%N%  %T_P7%
echo  %Y%[5]%N%  %T_P8%
echo.
echo  %R%[0]%N%  %T_BACK%
echo.
set "opt="
set /p "opt=%G% %T_SELECT% %N%"
if "%opt%"=="0" goto main
if "%opt%"=="1" goto pwBios
if "%opt%"=="2" goto pwAdv
if "%opt%"=="3" powercfg /list & pause & goto power
if "%opt%"=="4" goto pwRestart
if "%opt%"=="5" goto pwShutdown
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
echo %Y%                    %T_NOADMIN_TAG%%N%
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
set "T_M2=System Info and Reports"
set "T_M2D=Summary, battery, drivers, errors"
set "T_M3=Repair and Maintenance"
set "T_M4=Network Tools"
set "T_M5=Cleanup"
set "T_M6=Power and Boot"
set "T_M7=Open Reports Folder"
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Registry Editor"
set "T_C4=Services"
set "T_C5=Event Viewer"
set "T_C10=Recovery Settings"
set "T_C11=Windows Security"
set "T_C12=Device Manager"
set "T_C14=Task Manager"
set "T_C15=Task Scheduler"
set "T_C17=Control Panel"
set "T_C18=Programs and Features"
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
set "T_R9=Restart Windows Explorer"
set "T_R_EXPLORERDONE=Explorer restarted."
set "T_R8=Update all apps"
set "T_R8D=winget"
set "T_R_WINGETMISSING=winget is not installed. Get App Installer from the Microsoft Store."
set "T_R_WINGETCONFIRM=Install all the updates listed above?"
set "T_N1=Quick connection diagnosis"
set "T_N2=Show IP configuration"
set "T_N3=Show public IP address"
set "T_N4=Flush DNS cache"
set "T_N6=Ping a host"
set "T_N7=Trace route to a host"
set "T_N8=Saved Wi-Fi networks"
set "T_N9=Active connections"
set "T_N9D=saved to file"
set "T_N10=Open Network Adapters"
set "T_N13=Internet speed test"
set "T_N13D=download, upload, ping"
set "T_N_ROUTEROK=Router reachable -"
set "T_N_ROUTERFAIL=Router not responding -"
set "T_N_NOGATEWAY=No default gateway - check cable or Wi-Fi"
set "T_N_INETOK=Internet reachable"
set "T_N_INETFAIL=Internet not reachable"
set "T_N_DNSOK=DNS resolving names"
set "T_N_DNSFAIL=DNS not working - try Flush DNS or Network reset"
set "T_N_PINGPROMPT=Host or IP to ping:"
set "T_N_TRACEPROMPT=Host or IP to trace:"
set "T_N_SPEEDCONFIRM=This installs Ookla's official Speedtest CLI, about 15 MB, via winget, then runs a real speed test. Continue?"
set "T_N_SPEEDINSTALLING=Installing Speedtest CLI, one-time via winget..."
set "T_N_SPEEDRETRY=Installed. Please close and reopen this toolkit, then run the speed test again."
set "T_N_SPEEDRUNNING=Running speed test..."
set "T_L1=Clear my temp files"
set "T_L_USERTEMPCONFIRM=Delete temporary files in your Temp folder? Files in use will be skipped."
set "T_L3=Empty Recycle Bin"
set "T_L_BINCONFIRM=Permanently delete everything in the Recycle Bin?"
set "T_L4=Disk Cleanup"
set "T_L6=Storage Sense settings"
set "T_P1=Restart into BIOS / UEFI"
set "T_P_BIOSCONFIRM=Save your work. The PC will restart into firmware settings."
set "T_P_BIOSFAIL=This PC does not support restarting into firmware from Windows."
set "T_P2=Restart into Advanced Startup"
set "T_P_ADVCONFIRM=Save your work. The PC will restart into Advanced Startup."
set "T_P6=Power plans"
set "T_P7=Restart now"
set "T_P_RESTARTCONFIRM=Restart the computer now?"
set "T_P8=Shut down now"
set "T_P_SHUTDOWNCONFIRM=Shut down the computer now?"
set "T_MON_TITLE=LIVE SYSTEM MONITOR"
set "T_MON_EXITHINT=Press any key to exit..."
set "T_M1D=CMD, PowerShell, Registry, Services..."
set "T_M3D=Restart Explorer, update apps"
set "T_M4D=Diagnose, DNS, ping, Wi-Fi, speed test"
set "T_M5D=Temp files, Recycle Bin, Disk Cleanup"
set "T_M6D=BIOS, Advanced Startup, power plans"
set "T_NOADMIN_TAG=Standard User Edition - No Admin Required"
set "T_NOADMIN_NOTE=This edition intentionally skips anything that needs administrator rights. For repair tools, driver management, network resets, and static IP configuration, use the full WindowsTechToolKit.bat."
set "T_NOADMIN_CONTINUE=Press any key to continue..."
set "T_N8D=names only, no passwords"
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
set "T_M2=Systeminfo und Berichte"
set "T_M2D=Uebersicht, Akku, Treiber, Fehler"
set "T_M3=Reparatur und Wartung"
set "T_M4=Netzwerktools"
set "T_M5=Bereinigung"
set "T_M6=Energie und Start"
set "T_M7=Berichtsordner oeffnen"
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Registrierungs-Editor"
set "T_C4=Dienste"
set "T_C5=Ereignisanzeige"
set "T_C10=Wiederherstellungseinstellungen"
set "T_C11=Windows-Sicherheit"
set "T_C12=Geraete-Manager"
set "T_C14=Task-Manager"
set "T_C15=Aufgabenplanung"
set "T_C17=Systemsteuerung"
set "T_C18=Programme und Features"
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
set "T_R9=Windows-Explorer neu starten"
set "T_R_EXPLORERDONE=Explorer wurde neu gestartet."
set "T_R8=Alle Apps aktualisieren"
set "T_R8D=winget"
set "T_R_WINGETMISSING=winget ist nicht installiert. Laden Sie App Installer aus dem Microsoft Store herunter."
set "T_R_WINGETCONFIRM=Sollen alle oben aufgefuehrten Updates installiert werden?"
set "T_N1=Schnelle Verbindungsdiagnose"
set "T_N2=IP-Konfiguration anzeigen"
set "T_N3=Oeffentliche IP-Adresse anzeigen"
set "T_N4=DNS-Cache leeren"
set "T_N6=Host anpingen"
set "T_N7=Route zu einem Host verfolgen"
set "T_N8=Gespeicherte WLAN-Netzwerke"
set "T_N9=Aktive Verbindungen"
set "T_N9D=wird in Datei gespeichert"
set "T_N10=Netzwerkadapter oeffnen"
set "T_N13=Internet-Geschwindigkeitstest"
set "T_N13D=Download, Upload, Ping"
set "T_N_ROUTEROK=Router erreichbar -"
set "T_N_ROUTERFAIL=Router antwortet nicht -"
set "T_N_NOGATEWAY=Kein Standardgateway - Kabel oder WLAN pruefen"
set "T_N_INETOK=Internet erreichbar"
set "T_N_INETFAIL=Internet nicht erreichbar"
set "T_N_DNSOK=DNS loest Namen auf"
set "T_N_DNSFAIL=DNS funktioniert nicht - versuchen Sie DNS leeren oder Netzwerk-Reset"
set "T_N_PINGPROMPT=Host oder IP zum Anpingen:"
set "T_N_TRACEPROMPT=Host oder IP zum Verfolgen:"
set "T_N_SPEEDCONFIRM=Dies installiert Ooklas offizielle Speedtest-CLI, etwa 15 MB, ueber winget, und fuehrt dann einen echten Geschwindigkeitstest durch. Fortfahren?"
set "T_N_SPEEDINSTALLING=Speedtest-CLI wird installiert, einmalig ueber winget..."
set "T_N_SPEEDRETRY=Installiert. Bitte schliessen Sie dieses Toolkit und starten Sie es erneut, dann fuehren Sie den Geschwindigkeitstest noch einmal aus."
set "T_N_SPEEDRUNNING=Geschwindigkeitstest laeuft..."
set "T_L1=Meine Temp-Dateien loeschen"
set "T_L_USERTEMPCONFIRM=Temporaere Dateien in Ihrem Temp-Ordner loeschen? Dateien in Verwendung werden uebersprungen."
set "T_L3=Papierkorb leeren"
set "T_L_BINCONFIRM=Alles im Papierkorb endgueltig loeschen?"
set "T_L4=Datentraegerbereinigung"
set "T_L6=Speicheroptimierung-Einstellungen"
set "T_P1=Neustart ins BIOS / UEFI"
set "T_P_BIOSCONFIRM=Speichern Sie Ihre Arbeit. Der PC wird in die Firmware-Einstellungen neu gestartet."
set "T_P_BIOSFAIL=Dieser PC unterstuetzt keinen Neustart in die Firmware aus Windows heraus."
set "T_P2=Neustart in erweiterten Start"
set "T_P_ADVCONFIRM=Speichern Sie Ihre Arbeit. Der PC wird in den erweiterten Start neu gestartet."
set "T_P6=Energiesparplaene"
set "T_P7=Jetzt neu starten"
set "T_P_RESTARTCONFIRM=Computer jetzt neu starten?"
set "T_P8=Jetzt herunterfahren"
set "T_P_SHUTDOWNCONFIRM=Computer jetzt herunterfahren?"
set "T_MON_TITLE=LIVE-SYSTEMMONITOR"
set "T_MON_EXITHINT=Beliebige Taste druecken zum Beenden..."
set "T_M1D=CMD, PowerShell, Registrierung, Dienste..."
set "T_M3D=Explorer neu starten, Apps aktualisieren"
set "T_M4D=Diagnose, DNS, Ping, WLAN, Geschwindigkeitstest"
set "T_M5D=Temp-Dateien, Papierkorb, Datentraegerbereinigung"
set "T_M6D=BIOS, Erweiterter Start, Energiesparplaene"
set "T_NOADMIN_TAG=Standardbenutzer-Edition - Keine Adminrechte erforderlich"
set "T_NOADMIN_NOTE=Diese Edition laesst absichtlich alles aus, was Administratorrechte erfordert. Fuer Reparaturwerkzeuge, Treiberverwaltung, Netzwerk-Reset und statische IP-Konfiguration verwenden Sie die vollstaendige WindowsTechToolKit.bat."
set "T_NOADMIN_CONTINUE=Beliebige Taste druecken, um fortzufahren..."
set "T_N8D=nur Namen, keine Passwoerter"
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
set "T_M2=Sistem Bilgisi ve Raporlar"
set "T_M2D=Ozet, pil, suruculer, hatalar"
set "T_M3=Onarim ve Bakim"
set "T_M4=Ag Araclari"
set "T_M5=Temizlik"
set "T_M6=Guc ve Onyukleme"
set "T_M7=Raporlar Klasorunu Ac"
set "T_C1=CMD"
set "T_C2=PowerShell"
set "T_C3=Kayit Defteri Duzenleyicisi"
set "T_C4=Hizmetler"
set "T_C5=Olay Goruntuleyici"
set "T_C10=Kurtarma Ayarlari"
set "T_C11=Windows Guvenligi"
set "T_C12=Aygit Yoneticisi"
set "T_C14=Gorev Yoneticisi"
set "T_C15=Gorev Zamanlayici"
set "T_C17=Denetim Masasi"
set "T_C18=Programlar ve Ozellikler"
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
set "T_R9=Windows Gezgini'ni yeniden baslat"
set "T_R_EXPLORERDONE=Gezgin yeniden baslatildi."
set "T_R8=Tum uygulamalari guncelle"
set "T_R8D=winget"
set "T_R_WINGETMISSING=winget yuklu degil. Microsoft Store'dan App Installer'i edinin."
set "T_R_WINGETCONFIRM=Yukarida listelenen tum guncellemeler yuklensin mi?"
set "T_N1=Hizli baglanti tanilamasi"
set "T_N2=IP yapilandirmasini goster"
set "T_N3=Genel IP adresini goster"
set "T_N4=DNS onbellegini temizle"
set "T_N6=Bir sunucuyu ping'le"
set "T_N7=Bir sunucuya rota izle"
set "T_N8=Kayitli Wi-Fi aglari"
set "T_N9=Etkin baglantilar"
set "T_N9D=dosyaya kaydedilir"
set "T_N10=Ag Bagdastiricilarini Ac"
set "T_N13=Internet hiz testi"
set "T_N13D=indirme, yukleme, ping"
set "T_N_ROUTEROK=Yonlendiriciye ulasilabiliyor -"
set "T_N_ROUTERFAIL=Yonlendirici yanit vermiyor -"
set "T_N_NOGATEWAY=Varsayilan ag gecidi yok - kabloyu veya Wi-Fi'yi kontrol edin"
set "T_N_INETOK=Internete ulasilabiliyor"
set "T_N_INETFAIL=Internete ulasilamiyor"
set "T_N_DNSOK=DNS isimleri cozumluyor"
set "T_N_DNSFAIL=DNS calismiyor - DNS Temizleme veya Ag Sifirlama deneyin"
set "T_N_PINGPROMPT=Ping atilacak sunucu veya IP:"
set "T_N_TRACEPROMPT=Izlenecek sunucu veya IP:"
set "T_N_SPEEDCONFIRM=Bu islem, winget araciligiyla Ookla'nin resmi Speedtest CLI aracini, yaklasik 15 MB, yukler ve ardindan gercek bir hiz testi calistirir. Devam edilsin mi?"
set "T_N_SPEEDINSTALLING=Speedtest CLI yukleniyor, winget araciligiyla tek seferlik..."
set "T_N_SPEEDRETRY=Yuklendi. Lutfen bu arac setini kapatip yeniden acin, ardindan hiz testini tekrar calistirin."
set "T_N_SPEEDRUNNING=Hiz testi calisiyor..."
set "T_L1=Gecici dosyalarimi temizle"
set "T_L_USERTEMPCONFIRM=Temp klasorunuzdeki gecici dosyalar silinsin mi? Kullanimda olan dosyalar atlanacaktir."
set "T_L3=Geri Donusum Kutusunu bosalt"
set "T_L_BINCONFIRM=Geri Donusum Kutusundaki her sey kalici olarak silinsin mi?"
set "T_L4=Disk Temizleme"
set "T_L6=Depolama Duyarliligi ayarlari"
set "T_P1=BIOS / UEFI'ye yeniden baslat"
set "T_P_BIOSCONFIRM=Calismanizi kaydedin. Bilgisayar urun yazilimi ayarlarina yeniden baslatilacak."
set "T_P_BIOSFAIL=Bu bilgisayar Windows'tan urun yazilimina yeniden baslatmayi desteklemiyor."
set "T_P2=Gelismis Baslangic'a yeniden baslat"
set "T_P_ADVCONFIRM=Calismanizi kaydedin. Bilgisayar Gelismis Baslangic'a yeniden baslatilacak."
set "T_P6=Guc planlari"
set "T_P7=Simdi yeniden baslat"
set "T_P_RESTARTCONFIRM=Bilgisayar simdi yeniden baslatilsin mi?"
set "T_P8=Simdi kapat"
set "T_P_SHUTDOWNCONFIRM=Bilgisayar simdi kapatilsin mi?"
set "T_MON_TITLE=CANLI SISTEM IZLEYICI"
set "T_MON_EXITHINT=Cikmak icin herhangi bir tusa basin..."
set "T_M1D=CMD, PowerShell, Kayit Defteri, Hizmetler..."
set "T_M3D=Gezgini yeniden baslat, uygulamalari guncelle"
set "T_M4D=Tanilama, DNS, ping, Wi-Fi, hiz testi"
set "T_M5D=Gecici dosyalar, Geri Donusum Kutusu, Disk Temizleme"
set "T_M6D=BIOS, Gelismis Baslangic, guc planlari"
set "T_NOADMIN_TAG=Standart Kullanici Surumu - Yonetici Gerekmez"
set "T_NOADMIN_NOTE=Bu surum, yonetici hakki gerektiren her seyi kasitli olarak atlar. Onarim araclari, surucu yonetimi, ag sifirlama ve statik IP yapilandirmasi icin tam surum olan WindowsTechToolKit.bat dosyasini kullanin."
set "T_NOADMIN_CONTINUE=Devam etmek icin herhangi bir tusa basin..."
set "T_N8D=yalnizca isimler, sifre yok"
exit /b

:quit
call :log "Toolkit closed"
taskkill /FI "WINDOWTITLE eq TTK Live Monitor*" /F >nul 2>&1
if defined MONFILE if exist "%MONFILE%" del /f /q "%MONFILE%" >nul 2>&1
echo %G% %T_GOODBYE%%N%
timeout /t 1 >nul
endlocal
exit /b


