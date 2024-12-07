######################################
# Functions
######################################
function Print-Map {
    param (
        [Parameter(ParameterSetName = 'WriteAll')]
        [string[]]$Map,
        [Parameter(ParameterSetName = 'Update')]
        [int]$X,
        [int]$Y,
        [string]$newValue
    )

    # Update ParameterSet
    if ($newValue) {
        [System.Console]::SetCursorPosition($x, $y)
        switch ($newValue) {
            "." { Write-Host '·' -ForegroundColor DarkBlue -NoNewline }
            "#" { Write-Host $newValue -ForegroundColor red -NoNewline }
            "^" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
            ">" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
            "V" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
            "<" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
            "x" { Write-Host $newValue -ForegroundColor yellow -NoNewline }
            Default {}
        }

        return
    }

    # WriteAll ParameterSet
    for ($y = 0; $y -lt $Map.Count; $y++) {
        for ($x = 0; $x -lt $Map[$y].Length; $x++) {
            $newValue = $Map[$y][$x]
            
            [System.Console]::SetCursorPosition($x, $y)

            switch ($newValue) {
                "." { Write-Host '·' -ForegroundColor DarkBlue -NoNewline }
                "#" { Write-Host $newValue -ForegroundColor red -NoNewline }
                "^" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
                ">" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
                "V" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
                "<" { Write-Host $newValue -ForegroundColor Cyan -NoNewline }
                "x" { Write-Host $newValue -ForegroundColor yellow -NoNewline }
                Default {}
            }
        }
    }
}

function Get-Player {
    param(
        [string[]]$Map
    )

    $guardDirection = ($Map | Select-String '\^|V|<|>').Matches.Value

    for ($y = 0; $y -lt $Map.Count; $y++) {
        for ($x = 0; $x -lt $Map[$y].Length; $x++) {
            if ($Map[$y][$x] -eq $guardDirection) {
                # Write-Host "GuardDirection: $x, $y"
                return $guardDirection, $y, $x
            }
        }
    }
}
function Change-Direction {
    param (
        [string]$Direction
    )

    switch ($Direction) {
        "^" { return ">" }
        "V" { return "<" }
        "<" { return "^" }
        ">" { return "V" }
        Default {}
    }
}

function Move-Guard {
    param (
        [string[]]$Map,
        [string]$GuardCoordinatesX,
        [string]$GuardCoordinatesY,
        [string]$GuardDirection
    )

    $newCoordinatesX = [int] $GuardCoordinatesX
    $newCoordinatesY = [int] $GuardCoordinatesY

    $patrolEnd = $false
    $guardMoved = $false

    $RowWidth = $Map[0].Length 

    do {
        switch ($GuardDirection) {
            "^" { $newCoordinatesY -= 1 }
            ">" { $newCoordinatesX += 1 }
            "V" { $newCoordinatesY += 1 }
            "<" { $newCoordinatesX -= 1 }
            Default { return $false }
        }

        # Out of bounds check
        if (
            ($newCoordinatesX -ge $Map[0].Length) -or 
            ($newCoordinatesX -lt 0) -or 
            ($newCoordinatesY -ge $Map.Count) -or 
            ($newCoordinatesY -lt 0)) {
            $Global:CountOfTiles += 1

            [System.Console]::SetCursorPosition($RowWidth, 3)
            Write-Host "Tiles: $Global:CountOfTiles"

            # Patrol End
            return $false, $Map, $GuardCoordinatesX, $GuardCoordinatesY, $GuardDirection
        }

        # Obstacle check (turns guard)
        if ($Map[$newCoordinatesY][$newCoordinatesX] -eq "#") {
            $GuardDirection = Change-Direction -Direction $GuardDirection
            
            # Reset coordinates
            $newCoordinatesX = [int] $GuardCoordinatesX
            $newCoordinatesY = [int] $GuardCoordinatesY
        }
        else {
            if ($Map[$newCoordinatesY][$newCoordinatesX] -ne "x") {
                $Global:CountOfTiles += 1
                [System.Console]::SetCursorPosition($RowWidth, 3)
                Write-Host "Tiles: $Global:CountOfTiles"
            }
            $Map[$GuardCoordinatesY] = Update-MapRow -Row $Map[$GuardCoordinatesY] -IndexToChange $GuardCoordinatesX -NewChar "x"
            Print-Map -X $GuardCoordinatesX -Y $GuardCoordinatesY -newValue "x"

            $GuardCoordinatesX = $newCoordinatesX
            $GuardCoordinatesY = $newCoordinatesY
            $Map[$GuardCoordinatesY] = Update-MapRow -Row $Map[$GuardCoordinatesY] -IndexToChange $GuardCoordinatesX -NewChar $GuardDirection 

            Print-Map -X $GuardCoordinatesX -Y $GuardCoordinatesY -newValue $GuardDirection
            # Start-Sleep -Milliseconds 100

            $guardMoved = $true
        }
    }while ($guardMoved -ne $true)

    return $true, $Map, $GuardCoordinatesX, $GuardCoordinatesY, $GuardDirection
}

function Update-MapRow {
    param (
        [string]$Row,
        [string]$IndexToChange,
        [string]$NewChar
    )

    $NewRowArray = @()

    for ($x = 0; $x -lt $Row.Length; $x++) {
        if ($x -eq $IndexToChange) {
            $NewRowArray += $NewChar
        }
        else {
            $NewRowArray += $Row[$x]
        }
    }

    return ($NewRowArray -join "")
}


######################################
# Script
######################################
[System.Console]::CursorVisible = $false
Clear-Host
$Map = Get-Content .\Input.txt
$Global:CountOfTiles = 0

$guardDirection, $guardCoordinatesY, $guardCoordinatesX = Get-Player -Map $Map

Print-Map -Map $Map 
do {
    $moveAgain, $Map, $guardCoordinatesX, $guardCoordinatesY, $guardDirection = Move-Guard -Map $Map -GuardCoordinatesX $guardCoordinatesX -GuardCoordinatesY $guardCoordinatesY -GuardDirection $guardDirection
    # Print-Map -Map $Map
    # Start-Sleep -Milliseconds 250
}while ($moveAgain) 

[System.Console]::SetCursorPosition(0, $Map.Count + 1)