$File = Get-Content -Path .\Input.txt

function Get-Points {
    param (
        [int]$Wins
    )

    if($Wins -eq 0) {
        return 0
    }

    $toReturn = 1
    for ($i = 1; $i -lt $Wins; $i++) {
        $toReturn *= 2
    }
    $toReturn
}

$totalPoints = 0
foreach ($Row in $File) {
    $WinningNos = ((($Row -split ": ")[1] -split ' \| ')[0]) -split " " | Where-Object { $_ -notlike $null}
    $ScratchedNos = ((($Row -split ": ")[1] -split ' \| ')[1]) -split " " | Where-Object { $_ -notlike $null }

    $Wins = 0
    foreach ($no in $WinningNos) {
        if($no -in $ScratchedNos) {
            $Wins += 1
        }
    }

    $totalPoints += Get-Points -Wins $Wins
}

$totalPoints