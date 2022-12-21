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

            # Row
            for ($y = 1; $y -le $Centre; $y++) {
                $HighestEncountered = $Data[($y-1),0].Height
                Write-Debug "New Row - Highest Encountered reset to $HighestEncountered"
                # Column
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

        "SouthToNorth" {
            Write-Debug "South To North"
            
            # Row
            for ($y = $Y_Length - 2; $y -ge $Centre; $y--) {
                $HighestEncountered = $Data[($y+1),0].Height
                Write-Debug "New Row - Highest Encountered reset to $HighestEncountered"
                # Column
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
        "WestToEast" {
            Write-Debug "West To East"
            break
        }
        "EastToWest" {
            Write-Debug "East To West"
            break
        }
    }

}

$TreeArray = New-2dArray -Data (Get-Content .\input.txt) 
Get-Perimiter -Data $TreeArray
Scan-Trees -Data $TreeArray -Direction "NorthToSouth" -Debug
Write-Trees -Data $TreeArray
#Scan-Trees -Data $TreeArray -Direction "SouthToNorth" -Debug
#Write-Trees -Data $TreeArray
#$Answer = ($TreeArray | Where-Object {$_.Visible -eq $True} | Group-Object).Count
#Write-Host "`nThe Answer is $Answer" -ForegroundColor Green