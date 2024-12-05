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
    # Goes through the e.g 47|53) and returns true/false if it meets the requirements
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

function Get-RowResult {
    # A row is a of format 75,47,61,53,29
    param (
        [hashtable]$HashTable,
        [string]$Row
    )

    $allPages = $Row -split ","

    for ($x = 0; $x -lt $allPages.Count; $x++) {
        if ($null -ne $HashTable[($allPages[$x])]) {
            $isValid = Get-RuleResult -AllPages $allPages -CurrentPage $x -HashTable $HashTable
            if ($isValid -eq $false) {
                Write-Host "$Row failed the test" -ForegroundColor Red
                return $false
            }
        }
    }

    Write-Host "$Row passed the test" -ForegroundColor Green
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
    Write-Host "Result is $result"

    $answer += $result
}   

$answer