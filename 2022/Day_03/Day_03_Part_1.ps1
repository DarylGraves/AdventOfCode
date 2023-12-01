function Get-PriorityTotal {
    param (
        [string[]]$Rucksacks
    )
    
    $Total = 0
    foreach ($Rucksack in $Rucksacks) {
        $Comp1, $Comp2 = $Rucksack[0..($Rucksack.Length / 2 -1)], $Rucksack[($Rucksack.Length / 2) .. ($Rucksack.Length - 1)]
        
        $Duplicate = $null
        foreach ($char in $Comp1) {
            if ($char -cin $Comp2) {
                $Duplicate = $char
                break
            }
        }

        # Convert Duplicate to Priority.
        # a-z = 1-26
        # A-Z = 27-52

        if ([int][char]$Duplicate -gt 96) { $Priority = ([int][char]$Duplicate - 96) }
        else { $Priority = ([int][char]$Duplicate - 38) }

        $Total += $Priority
    }

    $Total
}

Get-PriorityTotal -Rucksacks (Get-Content .\input.txt)