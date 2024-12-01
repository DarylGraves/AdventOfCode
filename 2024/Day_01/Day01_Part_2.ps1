$Data = Get-Content .\Input.txt
$CountofRows = $Data.Length

$LeftRows = @()
$RightRows = @()

foreach ($Row in $Data) {
    $LeftRows += ($Row -split "   ")[0]
    $RightRows += ($Row -split "   ")[1]
}

$ToAdd = @()
$LeftSideSorted = $LeftRows | Sort-Object -Descending
$RightSideSorted = $RightRows | Sort-Object -Descending

for ($i = $CountofRows; $i -gt 0; $i--) {
    $LeftNumber = $LeftSideSorted[$i - 1]
    $CountOnRight = ($RightSideSorted | Where-Object { $_ -eq $LeftNumber }).Count 
    $ToAdd += ([int]$LeftNumber * [int]$CountOnRight)
}

$ToOutput = 0

foreach ($Result in $ToAdd) {
    $ToOutput += $Result
}

$ToOutput