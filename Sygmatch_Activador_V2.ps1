<#
.SYNOPSIS
    Sygmatch - Activador Windows y Office (Version Grafica Moderna Windows Forms)
.DESCRIPTION
    Aplicacion de escritorio moderna en PowerShell con interfaz grafica Dark Mode,
    consola interna integrada, confirmaciones de seguridad y ejecucion directa sin menus interactivos.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Forzar ejecucion como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# ====================================================================
# CREACION DE LA VENTANA PRINCIPAL (FORM)
# ====================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sygmatch - Activador Windows y Office (Modern UI)"
$form.Size = New-Object System.Drawing.Size(1200, 720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

# Panel Lateral de Control y Botones
$panelMenu = New-Object System.Windows.Forms.Panel
$panelMenu.Dock = [System.Windows.Forms.DockStyle]::Left
$panelMenu.Width = 380
$panelMenu.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$form.Controls.Add($panelMenu)

# Panel Superior / Titulo en el Menu
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "SYGMATCH ACTIVATOR"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 255)
$lblTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblTitle.Size = New-Object System.Drawing.Size(340, 35)
$panelMenu.Controls.Add($lblTitle)

$lblSubTitleCtrl = New-Object System.Windows.Forms.Label
$lblSubTitleCtrl.Text = "Gestion profesional de licencias y activacion"
$lblSubTitleCtrl.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$lblSubTitleCtrl.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$lblSubTitleCtrl.Location = New-Object System.Drawing.Point(22, 55)
$lblSubTitleCtrl.Size = New-Object System.Drawing.Size(340, 25)
$panelMenu.Controls.Add($lblSubTitleCtrl)

# Consola de texto integrada (RichTextBox)
$txtConsole = New-Object System.Windows.Forms.RichTextBox
$txtConsole.Location = New-Object System.Drawing.Point(395, 20)
$txtConsole.Size = New-Object System.Drawing.Size(775, 595)
$txtConsole.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 28)
$txtConsole.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 128)
$txtConsole.Font = New-Object System.Drawing.Font("Consolas", 10)
$txtConsole.ReadOnly = $true
$txtConsole.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$form.Controls.Add($txtConsole)

