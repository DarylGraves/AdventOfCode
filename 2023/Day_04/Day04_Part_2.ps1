$File = Get-Content -Path .\Input.txt

$Cards = @{}
# Create the initial cards (one per number)
for ($i = 0; $i -lt $File.Count; $i++) {
    $Cards[$i + 1 ] = 1
}

foreach ($Row in $File) {
    # Get the current card number
    $CardNo = [int] (($Row -split ":")[0] -split ' +')[1]

    # Break down the row on the text file
    $WinningNos = ((($Row -split ": ")[1] -split ' \| ')[0]) -split " " | Where-Object { $_ -notlike $null}
    $ScratchedNos = ((($Row -split ": ")[1] -split ' \| ')[1]) -split " " | Where-Object { $_ -notlike $null }

    # Find how many winning matches we have
    $MatchingNos = 0
    foreach ($no in $WinningNos) {
        if($no -in $ScratchedNos) {
            $MatchingNos += 1
        }
    }

    # Determined how many cards are gained...
    for ($i = 0; $i -lt $MatchingNos; $i++) {
        $Cards[$CardNo + $i + 1] += $Cards[$CardNo]
    }

}

($Cards.Values | Measure-Object -Sum).Sum