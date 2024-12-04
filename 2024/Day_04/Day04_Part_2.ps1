$Data = Get-Content .\Input.txt

$NoOfRows = $Data.Count
$NoOfColumns = $Data[0].Length

$MatchResults = @()

function Start-Scan {
    # This will loop through all the directions and trigger a scan when it finds "A"
    param (
        [System.Object[]]$Data,
        [int]$XStartPos,
        [int]$YStartPos
    )

    $Count = Find-Match -Data $Data -XStartPos $XStartPos -YStartPos $YStartPos -XDirection $XDirection -YDirection $YDirection
    return $Count
}

function Find-Match {
    # Scans in one direction to see if the pattern can be found
    param (
        [System.Object[]]$Data,
        [int]$XStartPos,
        [int]$YStartPos
    )

    $NoOfRows = $Data.Count
    $NoOfColumns = $Data[0].Length

    if (
        (($XStartPos - 1) -lt 0) -or 
        (($XStartPos + 1) -gt $NoOfColumns - 1) -or
        (($YStartPos - 1) -lt 0) -or
        (($YStartPos + 1) -gt $NoOfRows - 1 )
    ) {
        # Out of Bounds
        return $false
    }

    $TopLeft = $Data[$YStartPos - 1][$XStartPos - 1]
    $TopRight = $Data[$YStartPos - 1][$XStartPos + 1]
    $BottomLeft = $Data[$YStartPos + 1][$XStartPos - 1]
    $BottomRight = $Data[$YStartPos + 1][$XStartPos + 1]

    $TestOne = ($TopLeft -eq "M" -and $BottomRight -eq "S") -or ($TopLeft -eq "S" -and $BottomRight -eq "M")
    $TestTwo = ($BottomLeft -eq "M" -and $TopRight -eq "S") -or ($BottomLeft -eq "S" -and $TopRight -eq "M")

    if ($TestOne -eq $true -and $TestTwo -eq $True) {
        return $true
    }
    else {
        return $false
    }
}

for ($y = 1; $y -lt $NoOfRows; $y++) {
    for ($x = 1; $x -lt $NoOfColumns; $x++) {
        if ($Data[$y][$x] -eq "A") { 
            $Answer = Start-Scan -Data $Data -XStartPos $X -YStartPos $Y
            $MatchResults += $Answer
        }
    }
}

($MatchResults | Where-Object { $_ -eq $true }).Count