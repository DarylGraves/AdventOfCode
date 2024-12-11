##################################################
# Variables
##################################################
$Data = Get-Content .\TestInput2.txt
$Exclude = "."
$HashTable = @{}
# $HashTable = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
$VisualMode = $true

##################################################
# Functions
##################################################
function Update-HashTable {
    param (
        [char]$Char,
        [string[]]$Data,
        [System.Collections.HashTable]$HashTable,
        [int]$Y,
        [int]$X
    )
    
    if ($Data[$y][$x] -eq $char) {
        if (!$HashTable.ContainsKey($char)) {
            $HashTable[$char] = @()
        }

        $HashTable[$char] += "$y, $x"
    }

    return $HashTable
}

function Print-Grid {
    param(
        [string[]]$Data,
        [HashTable]$HashTable
    )

    Clear-Host
    for ($y = 0; $y -lt $Data.Count; $y++) {
        for ($x = 0; $x -lt $Data[0].Length; $x++) {
            Write-Host "." -NoNewLine
        }
        Write-Host ""
    }

    foreach ($char in $HashTable.Keys) {
        foreach ($coordinate in $HashTable[$char]) {
            $CoordY, $CoordX = $coordinate -split ", "
            [console]::SetCursorPosition($CoordX, $CoordY)
            Write-Host $char -NoNewline -ForegroundColor Yellow
        }
    }
}

function Find-Hashes {
    param(
        [string[]]$Coordinates,
        [HashTable]$HashTable,
        [char[]]$Characters
    )

    $MaxX = $Global:Grid.GetLength(1)
    $MaxY = $Global:Grid.GetLength(0)

    for ($i = 0; $i -lt $Coordinates.Count; $i++) {
        $oneY, $oneX = $Coordinates[$i] -split ", "

        for ($z = 0; $z -lt $Coordinates.Count; $z++) {
            if ($z -eq $i) { continue }
            
            $twoY, $twoX = $Coordinates[$z] -split ", "

            $diffY = [int] $twoY - [int] $oneY
            $diffX = [int] $twoX - [int] $oneX 
            
            $AddBeforeY = ([int]$oneY - [int]$diffY)
            $AddBeforeX = ([int]$oneX - [int]$diffX)
            $AddAfterY = ([int]$twoY + [int]$diffY) 
            $AddAfterX = ([int]$twoX + [int]$diffX)

            if (!$VisualMode) {
                Write-Host "`+ X: $AddBeforeX Y: $AddBeforeY" -ForegroundColor Green
                Write-Host "1 X: $oneX Y: $oneY " 
                Write-Host "2 X: $twoX Y: $twoY"
                Write-Host "`+ X: $AddAfterX Y: $AddAfterY" -ForegroundColor Green
                Write-Host "-------------------" -ForegroundColor Yellow
            }

            if ($VisualMode) {
                [console]::SetCursorPosition(0, $RowCount + 2)
                Write-Host "                      "
                Write-Host "                      "
                Write-Host "                      "
                Write-Host "                      "
                [console]::SetCursorPosition(0, $RowCount + 2)
                Write-Host "`+ X: $AddBeforeX Y: $AddBeforeY" -ForegroundColor Green
                Write-Host "1 X: $oneX Y: $oneY " 
                Write-Host "2 X: $twoX Y: $twoY"
                Write-Host "`+ X: $AddAfterX Y: $AddAfterY" -ForegroundColor Green
                # [console]::SetCursorPosition($oneX, $oneY)
                # Write-Host "X" -ForegroundColor DarkCyan
                # [console]::SetCursorPosition($twoX, $twoY)
                # Write-Host "X" -ForegroundColor DarkCyan
                [console]::SetCursorPosition(0, $RowCount + 6)
            }

            # Add before
            $isValid = $true
            if ($AddBeforeY -lt 0 -or $AddBeforeX -lt 0) { $isValid = $false } # Out of Bounds
            if ($AddBeforeY -ge $MaxY -or $AddBeforeX -gt ($MaxX - 1)) { $isValid = $false } # Out of Bounds

            $Temp = $Grid[($AddBeforeY), $AddBeforeX]

            try {
                
                if (($isValid) -and 
                ($Characters -notcontains $Global:Grid[($AddBeforeY ), $AddBeforeX])) {
                    # -and ($Global:Grid[$AddBeforeY, $AddBeforeX] -eq '.')) 

                    $Global:Grid[$AddBeforeY, $AddBeforeX] = [char]'#'
                    Print-Character -X $AddBeforeX -Y $AddBeforeY -Char "#" 
                }
            }
            catch {
                [console]::SetCursorPosition($AddBeforeX, $AddBeforeY)
                Write-Host "?" -ForegroundColor DarkCyan # Out of bounds troubleshooting
            }
            
            # Add after
            $isValid = $true
            if ($AddAfterY -lt 0 -or $AddAfterX -lt 0) { $isValid = $false } # Out of Bounds
            if ($AddAfterY -gt $MaxY - 1 -or $AddAfterX -gt ($MaxX - 1) ) { $isValid = $false } # Out of Bounds

            $Temp = $Grid[($AddAfterY), $AddAfterX]

            try {
                if (($isValid) -and 
                ($Characters -notcontains $Global:Grid[($AddAfterY - 1), $AddAfterX])) {
                    # -and ($Global:Grid[($AddAfterY), $AddAfterX] -eq '.')) 

                    $Global:Grid[$AddAfterY , $AddAfterX] = [char]'#'
                    Print-Character -X $AddAfterX -Y $AddAfterY -Char "#" 
                }
            }
            catch {
                [console]::SetCursorPosition($AddAfterX, $AddAfterY)
                Write-Host "?" -ForegroundColor DarkCyan # Out of bounds troubleshooting
            }
        }
    }
}

function Print-Character {
    param (
        [int]$X,
        [int]$Y,
        [char]$Char
    )
    
    if ($Global:VisualMode -eq $false) { return }

    [console]::SetCursorPosition($X, $Y)
    Write-Host "$Char" -ForegroundColor Red -NoNewline
    [console]::SetCursorPosition(0, $RowCount + 6)
}

##################################################
# Script
##################################################
$RowCount = $Data.Count
$ColumnCount = $Data[0].Length
$Global:Grid = New-Object 'char[,]' $RowCount, $ColumnCount

for ($y = 0; $y -lt $RowCount; $y++) {
    for ($x = 0; $x -lt $ColumnCount; $x++) {
        $Global:Grid[$y, $x] = $Data[$y][$x]
    }
}

$Characters = $Global:Grid | Where-Object { $_ -notlike $Exclude } | Select-Object -Unique

# Populate hashtable
foreach ($char in $Characters) {
    for ($y = 0; $y -lt $RowCount; $y++) {
        for ($x = 0; $x -lt $ColumnCount; $x++) {
            $HashTable = Update-HashTable -Char $char -Data $Data -Y $y -X $x -HashTable $HashTable
        }
    }
}

if ($VisualMode) {

    Print-Grid -Data $Data -HashTable $HashTable
}

$HashTable["#"] = @()

# Populating the hashes
foreach ($char in $Characters) {
    $Coordinates = $HashTable[$char]
    Find-Hashes -Coordinates $Coordinates -HashTable $HashTable -Characters $char
}

if ($VisualMode) {
    [console]::SetCursorPosition(0, $RowCount + 6)
}

$NewCount = ($Global:Grid | Where-Object { $_ -like "#" }).Count
Write-Host ""
Write-Host "Count: $NewCount"