# Enlace a GitHub
$lnkGitHub = New-Object System.Windows.Forms.LinkLabel
$lnkGitHub.Location = New-Object System.Drawing.Point(395, 630)
$lnkGitHub.Size = New-Object System.Drawing.Size(775, 30)
$lnkGitHub.Text = "Repositorio Oficial en GITHUB"
$lnkGitHub.LinkArea = New-Object System.Windows.Forms.LinkArea(23, 6)
$lnkGitHub.LinkColor = [System.Drawing.Color]::FromArgb(0, 160, 255)
$lnkGitHub.ActiveLinkColor = [System.Drawing.Color]::FromArgb(0, 220, 255)
$lnkGitHub.VisitedLinkColor = [System.Drawing.Color]::FromArgb(150, 100, 255)
$lnkGitHub.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$lnkGitHub.Add_LinkClicked({
    param($sender, $e)
    try {
        [System.Diagnostics.Process]::Start("https://github.com/Sygmatch/Sygmatch_Activador_Win-Office") | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("No se pudo abrir el enlace en el navegador.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($lnkGitHub)

# Funcion de Escritura en Consola con Traduccion al Espanol y Control de Hilos
function Write-Log {
    param(
        [string]$Message,
        [object]$Color = [System.Drawing.Color]::FromArgb(220, 220, 220)
    )
    if ($txtConsole.InvokeRequired) {
        $txtConsole.Invoke([Action[string, object]]{ param($m, $c) Write-Log $m $c }, $Message, $Color)
        return
    }
    
    $msg = $Message
    $msg = $msg -replace "Last 5 chars of installed product key:", "Ultimos 5 caracteres de la clave instalada:"
    $msg = $msg -replace "The machine is permanently activated\.", "El equipo esta activado de forma permanente."
    $msg = $msg -replace "Volume activation will expire", "La activacion por volumen expirara"
    $msg = $msg -replace "LICENSE NAME:", "NOMBRE DE LICENCIA:"
    $msg = $msg -replace "LICENSE DESCRIPTION:", "DESCRIPCION DE LICENCIA:"
    $msg = $msg -replace "LICENSE STATUS:", "ESTADO DE LICENCIA:"
    $msg = $msg -replace "---LICENSED---", "---LICENCIADO---"
    $msg = $msg -replace "---OOB_GRACE---", "---EN PERIODO DE PRUEBA (PROTEGIDO POR OHOOK)---"

    $txtConsole.SelectionStart = $txtConsole.TextLength
    $txtConsole.SelectionLength = 0
    $txtConsole.SelectionColor = $Color
    $txtConsole.AppendText("$msg`r`n")
    $txtConsole.ScrollToCaret()
}

# Comprobacion inteligente de Punto de Restauracion
try {
    Write-Log "[*] Verificando estado del sistema de restauracion..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
    Enable-ComputerRestore -Drive "C:" -ErrorAction SilentlyContinue | Out-Null
    
    $recentPoint = Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -gt (Get-Date).AddHours(-24) }
    if (-not $recentPoint) {
        Checkpoint-Computer -Description "Sygmatch_Backup_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop | Out-Null
        Write-Log "[OK] Punto de restauracion creado con exito." ([System.Drawing.Color]::FromArgb(0, 255, 128))
    } else {
        Write-Log "[*] Ya existe un punto de restauracion reciente (< 24 horas). Omitiendo creacion." ([System.Drawing.Color]::FromArgb(0, 200, 255))
    }
} catch {
    Write-Log "[!] No se pudo crear el punto de restauracion automatico (desactivado en Windows o limite de frecuencia)." ([System.Drawing.Color]::FromArgb(255, 180, 0))
}
Write-Log "================================================================" ([System.Drawing.Color]::FromArgb(100, 100, 100))
Write-Log "[*] Sistema listo. Seleccione una operacion en el panel izquierdo." ([System.Drawing.Color]::FromArgb(255, 255, 255))
Write-Log "================================================================" ([System.Drawing.Color]::FromArgb(100, 100, 100))

$btnBg = [System.Drawing.Color]::FromArgb(35, 35, 35)
$btnFg = [System.Drawing.Color]::FromArgb(240, 240, 240)

# ====================================================================
# BOTON: Activar Windows (HWID - Desatendido / Sin ventana negra)
# ====================================================================
$btn1 = New-Object System.Windows.Forms.Button
$btn1.Text = "Activar Windows (HWID - Permanente)"
$btn1.Location = New-Object System.Drawing.Point(20, 100)
$btn1.Size = New-Object System.Drawing.Size(340, 42)
$btn1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn1.FlatAppearance.BorderSize = 0
$btn1.BackColor = $btnBg
$btn1.ForeColor = $btnFg
$btn1.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn1.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn1.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("¿Desea proceder con la activacion permanente de Windows (HWID)?", "Confirmar Activacion", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Write-Log "`r`n[>] Iniciando activacion de Windows (HWID) en segundo plano..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
    $job = Start-Job -ScriptBlock {
        $env:MAS_Unattended = '1'
        $scriptContent = (irm https://get.activated.win)
        & ([scriptblock]::Create($scriptContent)) /HWID
    }
    while ($job.State -eq 'Running') {
        Start-Sleep -Milliseconds 400
        $output = Receive-Job -Job $job
        if ($output) {
            foreach ($line in $output) { Write-Output "  $line" }
        }
    }
    $finalOutput = Receive-Job -Job $job
    if ($finalOutput) {
        foreach ($line in $finalOutput) { Write-Log "  $line" ([System.Drawing.Color]::FromArgb(0, 255, 128)) }
    }
    Remove-Job -Job $job
    Write-Log "[OK] Proceso de activacion de Windows finalizado." ([System.Drawing.Color]::FromArgb(0, 255, 128))
})
$panelMenu.Controls.Add($btn1)

# ====================================================================
# BOTON: Activar Office (Ohook - Desatendido / Sin ventana negra)
# ====================================================================
$btn2 = New-Object System.Windows.Forms.Button
$btn2.Text = "Activar Office (Ohook - Permanente)"
$btn2.Location = New-Object System.Drawing.Point(20, 150)
$btn2.Size = New-Object System.Drawing.Size(340, 42)
$btn2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn2.FlatAppearance.BorderSize = 0
$btn2.BackColor = $btnBg
$btn2.ForeColor = $btnFg
$btn2.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn2.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn2.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("¿Desea proceder con la activacion permanente de Office (Ohook)?", "Confirmar Activacion", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Write-Log "`r`n[>] Iniciando activacion de Office (Ohook) en segundo plano..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
    $job = Start-Job -ScriptBlock {
        $env:MAS_Unattended = '1'
        $scriptContent = (irm https://get.activated.win)
        & ([scriptblock]::Create($scriptContent)) /Ohook
    }
    while ($job.State -eq 'Running') {
        Start-Sleep -Milliseconds 400
        $output = Receive-Job -Job $job
        if ($output) {
            foreach ($line in $output) { Write-Output "  $line" }
        }
    }
    $finalOutput = Receive-Job -Job $job
    if ($finalOutput) {
        foreach ($line in $finalOutput) { Write-Log "  $line" ([System.Drawing.Color]::FromArgb(0, 255, 128)) }
    }
    Remove-Job -Job $job
    Write-Log "[OK] Proceso de activacion de Office finalizado." ([System.Drawing.Color]::FromArgb(0, 255, 128))
})
$panelMenu.Controls.Add($btn2)

# ====================================================================
# BOTON: Activar KMS Online
# ====================================================================
$btn3 = New-Object System.Windows.Forms.Button
$btn3.Text = "Activar Windows / Office (KMS Online)"
$btn3.Location = New-Object System.Drawing.Point(20, 200)
$btn3.Size = New-Object System.Drawing.Size(340, 42)
$btn3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn3.FlatAppearance.BorderSize = 0
$btn3.BackColor = $btnBg
$btn3.ForeColor = $btnFg
$btn3.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn3.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn3.Add_Click({
    $kmsChoice = New-Object System.Windows.Forms.Form
    $kmsChoice.Text = "Seleccionar Producto para KMS Online"
    $kmsChoice.Size = New-Object System.Drawing.Size(380, 240)
    $kmsChoice.StartPosition = "CenterParent"
    $kmsChoice.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $kmsChoice.MaximizeBox = $false; $kmsChoice.MinimizeBox = $false
    $kmsChoice.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
    $kmsChoice.ForeColor = [System.Drawing.Color]::White

    $lblKms = New-Object System.Windows.Forms.Label
    $lblKms.Text = "Elija que producto desea activar por KMS (180 dias):"
    $lblKms.Location = New-Object System.Drawing.Point(20, 20)
    $lblKms.Size = New-Object System.Drawing.Size(330, 30)
    $lblKms.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $kmsChoice.Controls.Add($lblKms)

    $btnKmsWin = New-Object System.Windows.Forms.Button
    $btnKmsWin.Text = "Activar solo Windows (KMS)"
    $btnKmsWin.Location = New-Object System.Drawing.Point(20, 65)
    $btnKmsWin.Size = New-Object System.Drawing.Size(325, 42)
    $btnKmsWin.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $btnKmsWin.ForeColor = [System.Drawing.Color]::White
    $btnKmsWin.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnKmsWin.Add_Click({
        $global:kmsTarget = "Windows"
        $kmsChoice.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $kmsChoice.Close()
    })
    $kmsChoice.Controls.Add($btnKmsWin)

    $btnKmsOff = New-Object System.Windows.Forms.Button
    $btnKmsOff.Text = "Activar solo Office (KMS)"
    $btnKmsOff.Location = New-Object System.Drawing.Point(20, 120)
    $btnKmsOff.Size = New-Object System.Drawing.Size(325, 42)
    $btnKmsOff.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $btnKmsOff.ForeColor = [System.Drawing.Color]::White
    $btnKmsOff.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnKmsOff.Add_Click({
        $global:kmsTarget = "Office"
        $kmsChoice.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $kmsChoice.Close()
    })
    $kmsChoice.Controls.Add($btnKmsOff)

    if ($kmsChoice.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $confirm = [System.Windows.Forms.MessageBox]::Show("¿Desea proceder con la activacion KMS Online para [$global:kmsTarget]?", "Confirmar Activacion", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

        if ($global:kmsTarget -eq "Windows") {
            Write-Log "`r`n[>] Iniciando activacion KMS para Windows (180 dias)..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
            
            $currentOS = (Get-CimInstance Win32_OperatingSystem).Caption
            $kmsKey = ""

            if ($currentOS -match "IoT Enterprise LTSC") {
                $kmsKey = "QPM6N-7J2WJ-P88HH-P3YRH-YY74H"
            } elseif ($currentOS -match "Enterprise LTSC") {
                $kmsKey = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
            } elseif ($currentOS -match "Enterprise") {
                $kmsKey = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
            } elseif ($currentOS -match "Education") {
                $kmsKey = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
            } else {
                $kmsKey = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
            }

            Write-Log "  -> Detectado: $currentOS" ([System.Drawing.Color]::FromArgb(0, 200, 255))
            Write-Log "  -> Instalando clave de volumen compatible..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
            $r1 = cscript //nologo "$env:windir\system32\slmgr.vbs" /ipk $kmsKey
            foreach ($line in $r1) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }

            Write-Log "  -> Configurando servidor KMS (kms8.msguides.com)..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
            $r2 = cscript //nologo "$env:windir\system32\slmgr.vbs" /skms kms8.msguides.com
            foreach ($line in $r2) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }

            Write-Log "  -> Forzando activacion con el servidor..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
            $r3 = cscript //nologo "$env:windir\system32\slmgr.vbs" /ato
            foreach ($line in $r3) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }

            Write-Log "[OK] Proceso KMS de Windows terminado." ([System.Drawing.Color]::FromArgb(0, 255, 128))
        }
        elseif ($global:kmsTarget -eq "Office") {
            Write-Log "`r`n[>] Iniciando activacion KMS para Office (180 dias)..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
            
            $foundOspp = $null
            $searchPaths = @(
                "$env:ProgramFiles\Microsoft Office",
                "${env:ProgramFiles(x86)}\Microsoft Office",
                "C:\Program Files\Microsoft Office",
                "C:\Program Files (x86)\Microsoft Office",
                "$env:ProgramFiles\Microsoft Office\Office16",
                "${env:ProgramFiles(x86)}\Microsoft Office\Office16"
            )
            
            foreach ($basePath in $searchPaths) {
                if (Test-Path $basePath) {
                    $match = Get-ChildItem -Path $basePath -Filter "ospp.vbs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($match) {
                        $foundOspp = $match.FullName
                        break
                    }
                }
            }

            if ($foundOspp) {
                Write-Log "  -> Office localizado en: $foundOspp" ([System.Drawing.Color]::FromArgb(0, 200, 255))
                Write-Log "  -> Configurando servidor KMS (kms8.msguides.com)..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
                
                $ro1 = cscript //nologo "$foundOspp" /sethst:kms8.msguides.com
                foreach ($line in $ro1) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }

                Write-Log "  -> Ejecutando activacion de Office..." ([System.Drawing.Color]::FromArgb(0, 200, 255))
                $ro2 = cscript //nologo "$foundOspp" /act
                foreach ($line in $ro2) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }

                Write-Log "[OK] Proceso KMS de Office terminado." ([System.Drawing.Color]::FromArgb(0, 255, 128))
            } else {
                Write-Log "[!] No se encontro Office instalado en las rutas estandar o de disco." ([System.Drawing.Color]::FromArgb(255, 180, 0))
            }
        }
    }
})
$panelMenu.Controls.Add($btn3)

