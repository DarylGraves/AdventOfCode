$Data = Get-Content .\Input.txt
$ReportResults = @()

function Get-AscOrDesc {
    param (
        $NumOne,
        $NumTwo
    )
    
    if ($NumOne -gt $NumTwo) {
        return "Descending"
    }

    return "Ascending"
}

function Get-ReportResult {
    param(
        $Values,
        $AscOrDesc
    )

    for ($i = 0; $i -lt $Values.Count - 1; $i++) {
        $ValueOne = [int] $Values[$i]
        $ValueTwo = [int] $Values[$i + 1]
        $Difference = $ValueTwo - $ValueOne

        if ($Difference -eq 0) {
            return "Failed - $ValueOne and $ValueTwo are the same number"
        }

        if ($Difference -lt 0) {
            $Difference *= -1
        }

        if ($Difference -gt 3) {
            return "Failed - Jump between $ValueOne and $ValueTwo is too big"
        }

        if ($AscOrDesc -eq "Ascending" -and ($ValueOne -gt $ValueTwo)) {
            return "Failed - Ascending but $ValueOne was greater than $ValueTwo"
        }

        if ($AscOrDesc -eq "Descending" -and ($ValueOne -lt $ValueTwo)) {
            return "Failed - Descending but $ValueOne is less than $ValueTwo"
        }
    }

    return "Passed"
}

foreach ($Report in $Data) {
    $Values = ($Report -split " #")[0] -split " "
    $Values = [System.Collections.ArrayList] $Values

    Write-Host "Starting Value: $Values" -ForegroundColor Yellow
    $AscOrDesc = Get-AscOrDesc -NumOne ([int] $Values[0]) -NumTwo ([int] $Values[1])

    $Results = Get-ReportResult -Values $Values -AscOrDesc $AscOrDesc
    if ($Results -like "Passed*") {
        Write-Host "Passed on initial row`n" -ForegroundColor green
    }
    else {
        Write-Host "Failed on initial row, attempting to remove chars" -ForegroundColor DarkYellow
    }

    if ($Results -like "Failed*") {
        for ($i = 0; $i -lt $Values.Count; $i++) {
            if ($Results -notlike "Failed*") {
                # A test passed!
                break
            }

            $ValuesWithOneRemoved = $Values.Clone() # Need to be a value, not reference.
            for ($x = 0; $x -lt $Values.Count; $x++) {
                if ($x -eq $i) {
                    Write-Host "$($Values[$x]) " -ForegroundColor Red -NoNewline
                }
                else {
                    Write-Host "$($Values[$x]) " -ForegroundColor Blue -NoNewline
                }
            }

            $ValuesWithOneRemoved.RemoveAt($i)
            $AscOrDesc = Get-AscOrDesc -NumOne ([int] $ValuesWithOneRemoved[0]) -NumTwo ([int] $ValuesWithOneRemoved[1])

            $Results = Get-ReportResult -Values $ValuesWithOneRemoved -AscOrDesc $AscOrDesc
            if ($Results -like "Passed*") {
                Write-Host "$Results" -ForegroundColor Green
            }
            else {
                Write-Host "$Results" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    $ReportResults += $Results
}

$Count = ($ReportResults | Where-Object { $_ -like "Passed*" }).Count
Write-Host "Total Passed: $Count" -ForegroundColor DarkCyan