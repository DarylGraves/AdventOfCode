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
            return "Failed"
        }

        if ($Difference -lt 0) {
            $Difference *= -1
        }

        if ($Difference -gt 3) {
            return "Failed"
        }

        if ($AscOrDesc -eq "Ascending" -and ($ValueOne -gt $ValueTwo)) {
            return "Failed"
        }

        if ($AscOrDesc -eq "Descending" -and ($ValueOne -lt $ValueTwo)) {
            return "Failed"
        }
    }

    return "Passed"
}

foreach ($Report in $Data) {
    $Values = $Report -split " "
    $AscOrDesc = Get-AscOrDesc -NumOne ([int] $Values[0]) -NumTwo ([int] $Values[1])

    $ReportResults += Get-ReportResult -Values $Values -AscOrDesc $AscOrDesc
}

($ReportResults | Where-Object { $_ -eq "Passed" }).Count