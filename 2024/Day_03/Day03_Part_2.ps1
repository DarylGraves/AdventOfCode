$Data = Get-Content .\Input.txt
# $MulRegex = 'mul\(\d+,\d+\)|don''t()|do()'
$MulRegex = 'mul\(\d+,\d+\)|don''t\(\)|do\(\)'

$NumberRegex = '(\d+),(\d+)'

$MulMatches = ($Data | Select-String -Pattern $MulRegex -AllMatches).Matches

$Results = 0
$Enabled = $True

foreach ($result in $MulMatches) {
    if ($result.Value -like "do*") {
        $Enabled = $True
    }
    
    if ($result.Value -like "don*") {
        $Enabled = $False
    }

    $Numbers = ($result.Value | Select-String -Pattern $NumberRegex).Matches
    $NumberOne, $NumberTwo = $Numbers.Value -split ","

    if ($Enabled -eq $True) {
        $Results += ([int] $NumberOne * [int] $NumberTwo)
    }
}

$Results