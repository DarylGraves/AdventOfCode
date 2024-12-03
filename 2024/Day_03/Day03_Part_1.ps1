$Data = Get-Content .\Input.txt
$MulRegex = 'mul\(\d+,\d+\)'
$NumberRegex = '(\d+),(\d+)'

$MulMatches = ($Data | Select-String -Pattern $MulRegex -AllMatches).Matches

$Results = 0 
foreach ($result in $MulMatches) {
    $Numbers = ($result.Value | Select-String -Pattern $NumberRegex).Matches
    $NumberOne, $NumberTwo = $Numbers.Value -split ","

    $Results += ([int] $NumberOne * [int] $NumberTwo)
}

$Results