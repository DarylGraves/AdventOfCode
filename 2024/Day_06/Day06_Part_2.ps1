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

    if ($Global:VisualMode -eq $False) {
        return
    }
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

    $guardMoved = $false

    $RowWidth = $Map[0].Length + 1

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

            if ($Global:VisualMode) {

                [System.Console]::SetCursorPosition($RowWidth, 3)
            }

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
            # Area already touched
            if ($Map[$newCoordinatesY][$newCoordinatesX] -eq "x") {
                $Global:ConsecutiveOverlaps += 1
                if ($Global:VisualMode) {
                    [System.Console]::SetCursorPosition($RowWidth, 3)
                    Write-Host "Overlaps: $Global:ConsecutiveOverlaps" -NoNewLine 
                }
            }

            # Infinite Loop Checker
            if ($Global:ConsecutiveOverlaps -gt $Global:ConsecutiveOverLapLimit) {
                if ($Global:VisualMode) {
                    Write-Host " Inf. Loop" -ForegroundColor Red -NoNewline
                }
                $Global:InfiniteLoops += 1
                return $false, $Map, $GuardCoordinatesX, $GuardCoordinatesY, $GuardDirection
            }
            
            # If we got this far, the guard moves - Update the map
            $Map[$GuardCoordinatesY] = Update-MapRow -Row $Map[$GuardCoordinatesY] -IndexToChange $GuardCoordinatesX -NewChar "x"
            Print-Map -X $GuardCoordinatesX -Y $GuardCoordinatesY -newValue "x"

            $GuardCoordinatesX = $newCoordinatesX
            $GuardCoordinatesY = $newCoordinatesY
            $Map[$GuardCoordinatesY] = Update-MapRow -Row $Map[$GuardCoordinatesY] -IndexToChange $GuardCoordinatesX -NewChar $GuardDirection 

            Print-Map -X $GuardCoordinatesX -Y $GuardCoordinatesY -newValue $GuardDirection
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
$Global:ConsecutiveOverlaps = 0
$Global:ConsecutiveOverLapLimit = 25000
$Global:InfiniteLoops = 0
$Global:VisualMode = $False

$DataPath = ".\Input.txt"
$Map = Get-Content $DataPath
$guardDirection, $guardCoordinatesY, $guardCoordinatesX = Get-Player -Map $Map

[System.Console]::CursorVisible = $false
Clear-Host

$MapElements = $Map.Count * $Map[0].Length
$CellNo = 0

# Place an obstruction
for ($Y = 0; $Y -lt $Map.Count; $Y++) {
    for ($X = 0; $X -lt $Map[0].Length; $X++) {
        if ($Global:VisualMode -eq $False) {
            Write-Host "On $CellNo / $MapElements"
        }
        Print-Map -Map $Map 
        if ($Map[$Y][$X] -eq "#") {
            # Obstruction already here
            continue
        }

        $Map[$Y] = Update-MapRow -Row $Map[$Y] -IndexToChange $X -NewChar "#"
        Print-Map -X $X -Y $Y -newValue "#"

        do {
            $moveAgain, $Map, $guardCoordinatesX, $guardCoordinatesY, $guardDirection = Move-Guard -Map $Map -GuardCoordinatesX $guardCoordinatesX -GuardCoordinatesY $guardCoordinatesY -GuardDirection $guardDirection
        }while ($moveAgain) 

        $Map = Get-Content $DataPath
        $guardDirection, $guardCoordinatesY, $guardCoordinatesX = Get-Player -Map $Map

        $Global:ConsecutiveOverlaps = 0

        if ($Global:VisualMode) {
            [System.Console]::SetCursorPosition($Map[0].Length + 1, 3)
            Write-Host "Overlaps: $Global:ConsecutiveOverlaps                      " -NoNewLine
        }
    
        $CellNo += 1
    }
}

[System.Console]::SetCursorPosition(0, $Map.Count + 1)
Write-Host "Infinite Loops: $Global:InfiniteLoops"