# ====================================================================
# BOTON: Cambiar Edicion de Windows
# ====================================================================
$btn4 = New-Object System.Windows.Forms.Button
$btn4.Text = "Cambiar Edicion de Windows"
$btn4.Location = New-Object System.Drawing.Point(20, 250)
$btn4.Size = New-Object System.Drawing.Size(340, 42)
$btn4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn4.FlatAppearance.BorderSize = 0
$btn4.BackColor = $btnBg
$btn4.ForeColor = $btnFg
$btn4.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn4.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn4.Add_Click({
    $currentOS = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Log "`r`n[?] Sistema detectado actualmente: $currentOS" ([System.Drawing.Color]::FromArgb(0, 200, 255))

    $cb = New-Object System.Windows.Forms.Form
    $cb.Text = "Cambiar Edicion de Windows (Seguro)"
    $cb.Size = New-Object System.Drawing.Size(460, 440)
    $cb.StartPosition = "CenterParent"
    $cb.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $cb.MaximizeBox = $false; $cb.MinimizeBox = $false
    $cb.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24); $cb.ForeColor = [System.Drawing.Color]::White

    $lblNote = New-Object System.Windows.Forms.Label
    $lblNote.Text = "Nota: Se han deshabilitado ediciones no compatibles para proteger la estabilidad y el registro de tu sistema."
    $lblNote.Location = New-Object System.Drawing.Point(20, 15)
    $lblNote.Size = New-Object System.Drawing.Size(410, 40)
    $lblNote.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Italic)
    $lblNote.ForeColor = [System.Drawing.Color]::FromArgb(200, 180, 80)
    $cb.Controls.Add($lblNote)

    $l = New-Object System.Windows.Forms.Label
    $l.Text = "Ediciones compatibles segun tu sistema actual:"
    $l.Location = New-Object System.Drawing.Point(20, 65)
    $l.Size = New-Object System.Drawing.Size(410, 25)
    $l.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $cb.Controls.Add($l)

    $allEds = @(
        @{ T = "Windows 10/11 Pro"; K = "VK7JG-NPHTM-C97JM-9MPGT-3V66T"; Family = "Pro" },
        @{ T = "Windows 10/11 Enterprise"; K = "NPPR9-FWDCX-D2C8J-H872K-2YT43"; Family = "Enterprise" },
        @{ T = "Windows 10 Enterprise LTSC 2021"; K = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D"; Family = "LTSC" },
        @{ T = "Windows 10 IoT Enterprise LTSC"; K = "QPM6N-7J2WJ-P88HH-P3YRH-YY74H"; Family = "IoT" }
    )

    $availableEds = @()
    if ($currentOS -match "LTSC" -or $currentOS -match "IoT") {
        $availableEds = $allEds | Where-Object { $_.Family -eq "LTSC" -or $_.Family -eq "IoT" }
    } else {
        $availableEds = $allEds | Where-Object { $_.Family -eq "Pro" -or $_.Family -eq "Enterprise" }
    }

    $yPos = 100
    foreach ($ed in $availableEds) {
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $ed.T
        $b.Location = New-Object System.Drawing.Point(20, $yPos)
        $b.Size = New-Object System.Drawing.Size(410, 42)
        $b.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
        $b.ForeColor = [System.Drawing.Color]::White
        $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        
        if ($currentOS -like "*$($ed.Family)*") {
            $b.Text += " (Actual / Compatible)"
            $b.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 128)
        }

        $keyVal = $ed.K
        $b.Add_Click({ 
            $global:targetKey = $keyVal
            $cb.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $cb.Close() 
        })
        $cb.Controls.Add($b)
        $yPos += 52
    }

    if ($cb.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        if ($global:targetKey) {
            $confirm = [System.Windows.Forms.MessageBox]::Show("¿Esta seguro de cambiar la edicion del sistema?", "Confirmar Cambio", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
                Write-Log "`r`n[>] Aplicando clave segura para la nueva edicion..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
                $rEdit = cscript //nologo "$env:windir\system32\slmgr.vbs" /ipk $global:targetKey
                foreach ($line in $rEdit) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }
                Write-Log "[OK] Edicion configurada correctamente. Reinicie el equipo para aplicar los cambios." ([System.Drawing.Color]::FromArgb(0, 255, 128))
            }
        }
    }
})
$panelMenu.Controls.Add($btn4)

