$File = Get-Content -Path .\Input.txt

$Conversion = @{
    one = 1
    two = 2
    three = 3
    four = 4
    five = 5
    six = 6
    seven = 7
    eight = 8
    nine = 9
}

$Results = @()
foreach($Row in $File) {
    $Numbers = @()
    for ($i = 0; $i -lt $Row.Length; $i++) {
        # Number
        if([Int32]::TryParse($Row[$i], [ref]$OutNumber)) {
            $Numbers += $OutNumber
            continue
        }

        # Current char not a number - Scan ahead for words
        for ($e = $i; $e -lt $Row.Length; $e++) {
            if(($Row[$i..$e] -join "") -in $Conversion.Keys) {
                $Numbers += $Conversion[$Row[$i..$e] -join ""]
                continue
            }
        }
    }

    $Results += [string]$Numbers[0] + [string]$Numbers[-1]
}

($Results | Measure-Object -Sum).Sum
