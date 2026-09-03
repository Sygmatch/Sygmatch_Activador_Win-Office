<#
.SYNOPSIS
    Sygmatch - Activador Windows y Office (Version PowerShell)
.DESCRIPTION
    Script moderno en PowerShell para gestion de activacion, licencias y punto de restauracion.
#>

# Forzar ejecucion como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host " [!] Este script requiere permisos de Administrador." -ForegroundColor Red
    Write-Host " [*] Reiniciando automaticamente como Administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$Host.UI.RawUI.WindowTitle = "Sygmatch - Activador Windows y Office (PowerShell)"

function Show-Header {
    Clear-Host
    Write-Host " ====================================================================" -ForegroundColor Cyan
    Write-Host "   _____                               _       _     " -ForegroundColor Cyan
    Write-Host "  / ____|                             | |     | |    " -ForegroundColor Cyan
    Write-Host " | (___  _   _  __ _ _ __ ___   __ _  | |_ ___| |__  " -ForegroundColor Cyan
    Write-Host "  \___ \| | | |/ _`  | '_ `  _ \ / _`  |__   / __| '_ \ " -ForegroundColor Cyan
    Write-Host "  ____) | |_| | (_| | | | | | | (_| | | _| (__| | | |" -ForegroundColor Cyan
    Write-Host " |_____/ \__, |\__, |_| |_| |_|\__,_| \_  \___|_| |_|" -ForegroundColor Cyan
    Write-Host "          __/ | __/ |                            " -ForegroundColor Cyan
    Write-Host "         |___/ |___/                             " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     - A C T I V A D O R   W I N D O W S   Y   O F F I C E - " -ForegroundColor Green
    Write-Host " ====================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ====================================================================
# GESTION DE PUNTO DE RESTAURACION
# ====================================================================
Show-Header
Write-Host "   Desea crear un punto de restauracion del sistema antes de continuar?" -ForegroundColor Yellow
$rpchoice = Read-Host "   Escribe S (Si) o N (No) y presiona Enter"

if ($rpchoice -match '^[Ss]$') {
    Write-Host ""
    Write-Host "   Creando punto de restauracion... (Esto puede tardar un momento)" -ForegroundColor Cyan
    try {
        Enable-ComputerRestore -Drive "C:" -ErrorAction SilentlyContinue | Out-Null
        Checkpoint-Computer -Description "Sygmatch_Backup_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop | Out-Null
        Write-Host "   [OK] ¡Punto de restauracion creado con exito!" -ForegroundColor Green
    }
    catch {
        Write-Host "   [!] No se pudo crear el punto de restauracion (puede estar desactivado en Windows)." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 3
} else {
    Write-Host ""
    Write-Host "   Omitiendo la creacion de punto de restauracion..." -ForegroundColor DarkYellow
    Start-Sleep -Seconds 2
}

# ====================================================================
# MENU PRINCIPAL
# ====================================================================
function Show-Menu {
    while ($true) {
        Show-Header
        Write-Host "   [1] Activar Windows (Metodo HWID - Permanente)" -ForegroundColor White
        Write-Host "   [2] Activar Office (Metodo Ohook - Permanente)" -ForegroundColor White
        Write-Host "   [3] Activar Windows / Office (Metodo Online KMS - 180 Dias)" -ForegroundColor White
        Write-Host "   [4] Cambiar Edicion de Windows (Ej. Home a Pro)" -ForegroundColor White
        Write-Host "   [5] Limpiar Licencias (Windows y Office)" -ForegroundColor White
        Write-Host "   [6] Comprobar Estado de la Licencia (Windows y Office)" -ForegroundColor White
        Write-Host "   [7] Salir del programa" -ForegroundColor Red
        Write-Host ""
        Write-Host " ====================================================================" -ForegroundColor Cyan
        
        $choice = Read-Host "  Escribe el numero de tu opcion y presiona Enter"

        switch ($choice) {
            '1' { Act-WindowsHWID }
            '2' { Act-OfficeOhook }
            '3' { Act-KMS }
            '4' { Change-WinEdition }
            '5' { Clean-Licenses }
            '6' { Check-LicenseStatus }
            '7' { Exit }
            default { 
                Write-Host "   [!] Opcion no valida. Intente de nuevo." -ForegroundColor Red
                Start-Sleep -Seconds 1.5
            }
        }
    }
}

function Act-WindowsHWID {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  INICIANDO ACTIVACION DE WINDOWS (HWID)..." -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Aplicando licencia digital permanente vinculada al hardware..." -ForegroundColor White
    Write-Host ""
    irm https://get.activated.win | iex
    Write-Host ""
    Write-Host "   Proceso de activacion por HWID terminado." -ForegroundColor Green
    Pause
}

function Act-OfficeOhook {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  INICIANDO ACTIVACION DE OFFICE (Ohook)..." -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Aplicando parche local permanente para Microsoft Office..." -ForegroundColor White
    Write-Host ""
    irm https://get.activated.win | iex
    Write-Host ""
    Write-Host "   Proceso de activacion por Ohook terminado." -ForegroundColor Green
    Pause
}

function Act-KMS {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  INICIANDO ACTIVACION KMS (Windows / Office)..." -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Conectando con servidor KMS de respaldo (180 dias)..." -ForegroundColor White
    Write-Host ""
    
    Write-Host "   [Activando Windows...]" -ForegroundColor Cyan
    cscript //nologo "$env:windir\system32\slmgr.vbs" /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX | Out-Null
    cscript //nologo "$env:windir\system32\slmgr.vbs" /skms kms8.msguides.com | Out-Null
    cscript //nologo "$env:windir\system32\slmgr.vbs" /ato | Out-Null

    Write-Host "   [Activando Office (Auto Volumen)...]" -ForegroundColor Cyan
    $offPath = ""
    if (Test-Path "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs") {
        $offPath = "$env:ProgramFiles\Microsoft Office\Office16"
    } elseif (Test-Path "$env:ProgramFiles(x86)\Microsoft Office\Office16\ospp.vbs") {
        $offPath = "$env:ProgramFiles(x86)\Microsoft Office\Office16"
    }

    if ($offPath) {
        Push-Location $offPath
        $tokens = cscript //nologo ospp.vbs /dstatus
        foreach ($line in $tokens) {
            if ($line -match "Last 5 chars of installed product key: ([A-Z0-9]{5})") {
                $key = $Matches[1]
                cscript //nologo ospp.vbs /unpkey:$key | Out-Null
            }
        }
        cscript //nologo ospp.vbs /sethst:kms8.msguides.com | Out-Null
        cscript //nologo ospp.vbs /act | Out-Null
        Pop-Location
    }

    Write-Host ""
    Write-Host "   Proceso de activacion KMS terminado." -ForegroundColor Green
    Pause
}

function Change-WinEdition {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  CAMBIAR EDICION DE WINDOWS" -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [1] Cambiar a Windows 10/11 Pro"
    Write-Host "   [2] Cambiar a Windows 10/11 Enterprise"
    Write-Host "   [3] Volver al menu principal"
    Write-Host ""
    $winchoice = Read-Host "  Selecciona una opcion"

    $winKey = ""
    if ($winchoice -eq '1') { $winKey = "VK7JG-NPHTM-C97JM-9MPGT-3V66T" }
    elseif ($winchoice -eq '2') { $winKey = "NPPR9-FWDCX-D2C8J-H872K-2YT43" }
    else { return }

    Write-Host ""
    Write-Host "   Aplicando la nueva clave de edicion en el sistema..." -ForegroundColor White
    cscript //nologo "$env:windir\system32\slmgr.vbs" /ipk $winKey | Out-Null
    Write-Host ""
    Write-Host "   ¡Listo! Se ha configurado la nueva version." -ForegroundColor Green
    Write-Host "   Es muy probable que necesites reiniciar el equipo." -ForegroundColor Yellow
    Pause
}

function Clean-Licenses {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  LIMPIEZA Y REINICIO DE LICENCIAS (WINDOWS Y OFFICE)" -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   [1] Limpiar licencias de Windows"
    Write-Host "   [2] Limpiar licencias de Office"
    Write-Host "   [3] Limpiar AMBAS licencias"
    Write-Host "   [4] Volver al menu principal"
    Write-Host ""
    $cleanchoice = Read-Host "  Selecciona una opcion de limpieza"

    if ($cleanchoice -eq '1' -or $cleanchoice -eq '3') {
        Write-Host "   Limpiando Windows..." -ForegroundColor Cyan
        cscript //nologo "$env:windir\system32\slmgr.vbs" /upk | Out-Null
        cscript //nologo "$env:windir\system32\slmgr.vbs" /cpky | Out-Null
        cscript //nologo "$env:windir\system32\slmgr.vbs" /ckms | Out-Null
    }

    if ($cleanchoice -eq '2' -or $cleanchoice -eq '3') {
        Write-Host "   Limpiando Office..." -ForegroundColor Cyan
        $offPath = ""
        if (Test-Path "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs") {
            $offPath = "$env:ProgramFiles\Microsoft Office\Office16"
        } elseif (Test-Path "$env:ProgramFiles(x86)\Microsoft Office\Office16\ospp.vbs") {
            $offPath = "$env:ProgramFiles(x86)\Microsoft Office\Office16"
        }
        if ($offPath) {
            Push-Location $offPath
            $tokens = cscript //nologo ospp.vbs /dstatus
            foreach ($line in $tokens) {
                if ($line -match "Last 5 chars of installed product key: ([A-Z0-9]{5})") {
                    $key = $Matches[1]
                    cscript //nologo ospp.vbs /unpkey:$key | Out-Null
                }
            }
            cscript //nologo ospp.vbs /remhst | Out-Null
            Pop-Location
        }
    }

    if ($cleanchoice -in '1','2','3') {
        Write-Host ""
        Write-Host "   ¡Proceso de limpieza completado!" -ForegroundColor Green
        Pause
    }
}

function Check-LicenseStatus {
    Clear-Host
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host "  ESTADO ACTUAL DE LICENCIAS (WINDOWS Y OFFICE)" -ForegroundColor Yellow
    Write-Host " ===================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Estado de Windows
    Write-Host " [ ESTADO DE WINDOWS ]" -ForegroundColor Green
    cscript //nologo "$env:windir\system32\slmgr.vbs" /xpr
    Write-Host ""

    # Estado de Office
    Write-Host " [ ESTADO DE OFFICE ]" -ForegroundColor Green
    $offPath = ""
    if (Test-Path "$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs") {
        $offPath = "$env:ProgramFiles\Microsoft Office\Office16"
    } elseif (Test-Path "$env:ProgramFiles(x86)\Microsoft Office\Office16\ospp.vbs") {
        $offPath = "$env:ProgramFiles(x86)\Microsoft Office\Office16"
    }

    if ($offPath) {
        Push-Location $offPath
        cscript //nologo ospp.vbs /dstatus
        Pop-Location
    } else {
        Write-Host " [!] No se encontro una instalacion estandar de Microsoft Office (Office 16) en este equipo." -ForegroundColor Yellow
    }

    Write-Host ""
    Pause
}

# Iniciar menu principal
Show-Menu
