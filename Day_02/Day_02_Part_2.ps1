function Get-Score {
    param (
        [string[]]$Data
    )

    # X = Loose
    # Y = Draw
    # Z = Win
    $TotalScore = 0
    foreach ($Row in $Data) {
        $Opponent = [int][char]($Row -split " ")[0] -64
        $PrefOutcome = ($Row -split " ")[1]

        # Draw
        if ($PrefOutcome -eq 'Y') {
            $Score = [int]$Opponent + 3
        }
        elseif ($PrefOutcome -eq 'X') {
            # Destined to Lose
            if ($Opponent -eq '1') {
                # Rock to Scissors
                $Score = 3
            }
            elseif ($Opponent -eq '2') {
                # Paper so Rock
                $Score = 1
            }
            else {
                # Scissors so paper
                $Score = 2
            }
        }
        if ($PrefOutcome -eq 'Z') {
            # Destined to Win
            if ($Opponent -eq '1') {
                # Rock so Paper
                $Score = 2 + 6
            }
            elseif ($Opponent -eq '2') {
                # Paper so Scissors
                $Score = 3 + 6 
            }
            else {
                # Scissors so Rock
                $Score = 1 + 6
            }
        }
        
        $TotalScore += $Score
    }
    
    $TotalScore
}

$Games = Get-Content -Path ./input.txt 
Get-Score -Data $Games