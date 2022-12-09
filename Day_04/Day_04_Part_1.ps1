function Get-Overlaps {
    param (
        [String[]]$Data
    )

    $NumberofConflicts = 0
    
    foreach ($ElfPair in $Data) {
        $Elf1 = ($ElfPair -split ",")[0]
        $Elf2 = ($ElfPair -split ",")[1]

        $Elf1Start = [int] ($Elf1 -split "-")[0]
        $Elf1End = [int] ($Elf1 -split "-")[1]

        $Elf2Start = [int] ($Elf2 -split "-")[0]
        $Elf2End = [int] ($Elf2 -split "-")[1]

        $Elf1Range = for ($i = $Elf1Start; $i -le $Elf1End; $i++) {
            $i
        }
        
        $Elf2Range = for ($i = $Elf2Start; $i -le $Elf2End; $i++) {
            $i
        }

        $Conflict = $True

        foreach ($Section in $Elf1Range) {
            if ($Section -notin $Elf2Range ) {
                $Conflict = $false
                break
            }
        }
        
        if ($Conflict) {
            $NumberofConflicts += 1
        }
        else {
            $Conflict = $True
            foreach ($Section in $Elf2Range) {
                if ($Section -notin $Elf1Range) {
                    $Conflict = $false
                    break
                }
            }
    
            if ($Conflict) {
                $NumberofConflicts += 1
            }
        }
    }

    $NumberofConflicts
}

Get-Overlaps -Data (Get-Content .\input.txt)