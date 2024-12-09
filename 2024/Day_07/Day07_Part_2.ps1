$Global:AllRowResult = @()
function Calculate-Options {
    param(
        [long[]]$Numbers,
        [long]$CurrentNo = 0,
        [long]$Target,
        [System.Numerics.BigInteger]$TotalSoFar = 0,
        [switch]$All
    )

    $Global:FunctionInvokes += 1
    # Write-Host "Calculate-Options: " -NoNewline
    # Write-Host "Numbers $Numbers " -ForegroundColor Blue -NoNewline
    # Write-Host "Function Invocations: $Global:FunctionInvokes " -NoNewline -ForegroundColor Cyan
    # Write-Host "TotalSoFar: $TotalSoFar " -ForegroundColor Magenta -NoNewline
    # Write-Host "Current Interation : $CurrentNo " -ForegroundColor Yellow  -NoNewLine
    # Write-Host "All: $All" -ForegroundColor White

    if (($CurrentNo -eq $Numbers.Count) -and ($TotalSoFar -eq $Target)) {
        # We're on the final one AND it's the target
        $Global:AllRowResult += $TotalSoFar
        return
    }

    if (($CurrentNo -eq $Numbers.Count) -and ($TotalSoFar -ne $Target)) {
        # We got to the end but didn't hit the target
        return
    }
    if ($Global:AllRowResult -contains $Target) {
        # We've already found it
        return
    }

    if ($CurrentNo -gt $Target) {
        return
    }

    if ($CurrentNo -eq 0) {
        if ($All) {
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] + $Numbers[1]) -Target $Target -All
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] * $Numbers[1]) -Target $Target -All
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ([long] ("$($Numbers[0])" + "$($Numbers[1])")) -Target $Target -All
        }
        else {
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] + $Numbers[1]) -Target $Target
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] * $Numbers[1]) -Target $Target
        }
    }
    else {
        if ($All) {
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar + $Numbers[$CurrentNo]) -Target $Target -All
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar * $Numbers[$CurrentNo]) -Target $Target -All
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ([long] ("$TotalSoFar" + "$($Numbers[$CurrentNo])")) -Target $Target -All

        }
        else {
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar + $Numbers[$CurrentNo]) -Target $Target
            Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar * $Numbers[$CurrentNo]) -Target $Target
        }
    }
}

$Data = Get-Content .\Input.txt
$Result = 0

$RowNo = 0 # Just for display purposes
$RowCount = $Data.Count
foreach ($row in $Data) {
    $RowNo += 1
    $Global:AllRowResult = @()
    $Global:FunctionInvokes = 0
    $Target, $Numbers = $row -split ": "
    $Numbers = $Numbers -split " "

    Write-Host "$RowNo / $RowCount - Goal: $Target - $Numbers " -ForegroundColor Blue -NoNewLine
    Calculate-Options -Numbers $Numbers -Target $Target
    
    if ($Global:AllRowResult -Contains $Target) {
        Write-Host "Success" -ForegroundColor Green
        $Result += $Target
        continue
    }

    Write-Host "Failed. Retrying with || " -ForegroundColor Yellow -NoNewLine
    $Global:AllRowResult = @()
    Calculate-Options -Numbers $Numbers -Target $Target -All

    if ($Global:AllRowResult -Contains $Target) {
        Write-Host "Success with ||" -ForegroundColor Green
        $Result += $Target
    }
    else {
        Write-Host "Still fail." -ForegroundColor Red
    }
}

Write-Host $Result