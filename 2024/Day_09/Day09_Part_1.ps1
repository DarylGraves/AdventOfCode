$Troubleshooting = $false
$Data = Get-Content .\Input.txt
$UnpackedText = [System.Collections.Generic.List[char]]::new()
Clear-Host

# Populate the char[]
$Id = 0
for ($x = 0; $x -lt $Data.Length; $x += 2) {
    $Files = ($Id.ToString() * [int][string]$Data[$x]).ToCharArray()
    $Whitespace = ("." * [int][string]$Data[$x + 1]).ToCharArray()

    foreach ($file in $Files) {
        $UnpackedText.Add($File)
    }

    foreach ($space in $whitespace) {
        $UnpackedText.Add($space)
    }
    $Id += 1
}

if ($Troubleshooting) {
    Write-Host $UnpackedText
}

$KeepRunning = $true
$Front = 0
$Back = $UnpackedText.Count - 1

do {
    # Front and back have reached/passed each other
    if ($Front -ge $Back) {
        $KeepRunning = $false
        break
    }

    # Reached the end of the char[]
    if (($Front -ge $UnpackedText.Count) -or $UnpackedText[$Front] -eq ' ') {
        $KeepRunning = $false 
        continue 
    }

    # File already present, move forward one
    if ($UnpackedText[$Front] -ne '.') {
        $Front += 1 
        continue
    }

    # Back has a .
    if ($UnpackedText[$Back] -eq '.') {
        $Back -= 1
        continue
    }
    
    if ($UnpackedText[$Back] -ne ' ') { 
        $toMove = $UnpackedText[$Back]
        $UnpackedText[$Back] = '.'
        $UnpackedText[$Front] = $toMove

        if ($Troubleshooting) {
            [System.Console]::SetCursorPosition(0, 1)
            Write-Host "                                                                                                                                                                                                                                                                                                             "
            [System.Console]::SetCursorPosition(0, 0)
            Write-Host "                                                                                                                                                                                                                                                                                                             "
            [System.Console]::SetCursorPosition(0, 0)
            Write-Host $UnpackedText
            [System.Console]::SetCursorPosition($Front * 2, 1)
            Write-Host "^" -ForegroundColor Green
            [System.Console]::SetCursorPosition(($Back * 2) - 2, 1)
            Write-Host "^" -ForegroundColor Red
            # Start-Sleep -Seconds  1
        }

        $Front += 1
        $Back -= 1

    }
} while (
    $KeepRunning
)

$UnpackedText -join "" | Out-File temp.txt

[long] $Results = 0
for ($x = 0; $x -lt ($UnpackedText.Count - 1); $x++) {
    $Value = $UnpackedText[$x]

    try {
        $ResultToAdd = $X * [int][string]$Value
        if (($Troubleshooting)) {
            Write-Host "Adding $X * $([int][string]$Value) = $ResultToAdd"
        }
        $Results += $ResultToAdd
    }
    catch {
        if (($Troubleshooting)) {
            Write-Host "Skipping as not a number"
        }
    }
}

Write-Host $Results