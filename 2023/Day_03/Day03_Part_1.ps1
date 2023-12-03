function Search-Digits {
    # Scans ahead to gather all the digits
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

function Assert-Validity {
    # Checks to make sure there is a symbol surrounding the digits.
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
            if ($File[$Y][$X] -match '[^\d.]') {
                # Found a symbol so part number is valid
                return $true
            }
        }
    }
    
    # Didn't find a symbol so part number is invalid
    return $false
}

$File = Get-Content -Path .\Input.txt
$PartNos = @()

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
            $isValid = Assert-Validity -File $File -StartX ($StartX - 1) -EndX ($Chr + 1) -StartY ($Row - 1) -EndY ($Row + 1)

            # Add valid one to the final sum
            if ($isValid) { $PartNos += [int]$Digits }
        }
    }
}

($PartNos | Measure-Object -Sum).Sum
