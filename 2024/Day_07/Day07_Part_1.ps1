################################################
# Functions
################################################

function Get-Permutations {
    param(
        [long[]]$Array,
        [int]$Size = $Array.Length
    )
    $results = @()
    if ($Size -eq 1) {
        $results += ($Array -join ", ")
    }
    else {
        # First recursive call
        $results += Get-Permutations -Array $Array -Size ($Size - 1)

        # Track duplicates at this recursion level
        $seen = New-Object System.Collections.Generic.HashSet[long]
        $seen.Add($Array[$Size - 1]) | Out-Null

        for ($i = 0; $i -lt $Size - 1; $i++) {
            if ($Size % 2 -eq 0) {
                $temp = $Array[$i]
                $Array[$i] = $Array[$Size - 1]
                $Array[$Size - 1] = $temp
            }
            else {
                $temp = $Array[0]
                $Array[0] = $Array[$Size - 1]
                $Array[$Size - 1] = $temp
            }

            # Only recurse if the last element hasn't been used at this level
            if ($seen.Add($Array[$Size - 1])) {
                $results += Get-Permutations -Array $Array -Size ($Size - 1)
            }
        }
    }
    return $results
}
function Create-Formula {
    param(
        [long[]]$Numbers,
        [string[]]$Operators
    )

    $ArrayToTest = @()
    $Operators = $Operators -split ", "

    for ($x = 0; $x -le $Numbers.Length - 1; $x++) {
        $ArrayToTest += $Numbers[$x]
        
        if ($null -ne $Operators[$x]) {
            if ($Operators[$x] -eq 0) {
                $ArrayToTest += "+"
            }
            else {
                $ArrayToTest += "*"
            }
        }
    }

    return $ArrayToTest 
}
function Test-Row {
    param(
        [long]$TargetNumber,
        [PsCustomObject]$Permutations,
        [long[]]$Numbers
    )

    $MaxNumberAttempt = $Numbers -join "*" 
    $Attempt = Invoke-Expression -Command "$MaxNumberAttempt"
    if ($Attempt -lt $TargetNumber) {
        return 0 
    }

    $Numbers = $Numbers -split ", "
    foreach ($perm in $Permutations) {
        $Formula = Create-Formula -Numbers $Numbers -Operators $perm
        # Write-Host "Calculation: $Formula" -NoNewline
    
        $FirstSum = $Formula[0..2] -join ""
        $RemainingSums = @()

        for ($i = 3; $i -lt $Formula.Count; $i += 2) {
            $RemainingSums += $Formula[$i] + $Formula[$i + 1]
        }

        $Result = Invoke-Expression -Command $FirstSum
        foreach ($sum in $RemainingSums) {
            $Sum -match '\d+$' | Out-Null
            $Right = $Matches[0] 

            $Operator = ""
            if ($sum -like "+*") {
                $Operator = "+"
            }
            else {
                $Operator = "*"
            }

            $Result = Invoke-Expression -Command "$Result $Operator $Right"
        }

        # Write-Host " = $Result"
        if ($Result -eq $TargetNumber) {
            # Found number
            return $Result
        }

    }

    # Gone through every permutation but cannot find target number
    return 0
}

################################################
# Script
################################################

$Data = Get-Content .\Input.txt
$HashTable = @{}
$Results = 0

# Create Hashtable Keys first
Write-Host "Creating Hashtables Keys..." -NoNewLine
foreach ($row in $data) {
    $Numbers = ($Row -split ": ")[1]
    $Numbers = $Numbers -split " "
    $NumbersCount = $Numbers.Count - 1


    if (!$HashTable.ContainsKey($NumbersCount)) {
        $HashTable[$NumbersCount] = @()
    }
}
Write-Host "Complete!"

# Create Hashtable Values
Write-Host "Populating Hashtables..." -NoNewLine
$HashTableKeyCount = $HashTable.Keys.Count
$HashTableNumber = 0
foreach ($operatorCount in @($HashTable.Keys)) {
    $HashTableNumber += 1
    Write-Host "Currently on $HashTableNumber / $HashTableKeyCount"
    $KeyPermutations = @()


    # All Zeros
    $Permutation = @()
    for ($i = 0; $i -lt $operatorCount; $i++) {
        $Permutation += 0
    }

    $KeyPermutations += Get-Permutations -Array $Permutation | Select-Object -Unique
    # TODO: Probably an easier way to do this but was struggling to get PowerShell to stop treating it like a string...

    for ($p = 1; $p -lt $operatorCount + 1; $p++) {
        $Permutation = @()
        for ($o = 0; $o -lt $operatorCount; $o++) {
            if ($o -lt $p) {
                $Permutation += 1
            }
            else {
                $Permutation += 0
            }
        }

        $KeyPermutations += Get-Permutations -Array $Permutation | Select-Object -Unique
        $HashTable[$operatorCount] = $KeyPermutations
    }
}

Write-Host "Complete!"

# Go through the rows and perform calculations
Write-Host "Starting to go through rows..."
$RowCount = $Data.Count
$RowNumber = 0

foreach ($row in $Data) {
    $RowNumber += 1 
    Write-Host "Currently on Row $RowNumber of $RowCount" -NoNewline
    $TargetNumber, $Numbers = $Row -split ": "
    $Numbers = $Numbers -split " "
    $operatorsCount = $Numbers.Count - 1

    $Result = Test-Row -TargetNumber $TargetNumber -Permutations $HashTable[$operatorsCount] -Numbers $Numbers
    if ($Result -eq 0) {
        Write-Host " Failed" -ForegroundColor Red
        continue
    }

    Write-Host " Success!" -ForegroundColor Green
    $Results += $Result
}

Write-Host "Results: $Results"