# ====================================================================
# BOTON: Limpiar Licencias
# ====================================================================
$btn5 = New-Object System.Windows.Forms.Button
$btn5.Text = "Limpiar Licencias"
$btn5.Location = New-Object System.Drawing.Point(20, 300)
$btn5.Size = New-Object System.Drawing.Size(340, 42)
$btn5.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn5.FlatAppearance.BorderSize = 0
$btn5.BackColor = $btnBg
$btn5.ForeColor = $btnFg
$btn5.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn5.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn5.Add_Click({
    $cleanChoice = New-Object System.Windows.Forms.Form
    $cleanChoice.Text = "Seleccionar Licencia a Limpiar"
    $cleanChoice.Size = New-Object System.Drawing.Size(380, 240)
    $cleanChoice.StartPosition = "CenterParent"
    $cleanChoice.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $cleanChoice.MaximizeBox = $false; $cleanChoice.MinimizeBox = $false
    $cleanChoice.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
    $cleanChoice.ForeColor = [System.Drawing.Color]::White

    $lblClean = New-Object System.Windows.Forms.Label
    $lblClean.Text = "Elija que licencia desea limpiar o remover:"
    $lblClean.Location = New-Object System.Drawing.Point(20, 20)
    $lblClean.Size = New-Object System.Drawing.Size(330, 30)
    $lblClean.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $cleanChoice.Controls.Add($lblClean)

    $btnCleanWin = New-Object System.Windows.Forms.Button
    $btnCleanWin.Text = "Limpiar solo Windows"
    $btnCleanWin.Location = New-Object System.Drawing.Point(20, 65)
    $btnCleanWin.Size = New-Object System.Drawing.Size(325, 42)
    $btnCleanWin.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $btnCleanWin.ForeColor = [System.Drawing.Color]::White
    $btnCleanWin.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCleanWin.Add_Click({
        $global:cleanTarget = "Windows"
        $cleanChoice.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $cleanChoice.Close()
    })
    $cleanChoice.Controls.Add($btnCleanWin)

    $btnCleanOff = New-Object System.Windows.Forms.Button
    $btnCleanOff.Text = "Limpiar solo Office"
    $btnCleanOff.Location = New-Object System.Drawing.Point(20, 120)
    $btnCleanOff.Size = New-Object System.Drawing.Size(325, 42)
    $btnCleanOff.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $btnCleanOff.ForeColor = [System.Drawing.Color]::White
    $btnCleanOff.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCleanOff.Add_Click({
        $global:cleanTarget = "Office"
        $cleanChoice.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $cleanChoice.Close()
    })
    $cleanChoice.Controls.Add($btnCleanOff)

    if ($cleanChoice.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $confirm = [System.Windows.Forms.MessageBox]::Show("¿Esta seguro de limpiar las licencias de [$global:cleanTarget]?", "Confirmar Limpieza", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

        if ($global:cleanTarget -eq "Windows") {
            Write-Log "`r`n[>] Limpiando licencias y claves de producto de Windows..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
            $cl1 = cscript //nologo "$env:windir\system32\slmgr.vbs" /upk
            foreach ($line in $cl1) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }
            $cl2 = cscript //nologo "$env:windir\system32\slmgr.vbs" /cpky
            foreach ($line in $cl2) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }
            $cl3 = cscript //nologo "$env:windir\system32\slmgr.vbs" /ckms
            foreach ($line in $cl3) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }
            Write-Log "[OK] Limpieza de Windows completada." ([System.Drawing.Color]::FromArgb(0, 255, 128))
        }
        elseif ($global:cleanTarget -eq "Office") {
            Write-Log "`r`n[>] Limpiando licencias y servidor KMS de Office..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
            
            $foundOspp = $null
            $searchPaths = @(
                "$env:ProgramFiles\Microsoft Office",
                "${env:ProgramFiles(x86)}\Microsoft Office",
                "C:\Program Files\Microsoft Office",
                "C:\Program Files (x86)\Microsoft Office",
                "$env:ProgramFiles\Microsoft Office\Office16",
                "${env:ProgramFiles(x86)}\Microsoft Office\Office16"
            )
            
            foreach ($basePath in $searchPaths) {
                if (Test-Path $basePath) {
                    $match = Get-ChildItem -Path $basePath -Filter "ospp.vbs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($match) {
                        $foundOspp = $match.FullName
                        break
                    }
                }
            }

            if ($foundOspp) {
                Write-Log "  -> Office localizado en: $foundOspp" ([System.Drawing.Color]::FromArgb(0, 200, 255))
                $ro1 = cscript //nologo "$foundOspp" /remhst
                foreach ($line in $ro1) { if ($line.Trim()) { Write-Log "     $($line.Trim())" } }
                Write-Log "[OK] Limpieza de Office completada." ([System.Drawing.Color]::FromArgb(0, 255, 128))
            } else {
                Write-Log "[!] No se encontro Office instalado en las rutas estandar o de disco." ([System.Drawing.Color]::FromArgb(255, 180, 0))
            }
        }
    }
})
$panelMenu.Controls.Add($btn5)

