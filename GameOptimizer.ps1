# ===============================
# GAME OPTIMIZER V7 CLEAN
# ===============================

$validKey = "Fade"

Add-Type -AssemblyName System.Windows.Forms

# ===== ADMIN =====
$admin = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $admin.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "Run as Administrator!" -ForegroundColor Red
    pause
    exit
}

# ===== KEY (NO SAVE) =====
Clear-Host
Write-Host "======== ENTER KEY ========" -ForegroundColor Yellow
$key = Read-Host "Key"

if ($key -ne $validKey) {
    Write-Host "INVALID KEY!" -ForegroundColor Red
    pause
    exit
}

# ===============================
function Banner {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor DarkGreen
    Write-Host "               Fadex3D       " -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor DarkGreen
    Write-Host ""
}

# ===============================
function Select-Game {
    Write-Host "====== SELECT setting ======" -ForegroundColor Cyan
    Write-Host "[1] Fadx3D"
    Write-Host "[2] XPLUS"
    Write-Host "[3] F cri"
    Write-Host "[4] Auto "
    Write-Host "[5] Cri 100"
    Write-Host "[0] Back"

    $g = Read-Host "Select"

    switch ($g) {
        "1" { return "FiveM" }
        "2" { return "PUBG" }
        "3" { return "Valorant" }
        "4" { return "CSGO" }
        "5" {
            $name = Read-Host "Enter name"
            if ($name -match "^[a-zA-Z0-9]+$") { return $name }
            else { return Select-Game }
        }
        default { return $null }
    }
}

# ===============================
function Pick-Exe {
    $f = New-Object Windows.Forms.OpenFileDialog
    $f.Filter = "Game EXE (*.exe)|*.exe"
    $null = $f.ShowDialog()
    return $f.FileName
}

# ===============================
function Loading {
    for ($i=1; $i -le 100; $i+=5) {
        Write-Progress -Activity "Applying Tweaks" -Status "$i%" -PercentComplete $i
        Start-Sleep -Milliseconds 40
    }
}

# ===============================
function Apply-QoS($name,$exe) {
    $exeName = [System.IO.Path]::GetFileName($exe)

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\$name" /v "Application Name" /t REG_SZ /d "$exeName" /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\$name" /v "DSCP Value" /t REG_SZ /d "46" /f | Out-Null
}

# ===============================
function Apply-Network {

    netsh int tcp set global netdma=enabled | Out-Null
    netsh int tcp set global dca=enabled | Out-Null

    netsh int tcp set global rss=enabled | Out-Null
    netsh int tcp set global chimney=disabled | Out-Null
    netsh int tcp set global rsc=disabled | Out-Null

    netsh int tcp set global autotuninglevel=restricted | Out-Null
    netsh int tcp set global timestamps=disabled | Out-Null
    netsh int tcp set global fastopen=enabled | Out-Null

    netsh int tcp set heuristics disabled | Out-Null
    netsh int tcp set supplemental template=internet congestionprovider=ctcp | Out-Null

    netsh int ipv4 set glob defaultcurhoplimit=86 | Out-Null
    netsh int ipv6 set glob defaultcurhoplimit=86 | Out-Null
}

# ===============================
function Apply-Registry {

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f | Out-Null

    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 8 /f | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 1000 /f | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d 1 /f | Out-Null

    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f | Out-Null

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DPCQueueDepth /t REG_DWORD /d 100 /f | Out-Null
}

# ===============================
while ($true) {

    Banner

    Write-Host "[1] select " -ForegroundColor Cyan
    Write-Host "[2] Network " -ForegroundColor Cyan
    Write-Host "[3] REG " -ForegroundColor Cyan
    Write-Host "[0] Exit" -ForegroundColor Red
    Write-Host ""

    $c = Read-Host "Select"

    if ($c -eq "1") {

        $game = Select-Game
        if (-not $game) { continue }

        $exe = Pick-Exe
        if (-not $exe) { continue }

        Loading

        Apply-QoS $game $exe
        Apply-Network
        Apply-Registry

        Write-Host "DONE FULL OPTIMIZE!" -ForegroundColor Green
        pause
    }

    if ($c -eq "2") {
        Apply-Network
        pause
    }

    if ($c -eq "3") {
        Apply-Registry
        pause
    }

    if ($c -eq "0") { break }
}
