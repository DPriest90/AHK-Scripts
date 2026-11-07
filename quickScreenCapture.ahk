#Requires AutoHotkey v2.0
CoordMode("Mouse", "Screen")

; Hold Ctrl + Right Click and drag to capture screen region to clipboard
^RButton:: {
    MouseGetPos(&startX, &startY)
    myGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000") ; Transparent click-through
    myGui.BackColor := "B5EAD7" ; Pastel mint green
    
    while GetKeyState("RButton", "P") {
        MouseGetPos(&currentX, &currentY)
        x := Min(startX, currentX), y := Min(startY, currentY)
        w := Abs(startX - currentX), h := Abs(startY - currentY)
        myGui.Show("NA x" x " y" y " w" w " h" h)
        Sleep(10)
    }
    myGui.Destroy()
    
    ; Prevent accidental zero-pixel captures
    if (w < 5 || h < 5)
        return
    
    ; Build PowerShell command to capture screen and set directly to clipboard
    psCmd := 'Add-Type -AssemblyName System.Drawing, System.Windows.Forms; '
           . '$bmp = New-Object Drawing.Bitmap ' w ', ' h '; '
           . '$gfx = [Drawing.Graphics]::FromImage($bmp); '
           . '$gfx.CopyFromScreen(' x ', ' y ', 0, 0, $bmp.Size); '
           . '[Windows.Forms.Clipboard]::SetImage($bmp);'
           
    ; Run PowerShell hidden in the background
    Run('powershell -NoProfile -Command "' psCmd '"', , "Hide")
}