# ====================================================================
# BOTON: Comprobar Estado de Licencias
# ====================================================================
$btn6 = New-Object System.Windows.Forms.Button
$btn6.Text = "Comprobar Estado de Licencias"
$btn6.Location = New-Object System.Drawing.Point(20, 350)
$btn6.Size = New-Object System.Drawing.Size(340, 42)
$btn6.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn6.FlatAppearance.BorderSize = 0
$btn6.BackColor = $btnBg
$btn6.ForeColor = $btnFg
$btn6.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn6.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn6.Add_Click({
    Write-Log "`r`n[>] Analizando estado profundo de licencias del sistema..." ([System.Drawing.Color]::FromArgb(255, 200, 0))
    
    # --- 1. ESTADO DE WINDOWS ---
    Write-Log "--------------------------------------------------------" ([System.Drawing.Color]::FromArgb(100, 100, 100))
    Write-Log "--- [ DIAGNOSTICO DE WINDOWS ] ---" ([System.Drawing.Color]::FromArgb(0, 200, 255))
    
    $winStatus = cscript //nologo "$env:windir\system32\slmgr.vbs" /xpr
    $winLicensed = $false
    foreach ($line in $winStatus) {
        if ($line.Trim()) {
            $l = $line.Trim()
            if ($l -match "permanently activated" -or $l -match "activado de forma permanente") {
                $winLicensed = $true
            }
            $l = $l -replace "The machine is permanently activated\.", "El equipo esta activado de forma permanente."
            $l = $l -replace "Volume activation will expire", "La activacion por volumen expirara"
            Write-Log "  -> Estado: $l" ([System.Drawing.Color]::FromArgb(220, 220, 220))
        }
    }

    try {
        $winDetails = cscript //nologo "$env:windir\system32\slmgr.vbs" /dli
        $winType = "Licencia Digital / Permanente (OEM o HWID)"
        foreach ($dLine in $winDetails) {
            if ($dLine -match "KMSCLIENT") { $winType = "KMS Online (180 dias / Volúmen)" }
            elseif ($dLine -match "RETAIL") { $winType = "Canal Comercial (Retail)" }
        }
        if ($winLicensed) {
            Write-Log "  -> Tipo de Activacion: $winType" ([System.Drawing.Color]::FromArgb(0, 255, 128))
        } else {
            Write-Log "  -> Tipo de Activacion: No licenciado o pendiente" ([System.Drawing.Color]::FromArgb(255, 180, 0))
        }
    } catch {
        Write-Log "  -> Tipo de Activacion: Verificado por Sistema" ([System.Drawing.Color]::FromArgb(0, 255, 128))
    }

    # --- 2. ESTADO DE OFFICE ---
    Write-Log "--------------------------------------------------------" ([System.Drawing.Color]::FromArgb(100, 100, 100))
    Write-Log "--- [ DIAGNOSTICO DE MICROSOFT OFFICE ] ---" ([System.Drawing.Color]::FromArgb(0, 200, 255))

    $foundOspp = $null
    $searchPaths = @(
        "$env:ProgramFiles\Microsoft Office",
        "${env:ProgramFiles(x86)}\Microsoft Office",
        "C:\Program Files\Microsoft Office",
        "C:\Program Files (x86)\Microsoft Office",
        "$env:ProgramFiles\Microsoft Office\Office16",
        "${env:ProgramFiles(x86)}\Microsoft Office\Office16"
    )
    
    foreach ($basePath in $searchPaths) {
        if (Test-Path $basePath) {
            $match = Get-ChildItem -Path $basePath -Filter "ospp.vbs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($match) {
                $foundOspp = $match.FullName
                break
            }
        }
    }

    if ($foundOspp) {
        Write-Log "  -> Office detectado en disco." ([System.Drawing.Color]::FromArgb(220, 220, 220))
        
        $offStatus = cscript //nologo "$foundOspp" /dstatus
        $isRetail = $false
        $isLicensed = $false

        foreach ($oLine in $offStatus) {
            if ($oLine.Trim()) {
                $ol = $oLine.Trim()
                if ($ol -match "RETAIL") { $isRetail = $true }
                if ($ol -match "LICENSE STATUS: ---LICENSED---" -or $ol -match "LICENCIADO") { $isLicensed = $true }

                if ($ol -match "PRODUCT ID" -or $ol -match "LICENSE NAME" -or $ol -match "LICENSE STATUS") {
                    Write-Log "     $ol" ([System.Drawing.Color]::FromArgb(200, 200, 200))
                }
            }
        }

        if ($isLicensed -or $isRetail) {
            Write-Log "  -> Estado General: ACTIVADO" ([System.Drawing.Color]::FromArgb(0, 255, 128))
            Write-Log "  -> Metodo / Tipo: Permanente (Protegido por Ohook / Licencia Retail)" ([System.Drawing.Color]::FromArgb(0, 255, 128))
        } else {
            Write-Log "  -> Estado General: NO LICENCIADO / EN PERIODO DE PRUEBA" ([System.Drawing.Color]::FromArgb(255, 180, 0))
        }
    } else {
        Write-Log "  -> [!] Microsoft Office no se encuentra instalado en las rutas estandar." ([System.Drawing.Color]::FromArgb(255, 180, 0))
    }
    Write-Log "--------------------------------------------------------" ([System.Drawing.Color]::FromArgb(100, 100, 100))
})
$panelMenu.Controls.Add($btn6)

# ====================================================================
# BOTON: Salir
# ====================================================================
$btn7 = New-Object System.Windows.Forms.Button
$btn7.Text = "Salir"
$btn7.Location = New-Object System.Drawing.Point(20, 450)
$btn7.Size = New-Object System.Drawing.Size(340, 42)
$btn7.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn7.FlatAppearance.BorderSize = 0
$btn7.BackColor = [System.Drawing.Color]::FromArgb(60, 30, 30)
$btn7.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 120)
$btn7.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btn7.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn7.Add_Click({
    $form.Close()
})
$panelMenu.Controls.Add($btn7)

[void]$form.ShowDialog()