# Hardware Status Bar (`hardware_status_bar.ahk`)

A lightweight, zero-footprint system monitoring HUD built using AutoHotkey v2.0. It provides a clean, unobtrusive, always-on-top visual display of real-time CPU utilization, GPU load, and GPU temperature right at the top-centre of your primary display.

## 🛠️ Tech Stack & Architecture

* **Language:** AutoHotkey v2.0 (`#Requires AutoHotkey v2.0`)
* **UI Framework:** Native AHK borderless GUI (`+AlwaysOnTop -Caption +ToolWindow`) styled with a dark theme (`#1E1E1E`).
* **CPU Metrics:** Windows Management Instrumentation (WMI) via COM objects (`winmgmts:\\.\root\cimv2`) querying `Win32_PerfFormattedData_PerfOS_Processor`.
* **GPU Metrics:** NVIDIA System Management Interface (`nvidia-smi.exe`) CLI utility.
* **Performance & Caching:** Event-driven polling via `SetTimer` (1-second interval) with output redirection to a temporary cache file (`gpustats_cache.txt`) executed completely hidden to prevent window flashing and UI lag.

---

## 🔍 How It Works

### 1. Window Initialization & Centering
The script creates a minimalist window stripped of standard borders, captions, and taskbar distractions. It queries the primary monitor's dimensions dynamically using `SysGet(78)` and calculates exact coordinates via `WinMove` to snap itself perfectly to the top-centre of the screen.

### 2. Event-Driven Refresh Loop
A background timer (`SetTimer(UpdateStats, 1000)`) triggers a refresh every 1000 milliseconds. This ensures data is kept current without taxing system resources, maintaining an ultra-low memory footprint (<7MB RAM).

### 3. CPU Load Monitoring
The script leverages Windows WMI performance counters to query the `PercentProcessorTime` for the `_Total` processor instance, returning a clean, real-time integer percentage of total CPU usage.

### 4. GPU Metrics & Safe Caching
To fetch GPU statistics without triggering disruptive command prompt windows or blocking the UI thread:
* **Execution:** It locates `nvidia-smi.exe` (checking the default NVIDIA directory or falling back to the system path).
* **Caching:** It queries utilization and temperature (`--query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits`) and pipes the raw output straight into a temporary cache file using `RunWait` with the `"Hide"` flag.
* **Parsing & Safety:** The script reads the cache file, strips out invisible Windows carriage returns and newlines (`\r\n`), safely casts values to numbers, rounds the temperature to a clean integer, and formats the output string with a proper degree symbol (`Chr(176)`).

* # Quick Screen Capture (`quickScreenCapture.ahk`)

A slick, lightweight screen region capture utility built using AutoHotkey v2.0[cite: 9]. By holding Ctrl and dragging with the right mouse button, it draws a live selection box and instantly copies the targeted screen area straight to your Windows clipboard[cite: 9].

## 🛠️ Tech Stack & Architecture

* **Language:** AutoHotkey v2.0 (`#Requires AutoHotkey v2.0`)[cite: 9].
* **UI/Overlay Framework:** Native AHK borderless, transparent, click-through window (`+AlwaysOnTop -Caption +ToolWindow +E0x08000000`) styled with a pastel mint green background (`#B5EAD7`)[cite: 9].
* **Capture Engine:** Embedded PowerShell automation leveraging .NET Framework libraries (`System.Drawing` and `System.Windows.Forms`)[cite: 9].
* **Execution:** Event-driven hotkey binding with background PowerShell execution routed via the hidden `"Hide"` flag[cite: 9].

---

## 🔍 How It Works

### 1. Hotkey & Overlay Initialization
The script triggers on `^RButton` (Ctrl + Right Click)[cite: 9]. It anchors coordinate tracking globally using `CoordMode("Mouse", "Screen")`[cite: 9] and spawns a minimalist GUI overlay configured to be completely transparent to mouse clicks (`+E0x08000000`), ensuring it never steals focus or interferes with underlying windows[cite: 9].

### 2. Live Drag-to-Select Loop
While the right mouse button is held down (`while GetKeyState("RButton", "P")`), a high-frequency loop tracks current mouse coordinates in real time, calculates absolute widths, heights, and origin bounds, and dynamically resizes and redraws the selection box using `myGui.Show()` with a responsive 10ms sleep interval[cite: 9].

### 3. Accidental Click Protection
Upon releasing the mouse button, the overlay window is immediately destroyed[cite: 9]. A built-in validation check evaluates the dimensions (`if (w < 5 || h < 5) return`), aborting the routine if it detects an accidental zero-pixel or micro-selection[cite: 9].

### 4. .NET Screen Copy & Clipboard Injection
Instead of relying on heavy external dependencies, the script builds and executes a lean PowerShell one-liner[cite: 9]. It initializes a .NET drawing bitmap matching the custom width and height, copies the precise pixel buffer from the screen using `[Drawing.Graphics]::FromImage` and `CopyFromScreen`, and pushes the final graphic right into the Windows clipboard via `[Windows.Forms.Clipboard]::SetImage`[cite: 9].
