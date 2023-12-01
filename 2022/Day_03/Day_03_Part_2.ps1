function Get-PriorityTotal {
    param (
        [string[]]$Rucksacks,
        [int]$NumberinGroup
    )

    $Total = 0   
    for ($i = 0; $i -lt $Rucksacks.Count; $i += $NumberInGroup) {
        $Bag1, $Bag2, $Bag3 = $Rucksacks[$i], $Rucksacks[$i+1], $Rucksacks[$i+2]

        $Badge = $null
        foreach ($char in $Bag1.GetEnumerator()) {
            if(($char -cin $Bag2.GetEnumerator()) -and ($char -cin $Bag3.GetEnumerator())) {
                $Badge = $char
                break
            }
        }

        if ([int][char]$Badge -gt 96) { $Priority = ([int][char]$Badge - 96) }
        else { $Priority = ([int][char]$Badge - 38) }

        $Total += $Priority
    }

    $Total
}

Get-PriorityTotal -Rucksacks (Get-Content .\input.txt) -NumberinGroup 3