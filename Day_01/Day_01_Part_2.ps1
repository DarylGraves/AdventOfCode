function Get-HighestCalories {
    param (
        [string[]]$Data,
        [int]$Top
    )
    
    $Data = $Data -split '(\r?\n){2,}'  -match '\d'
    $ElfNo = 0
    
    $Elves = foreach ($Elf in $Data) {
        $ElfNo += 1
        $Rucksack = $Elf -split '(\r?\n)' -match '\d' 
        $Calories = 0

        foreach ($Food in $Rucksack) {
            $Calories += $Food
        }
        
        $Calories
    }

    ($Elves | Sort-Object -Descending | Select-Object -First 3 | Measure-Object -Sum).Sum
}

$Data = Get-Content ".\input.txt" -Raw
Get-HighestCalories -Data $Data -Top 3