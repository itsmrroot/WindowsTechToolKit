# 🛠️ Windows Technician Toolkit PRO

An all-in-one, menu-driven batch script for Windows technicians, IT support staff, and power users. You get admin consoles, system reports, repair tools, network diagnostics, cleanup, and boot options from a single colored console window.

No installation, no dependencies. Just download and double-click.

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows)
![Language](https://img.shields.io/badge/language-Batch-4D4D4D)
![Languages](https://img.shields.io/badge/menus-EN%20%7C%20DE%20%7C%20TR-6f42c1)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🔓 Two editions

| File | Elevation | What's in it |
|---|---|---|
| **`WindowsTechToolKit.bat`** | Auto-elevates to Administrator | Everything — including repair tools, driver management, network reset, static IP configuration, Safe Mode toggling |
| **`WindowsTechToolKit-NoAdmin.bat`** | Never asks for admin | Only tools that genuinely work for a standard Windows user |

The No-Admin edition isn't a trimmed-down demo — it's a real, separately maintained tool built by going through every single menu item and checking whether Windows actually requires elevation for it (some of this is non-obvious: `shutdown /r` and `netstat` don't need admin despite feeling like they should, while `ipconfig /release`, `netsh wlan show profile key=clear`, and anything touching SFC/DISM/CHKDSK/BCDEdit absolutely do). Repair tools, driver export/import, network reset, static IP configuration, and Safe Mode toggling are left out entirely because they genuinely require administrator rights on Windows — there's no way around that, so use the full edition for those. Everything included in the No-Admin edition — System Monitor, System Info & Reports, most of Network Tools, and the parts of Admin Consoles/Cleanup/Power that don't need elevation — is fully functional without ever prompting for admin.

---

## ✨ Features

- **Multi-language menus.** On launch, pick English, Deutsch, or Türkçe; every menu, prompt, and status message is shown in that language for the rest of the session.
- **Auto-elevation.** It requests administrator rights automatically, so you don't need to right-click. Your language choice is carried over when it relaunches itself elevated.
- **Colored, categorized menus.** Six sections keep 50+ tools easy to find.
- **Safety prompts.** Anything risky asks you to type `YES` before running.
- **Input validation.** Typing something other than a listed number never breaks the script — it shows a warning in your chosen language and re-asks until you enter a valid option.
- **Loading spinner.** Slower operations (building a full report, collecting installed software, a full repair) show an animated spinner with a status message instead of sitting there silently.
- **Saved reports.** Reports are saved with timestamps to `%USERPROFILE%\TechToolkit_Reports`.
- **Activity log.** Every action is recorded in `toolkit_log.txt`.
- **Windows Home aware.** On Home editions, it shows a fallback or an explanation for tools that edition doesn't include.

## 📋 Menu Overview

### System Monitor
Launches automatically as soon as you pick a language — it's not a menu option, it just runs for the whole session.

- **In Windows Terminal**, it opens as a split pane inside the *same* window, on the right side (~40% of the width). If you launched from a plain `cmd.exe`/legacy console but Windows Terminal is installed, both editions automatically rehost themselves into Windows Terminal first (the admin edition does this even through the UAC prompt), so you get the merged view without doing anything extra.
- **Without Windows Terminal**, it falls back to a separate window instead — still fully live, just not merged. That window pins itself to the right half of the screen and stays on top so picking a menu option can't cover it up (best-effort — uses a couple of Windows-only APIs; if that fails, the window still opens, just not pinned).
- **Self-healing either way**: every time you return to the main menu, the toolkit checks (by process ID, so this works for a split pane or a separate window) whether the monitor is still running and relaunches it if you closed it. Closing the main toolkit closes the monitor too.

It updates about once a second, with its layout adapting to the actual pane/window width:
- CPU, RAM, and disk usage as color-coded bars (green/yellow/red by load); CPU and RAM also get a rolling trend sparkline. Every local drive (C:, D:, G:, ...) gets its own bar, not just the system drive
- Live network throughput (down/up, in Mbps), plus the IP address, subnet mask, and gateway of whichever adapter is actually on your default route
- A top-5-by-CPU process table (PID, name, live CPU%, memory)

Since the toolkit is plain ASCII (no special console setup required), it's drawn with `#`/`-` bars and a density-character sparkline rather than Unicode block graphics — same information, plain-text rendering.

### 1. Admin Consoles
| | | |
|---|---|---|
| CMD | PowerShell (uses PowerShell 7 if installed) | Registry Editor |
| Services | Event Viewer | Local Users |
| Group Policy | Computer Management | System Restore |
| Recovery Settings | Windows Security | Device Manager |
| Disk Management | Task Manager | Task Scheduler |
| System Configuration | Control Panel | Programs and Features |
| Windows Firewall | Resource Monitor | |

### 2. System Info & Reports
- Quick summary of the OS, model, serial number, CPU, RAM, GPU, disks, and uptime
- Full system report (saved as `.txt`)
- Battery health report for laptops (saved as `.html`)
- Installed software list
- Driver list (saved as `.csv`)
- Disk health status
- Critical errors from the last 24 hours
- Windows activation status

### 3. Repair & Maintenance
- System File Checker (`sfc /scannow`)
- DISM image repair
- **Full repair**, which runs DISM and then SFC
- CHKDSK, as a scan only or as a fix on the next reboot
- Create a restore point
- Reset Windows Update components
- Update all apps with `winget`
- Restart Windows Explorer
- Windows Memory Diagnostic
- Open Windows Update settings
- **Export drivers**, with a choice of destination: the default `TechToolkit_Reports` folder, a custom path you type, or the same folder the script itself is running from (handy when running off a USB stick, so the export travels with it) — handy before a clean reinstall
- **Import drivers from a folder** and install them for this PC's hardware (`pnputil /add-driver ... /install`)
- **Refresh all drivers** — exports and immediately reinstalls every driver currently on the PC in one step, a quick self-contained fix for a flaky/corrupted driver with no external media needed

### 4. Network Tools
- **One-click diagnosis** that checks your router, the internet, and DNS
- IP configuration and public IP
- Flush DNS, and release and renew your IP
- Ping and traceroute
- Saved Wi-Fi networks
- Active connections (saved to a file)
- Full network reset (Winsock and TCP/IP)
- **Show saved Wi-Fi passwords** for every network this PC has stored credentials for
- **Internet speed test** (download / upload / ping) via Ookla's official Speedtest CLI, installed automatically through `winget` the first time you use it
- **Configure IP address** — switch an adapter back to DHCP, or set a manual static IP. The subnet mask accepts either dotted form (`255.255.255.0`) or a CIDR prefix (`/24`, `24`, ...), converted automatically. Setting a static IP also offers an optional MAC address change for that adapter — press Enter to skip and leave it as is

### 5. Cleanup
- User temp files and Windows temp files
- Empty the Recycle Bin
- Disk Cleanup
- Component store cleanup
- Storage Sense settings

### 6. Power & Boot
- Restart into BIOS / UEFI
- Restart into Advanced Startup
- Turn Safe Mode booting on or off
- Startup apps and power plans
- Restart or shut down

### Check for Toolkit Updates
Downloads the latest `main` branch copy of whichever edition you're running from this repository, compares its version against yours, and if it's newer, asks for confirmation before installing it. A few sanity checks run on the download first (size, that it looks like a real script and not an error page) so nothing bad gets installed. Once confirmed, it relaunches automatically in your chosen language — no manual re-download needed.

## 🌐 Languages

The first screen asks you to pick a language:

| # | Language |
|---|---|
| 1 | English |
| 2 | Deutsch |
| 3 | Türkçe |

Entering anything other than `1`-`3` just shows a warning and asks again — it won't crash or silently pick a language for you. The choice is remembered through the administrator-elevation relaunch and the Windows Terminal rehost (see System Monitor below), so you're only asked once per run no matter how many times the toolkit relaunches itself in the background.

> **Note:** only the toolkit's own menus and messages are translated. Output from native Windows tools invoked by the toolkit (`systeminfo`, `ipconfig`, `driverquery`, and similar) is shown in whatever language Windows itself produces it in.

## 🚀 Getting Started

1. Download `WindowsTechToolKit.bat` (or `WindowsTechToolKit-NoAdmin.bat` if you don't have admin rights on the PC) from this repository, either through **Code → Download ZIP** or by opening the file and clicking **Download raw file**.
2. Double-click the file, choose your language, and approve the administrator prompt (skip that last part with the No-Admin edition — it never asks).
3. Type a menu number and press **Enter**.

> **SmartScreen warning?** Windows flags scripts downloaded from the internet. Click **More info → Run anyway**, or right-click the file, choose **Properties**, and tick **Unblock**.

## 🖥️ Requirements

- Windows 10 or Windows 11 (needed for the console colors)
- Administrator account for `WindowsTechToolKit.bat`; any standard account works for `WindowsTechToolKit-NoAdmin.bat`
- Optional: [winget](https://learn.microsoft.com/windows/package-manager/winget/) for bulk app updates and the internet speed test (it installs Ookla's Speedtest CLI on first use)
- Optional: [Windows Terminal](https://learn.microsoft.com/windows/terminal/) (preinstalled on most current Windows 11 systems) for the System Monitor to open as a merged split pane instead of a separate window

## ⚠️ Disclaimer

Some tools make system-level changes, such as a network reset, a Windows Update reset, Safe Mode booting, or scheduling CHKDSK. Each one asks for confirmation first. Still, **create a restore point before making major changes**, and use this toolkit at your own risk. The author is not responsible for data loss or system issues.

The **Show saved Wi-Fi passwords** tool prints stored network passwords in plain text to the console. Be mindful of who can see the screen (or a screen recording/share) when you use it.

## 🤝 Contributing

Suggestions and improvements are welcome:

1. Fork the repository.
2. Create a branch with `git checkout -b feature/new-tool`.
3. Commit your changes and open a Pull Request.

When editing, keep the `.bat` file saved with **CRLF** line endings.

## 📄 License

This project is licensed under the [MIT License](LICENSE).