function Get-DataSets {
    # Reads the data but returns them as two variables based on the line break
    param (
        [string]$File
    )
    
    $Data = Get-Content -Path $File

    $Rules = @()
    $PageRows = @()

    $BeforeLineBreak = $True
    foreach ($Row in $Data) {
        if ($Row -eq "") {
            $BeforeLineBreak = $False
            continue
        }
    
        if ($BeforeLineBreak -eq $True) {
            $Rules += $Row
        }
        else {
            $PageRows += $Row
        }
    }

    return $Rules, $PageRows
}

function New-HashTable {
    # Creates a hashtable of the rules
    param (
        [string[]]$Rules
    )

    $HashTable = @{}

    foreach ($row in $Rules) {
        $Key, $Value = $row -split "\|"

        if (!$HashTable.ContainsKey($Key)) {
            $HashTable[$Key] = @()
            $HashTable[$Key] += $Value
            continue
        }

        $HashTable[$Key] += $Value
    }

    return $HashTable
}

function Get-RuleResult {
    # Goes through the current number and checks if it's in the rules, returns true/false if it meets the requirements
    param (
        [string[]]$AllPages,
        [string]$CurrentPage,
        [hashtable]$HashTable
    )
    
    $mustComeAfter = $HashTable[$AllPages[$CurrentPage]]

    foreach ($number in $mustComeAfter) {
        $previousItems = $AllPages[0..$CurrentPage]
        if ($number -in $previousItems) {
            return $false
        }
    }

    return $true
}

function Update-Row {
    # This row failed so requires sorting
    param(
        [hashtable]$HashTable,
        [string]$Row
    )

    $pages = $Row -split " "
    $changesMade = $false
    for ($x = 0; $x -lt $pages.Count; $x++) {
        if ($null -eq $HashTable[$pages[$x]]) {
            # This doesn't need to be sorted as both numbers aren't in the dictionary
            continue
        }

        foreach ($value in $HashTable[$pages[$x]]) {
            # Go through each number up to the current (x) and if the number matches the Hashtable, swap
            for ($z = 0; $z -lt $x; $z++) {
                if ($pages[$z] -eq $value) {
                    $pages[$z] = $pages[$x]
                    $pages[$x] = $value
                    $changesMade = $true
                }
            }
        }
    }

    if ($changesMade) {
        return $pages 
    }

    return $pages 
}

function Get-RowResult {
    # This gets the result for the entire row
    param (
        [hashtable]$HashTable,
        [string]$Row
    )

    $allPages = $Row -split ","

    $PreviouslyFaulty = $false
    for ($x = 0; $x -lt $allPages.Count; $x++) {
        $isValid = Get-RuleResult -AllPages $allPages -CurrentPage $x -HashTable $HashTable
        
        while ($isValid -eq $false) {
            $allPages = Update-Row -HashTable $HashTable -Row $allPages
            $isValid = Get-RuleResult -AllPages $allPages -CurrentPage $x -HashTable $HashTable
            $PreviouslyFaulty = $true
        }
    }

    if (!$PreviouslyFaulty) {
        return 0
    }

    return $allPages[(($allPages.Count - 1) / 2) ]
}

#########################
# Script
#########################
$rules, $pageRows = Get-DataSets -File ".\Input.txt"
$hashTable = New-HashTable -Rules $Rules
$answer = 0

foreach ($row in $pageRows) {
    $result = Get-RowResult -Hashtable $hashTable -Row $row
    if ($result -eq $false) {
        continue 
    }

    $answer += $result
}   

$answer