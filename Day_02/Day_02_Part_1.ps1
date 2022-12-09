function Get-Score {
    param (
        [string[]]$Data
    )

    $TotalScore = 0
    foreach ($Row in $Data) {
        $Hands = $Row -split " "
        $Hands[0] = ([int][char]$Hands[0]) - 64
        $Hands[1] = ([int][char]$Hands[1]) - 87
    
        $Score = 0

        if ($Hands[1] -eq $Hands[0])
        {
            #Draw
            $Score = [int]$Hands[1] + 3
        }
        elseif (($Hands[1] -eq 1) -and ($Hands[0] -eq 3)) {
            # Win via overlap
            $Score = [int]$Hands[1] + 6
        }
        elseif (($Hands[1] -eq 3) -and ($Hands[0] -eq 1)) {
            $Score = [int]$Hands[1]
        }
        elseif ($Hands[1] -gt $Hands[0]) {
            # Win
            $Score = [int]$Hands[1] + 6
        }
        else {
            # Loss
            $Score = [int]$Hands[1]
        }
    
        $TotalScore += $Score
    }
    
    $TotalScore
}

$Games = Get-Content -Path ./input.txt 
Get-Score -Data $Games