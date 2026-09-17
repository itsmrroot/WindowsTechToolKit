# 🛠️ Windows Technician Toolkit PRO

An all-in-one, menu-driven batch script for Windows technicians, IT support staff, and power users. You get admin consoles, system reports, repair tools, network diagnostics, cleanup, and boot options from a single colored console window.

No installation, no dependencies. Just download and double-click.

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows)
![Language](https://img.shields.io/badge/language-Batch-4D4D4D)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

- **Auto-elevation.** It requests administrator rights automatically, so you don't need to right-click.
- **Colored, categorized menus.** Six sections keep 50+ tools easy to find.
- **Safety prompts.** Anything risky asks you to type `YES` before running.
- **Saved reports.** Reports are saved with timestamps to `%USERPROFILE%\TechToolkit_Reports`.
- **Activity log.** Every action is recorded in `toolkit_log.txt`.
- **Windows Home aware.** On Home editions, it shows a fallback or an explanation for tools that edition doesn't include.

## 📋 Menu Overview

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

### 4. Network Tools
- **One-click diagnosis** that checks your router, the internet, and DNS
- IP configuration and public IP
- Flush DNS, and release and renew your IP
- Ping and traceroute
- Saved Wi-Fi networks
- Active connections (saved to a file)
- Full network reset (Winsock and TCP/IP)

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

## 🚀 Getting Started

1. Download `WindowsTechToolkit.bat` from this repository, either through **Code → Download ZIP** or by opening the file and clicking **Download raw file**.
2. Double-click the file and approve the administrator prompt.
3. Type a menu number and press **Enter**.

> **SmartScreen warning?** Windows flags scripts downloaded from the internet. Click **More info → Run anyway**, or right-click the file, choose **Properties**, and tick **Unblock**.

## 🖥️ Requirements

- Windows 10 or Windows 11 (needed for the console colors)
- Administrator account
- Optional: [winget](https://learn.microsoft.com/windows/package-manager/winget/) for bulk app updates

## ⚠️ Disclaimer

Some tools make system-level changes, such as a network reset, a Windows Update reset, Safe Mode booting, or scheduling CHKDSK. Each one asks for confirmation first. Still, **create a restore point before making major changes**, and use this toolkit at your own risk. The author is not responsible for data loss or system issues.

## 🤝 Contributing

Suggestions and improvements are welcome:

1. Fork the repository.
2. Create a branch with `git checkout -b feature/new-tool`.
3. Commit your changes and open a Pull Request.

When editing, keep the `.bat` file saved with **CRLF** line endings.

## 📄 License

This project is licensed under the [MIT License](LICENSE).