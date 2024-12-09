$Global:AllRowResult = @()
function Calculate-Options {
    param(
        [long[]]$Numbers,
        [long]$CurrentNo = 0,
        [long]$TotalSoFar = 0
    )

    if ($CurrentNo -eq $Numbers.Count) {
        $Global:AllRowResult += $TotalSoFar
        return
    }

    if ($CurrentNo -eq 0) {
        Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] + $Numbers[1])
        Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ($Numbers[0] * $Numbers[1])
        # Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 2) -TotalSoFar ([long] ("$($Numbers[0])" + "$($Numbers[1])"))
    }
    else {
        Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar + $Numbers[$CurrentNo])
        Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ($TotalSoFar * $Numbers[$CurrentNo])
        # Calculate-Options -Numbers $Numbers -CurrentNo ($CurrentNo + 1) -TotalSoFar ([long] ("$TotalSoFar" + "$($Numbers[$CurrentNo])"))
    }
}

$Data = Get-Content .\Input.txt
$Result = 0

$RowNo = 0 # Just for display purposes
$RowCount = $Data.Count
foreach ($row in $Data) {
    $RowNo += 1
    $Global:AllRowResult = @()
    $Target, $Numbers = $row -split ": "
    $Numbers = $Numbers -split " "

    Write-Host "$RowNo / $RowCount - Goal: $Target - $Numbers " -NoNewline -ForegroundColor Yellow
    Calculate-Options -Numbers $Numbers
    
    if ($Global:AllRowResult -Contains $Target) {
        Write-Host "Success" -ForegroundColor Green
        $Result += $Target
    }
    else {
        Write-Host "Fail" -ForegroundColor red
    }
}

Write-Host $Result