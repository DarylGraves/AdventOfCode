##################################################
# Variables
##################################################
$Data = Get-Content .\Input.txt
$Exclude = "."
$HashTable = @{}
$VisualMode = $true

# I know Global Variables are bad practice but I just want to get to the next day now....
$Global:ValidNodes = 0

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
    
    if ($Data[$y][$x] -ceq $char) {
        if (!$HashTable.ContainsKey([int][char]$char)) {
            $HashTable[[int][char]$char] = @()
        }

        $HashTable[[int][char]$char] += "$y, $x"
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
            Write-Host ([char]$char) -NoNewline -ForegroundColor Yellow
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
                [console]::SetCursorPosition(0, $RowCount + 6)
            }

            # Add before
            # Base number, before incrementing wiht the difference
            $AddBeforeY = [int]$oneY
            $AddBeforeX = [int]$oneX
            
            $isValid = $true
            while ($isValid) {
                $AddBeforeY -= [int]$diffY
                $AddBeforeX -= [int]$diffX

                # Out of Bounds Checking - Hitting Out of Bounds will break the loop
                if ($AddBeforeY -lt 0 -or $AddBeforeX -lt 0) { $isValid = $false } # Out of Bounds
                if ($AddBeforeY -ge $MaxY -or $AddBeforeX -gt ($MaxX - 1)) { $isValid = $false } # Out of Bounds

                $ValueOnGrid = [int][char] $Global:Grid[$AddBeforeY, $AddBeforeX]

                # if ([char]$ValueOnGrid -eq "y") {
                #     Write-Host "Pause"
                # }

                if ([char]$ValueOnGrid -ne ".") {
                    if ($HashTable[$ValueOnGrid].Count -ne 1) {
                        continue
                    }
                }

                if ([char]$ValueOnGrid -eq "#") {
                    continue
                }

                # Update the coordinates
                if ($isValid -and ($Characters -notcontains $Global:Grid[($AddBeforeY ), $AddBeforeX])) {
                    $Global:Grid[$AddBeforeY, $AddBeforeX] = [char]'#'
                    Print-Character -X $AddBeforeX -Y $AddBeforeY -Char "#" 
                }
            }

            
            # Add after
            $AddAfterY = [int]$twoY 
            $AddAfterX = [int]$twoX

            $isValid = $true
            while ($isValid) {
                $AddAfterY += [int]$diffY 
                $AddAfterX += [int]$diffX
                
                if ($AddAfterY -lt 0 -or $AddAfterX -lt 0) { $isValid = $false } # Out of Bounds
                if ($AddAfterY -gt $MaxY - 1 -or $AddAfterX -gt ($MaxX - 1) ) { $isValid = $false } # Out of Bounds
                $ValueOnGrid = [int][char] $Global:Grid[$AddAfterY, $AddAfterX]

                # if ([char]$ValueOnGrid -eq "y") {
                #     Write-Host "Pause"
                # }

                if ([char]$ValueOnGrid -ne ".") {
                    # Overwrite single antennas
                    if ($HashTable[$ValueOnGrid].Count -ne 1) {
                        continue
                    }
                }
                
                if ([char]$ValueOnGrid -eq "#") {
                    continue
                }

                if ($isValid -and ($Characters -notcontains $Global:Grid[($AddAfterY - 1), $AddAfterX])) {
                    $Global:Grid[$AddAfterY , $AddAfterX] = [char]'#'
                    Print-Character -X $AddAfterX -Y $AddAfterY -Char "#" 
                }
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
    # Start-Sleep -Seconds 1
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

# Store the valid nodes before processing hashes (as long as there are two nodes it's valid)
$AllNodes = $Global:Grid | Where-Object { $_ -notlike '.' } | Select-Object -Unique
foreach ($char in $AllNodes) {
    $count = ($Global:Grid | Where-Object { $_ -clike $char }).Count
    if ($Count -le 1) {
        continue
    }

    $Global:ValidNodes += $count
}

if ($VisualMode) {

    Print-Grid -Data $Data -HashTable $HashTable
}

$HashTable["#"] = @()

# Populating the hashes
foreach ($char in $Characters) {
    $Coordinates = $HashTable[[int][char]$char]
    Find-Hashes -Coordinates $Coordinates -HashTable $HashTable -Characters $char
}

if ($VisualMode) {
    [console]::SetCursorPosition(0, $RowCount + 6)
}

$ValidHashes = ($Global:Grid | Where-Object { $_ -like '#' }).Count

$Total = $Global:ValidNodes + $ValidHashes
Write-Host ""
Write-Host "Total: $Total (Nodes: $($Global:ValidNodes) and Hashes: $ValidHashes)"