function Search-Digits {
    # Scans ahead to gather all the digits, returns hte ned and the entire number
    param (
        [string]$Row,
        [int]$StartNo
    )
    
    $PartNo = @()

    for ($i = $StartNo; $i -lt $Row.Length; $i++) {
        # If next character isn't a number, exit out
        if(!($Row[$i] -match "\d")) {
            return $i, ($PartNo -Join "")
        }

        $PartNo += $Row[$i]
    }

    return $i, ($PartNo -Join "")
}

function Find-Cog {
    # Checks to make sure there is a "*" surrounding the digits.
    param (
        [string[]]$File,
        [int]$StartX,
        [int]$EndX,
        [int]$StartY,
        [int]$EndY
    )
    
    if ($StartY -lt 0) { $StartY = 0 }
    if ($StartX -lt 0) { $StartX = 0 }
    if ($EndY -gt ($File.Length) -1 ) { $EndY = $File.Length -1 }
    if ($EndX -gt ($File[$StartY].Length) -1) { $EndX = $File[$StartY].Length -1 }

    for ($Y = $StartY; $Y -le $EndY; $Y++) {
        for ($X = $StartX; $X -lt $EndX; $X++) {
            if ($File[$Y][$X] -match '\*') {
                # Found a "*" so this is half a cog
                return $X, $Y
            }
        }
    }
    
    # Didn't find a symbol so part number is invalid
    return "-", "-"
}

$File = Get-Content -Path .\Input.txt
$Parts = @()

# Go through each row
for ($row = 0; $row -lt $File.Length; $row++) {
    # Go through each character on the current row
    for ($Chr = 0; $Chr -lt $File[$Row].Length; $Chr++) {
        # If the character is a number, scan ahead
        if ($File[$Row][$Chr] -match "\d") {
            $StartX = $Chr 

            # Scan ahead to find other numbers and add them to the array
            $Chr, $Digits = Search-Digits -Row $File[$Row] -StartNo $Chr

            # Check there's a symbol in the perimiter
            $CogX, $CogY = Find-Cog -File $File -StartX ($StartX - 1) -EndX ($Chr + 1) -StartY ($Row - 1) -EndY ($Row + 1)

            # Add any digit next to a "*" to our array the list
            if(($CogX -ne "-") -and ($CogY -ne "-")) {
                $Parts += [PSCustomObject]@{
                    Digits = $Digits
                    CogX = $CogX
                    CogY = $CogY
                }
            }
        }
    }
}

$Sum = 0

# Find the cogs which have two numbers next to it
$ValidCogs = $Parts | Group-Object CogX, CogY | Where-Object Count -eq 2

# Go through each and multiple the values
foreach ($CogPair in $ValidCogs) {
    $Sum += [int] $CogPair.Group.Digits[0] * [int] $CogPair.Group.Digits[1]
}

$Sum
