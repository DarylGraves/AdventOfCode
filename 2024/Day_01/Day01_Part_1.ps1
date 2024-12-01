$Data = Get-Content .\Input.txt
$CountofRows = $Data.Length

$LeftRows = @()
$RightRows = @()

foreach ($Row in $Data) {
    $LeftRows += ($Row -split "   ")[0]
    $RightRows += ($Row -split "   ")[1]
}

$ToAdd = @()
$Result = @()
$LeftSideSorted = $LeftRows | Sort-Object -Descending
$RightSideSorted = $RightRows | Sort-Object -Descending

for ($i = $CountofRows; $i -gt 0; $i--) {
    $LeftSideComparison = $LeftSideSorted[$i - 1]
    $RightSideComparison = $RightSideSorted[$i - 1]

    if ($LeftSideComparison -gt $RightSideComparison) {
        $Adding = $LeftSideComparison - $RightSideComparison
        $ToAdd += $LeftSideComparison - $RightSideComparison
    }
    else {
        $Adding = $RightSideComparison - $LeftSideComparison
        $ToAdd += $RightSideComparison - $LeftSideComparison
    }
}

$ToOutput = 0
foreach ($Number in $ToAdd) {
    $ToOutput += $Number
}

$ToOutput