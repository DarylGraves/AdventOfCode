$Data = Get-Content .\Input.txt

$NoOfRows = $Data.Count
$NoOfColumns = $Data[0].Length

$WordToFind = "XMAS"
$MatchResults = @() 

function Get-DirectionCoordinates {
    # Determines the direction coordinates for Find-Match
    param (
        [String]$Direction
    )

    switch ($Direction) {
        "Up" { return 0, -1 }
        "Down" { return 0, 1 }
        "Left" { return -1, 0 }
        "Right" { return 1, 0 }
        "UpLeft" { return -1, -1 }
        "UpRight" { return 1, -1 }
        "DownLeft" { return -1, 1 }
        "DownRight" { return 1, 1 }
    }

    Write-Error "Invalid Direction"
}

function Start-Scan {
    # This will loop through all the directions and trigger a scan
    param (
        [string]$WordToFind,
        [System.Object[]]$Data,
        [int]$XStartPos,
        [int]$YStartPos
    )

    $Directions = @("Up", "Down", "Left", "Right", "UpLeft", "UpRight", "DownLeft", "DownRight")

    foreach ($Direction in $Directions) {
        $XDirection, $YDirection = Get-DirectionCoordinates -Direction $Direction
        Find-Match -WordToFind $WordToFind -Data $Data -XStartPos $XStartPos -YStartPos $YStartPos -XDirection $XDirection -YDirection $YDirection
    }
}

function Find-Match {
    # Scans in one direction to see if the word can be found
    param (
        [string]$WordToFind,
        [System.Object[]]$Data,
        [int]$XStartPos,
        [int]$YStartPos,
        [int]$XDirection,
        [int]$YDirection
    )

    Write-Host "Starting at X: $XStartPos Y: $YStartPos"
    
    $CharsToFind = $WordToFind[1..$WordToFind.Length]

    $XCurrentPosition = $XStartPos
    $YCurrentPosition = $YStartPos

    $NoOfRows = $Data.Count
    $NoOfColumns = $Data[$YStartPos].Length

    foreach ($character in $CharsToFind) {
        # Left/Right
        $XCurrentPosition += $XDirection 
        # Up/Down
        $YCurrentPosition += $YDirection

        # Border Validation (Checking we're not out of bounds)
        if (($XCurrentPosition -lt 0) -or ($XCurrentPosition -gt $NoOfRows - 1)) {
            return $false
        }

        if (($YCurrentPosition -lt 0) -or ($YCurrentPosition -gt $NoOfColumns - 1)) {
            return $false
        }

        # Check the character is the correct one
        if ($Data[$YCurrentPosition][$XCurrentPosition] -ne $character) {
            return $false
        }
    }

    return $true
}

for ($y = 0; $y -lt $NoOfRows; $y++) {
    for ($x = 0; $x -lt $NoOfColumns; $x++) {
        if ($Data[$y][$x] -eq $WordToFind[0]) { 
            $MatchResults += Start-Scan -WordToFind $WordToFind -Data $Data -XStartPos $X -YStartPos $Y
        }
    }
}

($MatchResults | Where-Object { $_ -eq $true }).count
