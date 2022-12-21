$Global:X_Length = 0
$Global:Y_Length = 0
$Global:Centre = 0

class Tree {
    [int]$Height
    [bool]$Visible
}

function New-2dArray {
    # Converts the text file into a 2D array of type "Tree"
    [CmdletBinding()]
    param (
        [string[]]$Data
    )
    
    $Global:X_Length = $Data[0].Length
    $Global:Y_Length = $Data.Count

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
    # The perimiter is all visible regardless of height so mark all these trees visible
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
    # Writes the result to the screen - Partly for troubleshooting, partly because it looks cool
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
    # Go from one end to the other and mark each tree as visible if it's the largest so far in that direction
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

function Find-ScenicValue {
    [cmdletbinding()]
    param (
        [Object[,]]$Data,
        [int]$tree_y,
        [int]$tree_x
    )

    $LeftFree = 0
    $RightFree = 0
    $UpFree = 0
    $DownFree = 0

    $CurrentTree = $Data[$tree_y, $tree_x]
    Write-Debug "Tree($($Tree_X + 1),$($Tree_Y + 1)) Height = $($CurrentTree.Height)"

    # Checking Left
    Write-Debug "---Checking Left---"

    for ($x = $tree_x - 1; $x -ge 0; $x--) {
        $CheckingTree = $Data[$tree_y, $x]
        Write-Debug "`t Checking $($X + 1), $($Tree_y + 1) - Height: $($CheckingTree.Height)"
        
        $LeftFree++
        if ($CheckingTree.Height -lt $CurrentTree.Height) {
            Write-Debug "`t`tThis tree is smaller than the current tree."
            Write-Debug "`t`tLeftFree = $LeftFree"
        }
        else {
            Write-Debug "`t`tThis tree is the same size or higher than the current tree so breaking out."
            break
        }
    }

    Write-Debug "LeftFree totaled $LeftFree"

    # Checking Right
    Write-Debug "---Checking Right---"

    for ($x = $tree_x + 1; $x -lt $X_Length; $x++) {
        $CheckingTree = $Data[$tree_y, $x]
        Write-Debug "`t Checking $($X + 1), $($Tree_Y + 1) - Height: $($CheckingTree.Height)"

        $RightFree++
        if ($CheckingTree.Height -lt $CurrentTree.Height) {
            Write-Debug "`t`tThis tree is smaller than the current tree."
            Write-Debug "`t`tRightFree = $RightFree"
        }
        else {
            Write-Debug "`t`tThis tree is the same size or higher than the current tree so breaking out."
            break
        }
    }

    Write-Debug "RightFree totaled $RightFree"

    # Checking Up
    Write-Debug "---Checking Up---"

    for ($y = $tree_y - 1; $y -ge 0; $y--) {
        $CheckingTree = $Data[$y, $tree_x]
        Write-Debug "`t Checking $($tree_x + 1), $($y + 1) - Height: $($CheckingTree.Height)"

        $UpFree++
        if ($CheckingTree.Height -lt $CurrentTree.Height) {
            Write-Debug "`t`tThis tree is smaller than the current tree."
            Write-Debug "`t`tUpFree = $UpFree"
        }
        else {
            Write-Debug "`t`tThis tree is the same size or higher than the current tree so breaking out."
            break
        }
    }
    
    Write-Debug "UpFree totaled $UpFree"

    # Checking Down
    Write-Debug "---Checking Down---"

    for ($y = $tree_y + 1; $y -lt $Y_Length; $y++) {
        $CheckingTree = $Data[$y, $tree_x]
        Write-Debug "`t Checking $($tree_x + 1), $($y + 1) - Height: $($CheckingTree.Height)"

        $DownFree++
        if ($CheckingTree.Height -lt $CurrentTree.Height) {
            Write-Debug "`t`tThis tree is smaller than the current tree."
            Write-Debug "`t`tDownFree = $DownFree"
        }
        else {
            Write-Debug "`t`tThis tree is the small size or higher than the current tree so breaking out."
            break
        }
    }

    Write-Debug "DownFree totaled $DownFree"
    $Total = $LeftFree * $RightFree * $UpFree * $DownFree
    Write-Debug "$LeftFree * $RightFree * $UpFree * $DownFree = $Total"
    return $Total
}

$TreeArray = New-2dArray -Data (Get-Content .\input.txt) 
$ScenicValues = [System.Collections.ArrayList]::new()

#Find-ScenicValue -Data $TreeArray -tree_x 98 -tree_y 98 -debug
for ($y = 0; $y -lt $Y_Length; $y++) {
    for ($x = 0; $x -lt $X_Length; $x++) {
        $ScenicValues.Add((Find-ScenicValue -Data $TreeArray -tree_y $y -tree_x $x)) | Out-Null
    }
}

$Answer = $ScenicValues | Sort-Object -Descending | Select-Object -First 1
Write-Host "The answer is $Answer" -ForegroundColor Green
