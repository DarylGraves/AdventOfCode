$Global:X_Length = 0
$Global:Y_Length = 0
$Global:Centre = 0

enum Direction {
    NorthToSouth
    SouthToNorth
    WestToEast
    EastToWest
}

class Tree {
    [int]$Height
    [bool]$Visible
}

function New-2dArray {
    [CmdletBinding()]
    param (
        [string[]]$Data
    )
    
    $Global:X_Length = $Data[0].Length
    $Global:Y_Length = $Data.Count
    $Global:Centre = ($Data[0].Length - 1) / 2

    Write-Debug "Rows =`t`t$X_Length"
    Write-Debug "Columns =`t$Y_Length "

    $2dArray = New-Object 'object[,]' $Y_Length, $X_Length 

    for ($y = 0; $y -lt $Y_Length; $y++) {
        for ($x = 0; $x -lt $X_Length; $x++) {
            $2dArray[$y, $x] = [Tree]@{
                Height = [int][string]$Data[$y][$x]
                Visible = $False
            }
        }
    }

    return ,$2dArray
}

function Get-Perimiter {
    [CmdletBinding()]
    param (
        [Object[,]]$Data
    )

    # Mark the top and bottom rows as visible
    foreach ($row in 0, ($Y_Length - 1)) {
        for ($X = 0; $X -lt $X_Length; $X++) {
            $Data[$row,$X].Visible = $True
        }
    }

    # Mark the left and right columns as visible
    foreach ($column in 0, ($X_Length -1)) {
        for ($Y = 0; $Y -lt $Y_Length; $Y++) {
            $Data[$Y,$column].Visible = $True
        }
    }
}

function Write-Trees {
    param (
        [Object[,]]$Data
    )

    Clear-Host
    for ($y = 0; $y -lt $Y_Length; $y++) {
        for ($x = 0; $x -lt $X_Length; $x++) {
            $CurTree = $Data[$y,$x]
            if ($CurTree.Visible -eq $True) {
                Write-Host $CurTree.Height -ForegroundColor Green -NoNewline
            }
            else {
                Write-Host $CurTree.Height -ForegroundColor Blue -NoNewline
            }
        }
        Write-Host ""
    }
}

function Scan-Trees {
    [cmdletbinding()]
    param (
        [Object[,]]$Data,
        [String]$Direction
    )
    
    switch ($Direction) {
        "NorthToSouth" { 
            Write-Debug "North To South"

            #Column
            for ($x = 1; $x -lt $x_length; $x++) {
                $HighestEncountered = $Data[0,($x)].Height
                Write-Debug "HighestEncountered Starts at: $HighestEncountered"
                # Row
                for ($y = 1; $y -lt $Y_Length; $y++) {
                    $CurTree = $Data[$y,$x]
                    Write-Debug "Tree X: $x`tTree Y: $y`tTree Height: $($CurTree.Height)`tHighestSoFar: $HighestEncountered"

                    if ($CurTree.Height -gt $HighestEncountered) {
                        $HighestEncountered = $CurTree.Height
                        Write-Debug "HighestEncountered now equals $HighestEncountered"
                        $CurTree.Visible = $True
                    }
                }
            }
            break
        }

        "SouthToNorth" {
            Write-Debug "South To North"

            # Column
            for ($x = 1; $x -lt $x_length; $x++) {
                $HighestEncountered = $Data[($Y_Length -1), $x].Height
                Write-Debug "HighestEncountered Starts at $HighestEncountered"
                # Row
                for ($y = $Y_Length - 1; $y -gt 0; $y--) {
                    $CurTree = $Data[$y,$x]
                    Write-Debug "Tree X: $x`tTree Y: $y`tTree Height: $($CurTree.Height)`tHighestSoFar: $HighestEncountered"

                    if ($CurTree.Height -gt $HighestEncountered) {
                        $HighestEncountered = $CurTree.Height
                        Write-Debug "HighestEnountered now equals $HighestEncountered"
                        $CurTree.Visible = $True
                    }
                }
            }
            break
        }

        "WestToEast" {
            Write-Debug "West To East"

            # Row
            for ($y = 1; $y -lt $Y_Length; $y++) {
                $HighestEncountered = $Data[$y, 0].Height
                Write-Debug "HighestEncountered Starts at $HighestEncountered"
                #Column
                for ($x = 1; $x -lt $X_Length; $x++) {
                    $CurTree = $Data[$y,$x]
                    Write-Debug "Tree X: $x`tTree Y: $y`tTree Height: $($CurTree.Height)`tHighestSoFar: $HighestEncountered"

                    if ($CurTree.Height -gt $HighestEncountered) {
                        $HighestEncountered = $CurTree.Height
                        Write-Debug "HighestEncountered now equals $HighestEncountered"
                        $CurTree.Visible = $True
                    }
                }
            }
            break
        }

        "EastToWest" {
            Write-Debug "East To West"
            
            # Row
            for ($y = 1; $y -lt $Y_Length; $y++) {
                $HighestEncountered = $Data[$y, ($x_length -1)].Height
                Write-Debug "HighestEncountered Starts at $HighestEncountered"
                #Column
                for ($x = $X_Length -1; $x -gt 0; $x--) {
                    $CurTree = $Data[$y,$x]
                    Write-Debug "Tree X: $x`tTree Y: $y`tTree Height: $($CurTree.Height)`tHighestSoFar: $HighestEncountered"

                    if ($CurTree.Height -gt $HighestEncountered) {
                        $HighestEncountered = $CurTree.Height
                        Write-Debug "HighestEncountered now equals $HighestEncountered"
                        $CurTree.Visible = $True
                    }
                }
            }
            break
        }
    }

}

$TreeArray = New-2dArray -Data (Get-Content .\input.txt) 
Get-Perimiter -Data $TreeArray
Scan-Trees -Data $TreeArray -Direction "NorthToSouth" 
Scan-Trees -Data $TreeArray -Direction "SouthToNorth" 
Scan-Trees -Data $TreeArray -Direction "WestToEast" 
Scan-Trees -Data $TreeArray -Direction "EastToWest" 
Write-Trees -Data $TreeArray # It so pretty!
$Answer = ($TreeArray | Where-Object {$_.Visible -eq $True} | Group-Object).Count
Write-Host "`nThe Answer is $Answer" -ForegroundColor Green