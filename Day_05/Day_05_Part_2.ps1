function Split-Input {
    param (
        [string[]]$Data
    )
    
    $LineBreak = 0

    for ($i = 0; $i -lt $Data.Length; $i++) {
        if($Data[$i] -eq "") {
            $Linebreak = $i
            break
        }
    }

    Return $Data[0..($i-1)], $Data[($i+1)..($Data.Count)]
}

function Set-Stacks {
    param (
        [string[]]$Data
    )
    
    # Get the number of stacks (Max 9)
    $NoOfStacks = ($Data[-1].GetEnumerator() | Where-Object { $_ -ne " "}).Count
    
    # Create the stacks and add them to a collection
    $StackCollection = New-Object System.Collections.Generic.List[System.Object]
    for ($i = 0; $i -lt $NoOfStacks; $i++) {
        $Stack = New-Object System.Collections.Stack
        $StackCollection.Add($Stack)
    }
    
    # Go through each box row, get the value of boxes and add to relevant stack
    for ($i = $Data.Count -2; $i -gt $0; $i--) {
        # Go through chars on row
        $BoxValues = $null
        for ($x = 1; $x -lt ($NoOfStacks * 4); $x += 4) {
            $BoxValues += $Data[$i][$x]
        }

        # Add the current row to the stacks
        $StackIndex = 0
        foreach ($Box in $BoxValues.GetEnumerator()) {
            if ($Box -ne " ") {
                $StackCollection[$StackIndex].Push($Box)
            }

            $StackIndex++
        }
    }

    $StackCollection
}

function Sort-Stacks {
    param (
        [String[]]$Instructions,
        [System.Object]$Stacks
    )
    
    foreach ($Row in $Instructions) {
        $Row -match 'move (\d+) from (\d+) to (\d+)' | Out-Null

        $Claw = New-Object System.Collections.Stack
        for ($i = 0; $i -lt $Matches[1]; $i++) {
            $Crate = $Stacks[(($Matches[2]-1))].Pop()
            $Claw.Push($Crate)
        }
        
        $BoxesHeld = $Claw.Count
        for ($i = 0; $i -lt $BoxesHeld; $i++) {
            $Stacks[(($Matches[3]-1))].Push($Claw.Pop())
        }

    }

    $FinalResult = foreach ($Stack in $Stacks) {
        $Stack.Peek()
    }
    
    $FinalResult -join ""
}

$Splitinput = Split-Input -Data (Get-Content .\input.txt)
$Stacks = Set-Stacks -Data $SplitInput[0]
Sort-Stacks -Instructions $SplitInput[1] -Stacks $Stacks