#Requires AutoHotkey v2.0
#SingleInstance Force

; Create a borderless, always-on-top GUI window
MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "SysMonitor")
MyGui.BackColor := "1E1E1E"

; Add text controls with Center alignment and generous widths
CpuText := MyGui.Add("Text", "CWhite w130 Center", "CPU: --%")
GpuText := MyGui.Add("Text", "CWhite x+10 w200 Center", "GPU: --% (--" . Chr(176) . "C)")

MyGui.Show("AutoSize NA")

; Position at top-centre of primary monitor (recalculated for new width ~350px)
screenWidth := SysGet(78) 
WinMove((screenWidth - 350) / 2, 0, , , "SysMonitor")

; Set a timer to update stats every 1000ms
SetTimer(UpdateStats, 1000)

UpdateStats() {
    try {
        cpuLoad := GetCpuUsage()
        gpuData := GetGpuStats()

        CpuText.Value := "CPU: " . cpuLoad . "%"
        GpuText.Value := "GPU: " . gpuData.load . "% (" . gpuData.temp . Chr(176) . "C)"
    }
}

GetCpuUsage() {
    try {
        for objItem in ComObjGet("winmgmts:\\.\root\cimv2").ExecQuery("SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfOS_Processor WHERE Name='_Total'") {
            return objItem.PercentProcessorTime
        }
    }
    return "--"
}

GetGpuStats() {
    static tempFile := A_Temp . "\gpustats_cache.txt"
    try {
        nvsmi := "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"
        cmd := FileExist(nvsmi) ? nvsmi : "nvidia-smi"
        
        ; Run completely hidden by redirecting output to a temp file with the "Hide" option
        RunWait('"' . A_ComSpec . '" /c "' . cmd . ' --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits > "' . tempFile . '""', , "Hide")
        
        if FileExist(tempFile) {
            output := FileRead(tempFile)
            if (Trim(output, " `t`r`n") != "") {
                parts := StrSplit(Trim(output, " `t`r`n"), ",")
                if (parts.Length >= 2) {
                    gpuLoad := Trim(parts[1], " `t`r`n")
                    gpuTemp := Round(Number(Trim(parts[2], " `t`r`n")), 0)
                    return { 
                        load: (gpuLoad != "" ? gpuLoad : "--"), 
                        temp: (gpuTemp != "" ? gpuTemp : "--") 
                    }
                }
            }
        }
    }
    return { load: "--", temp: "--" }
}