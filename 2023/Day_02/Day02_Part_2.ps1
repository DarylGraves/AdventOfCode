$File = Get-Content .\Input.txt

$Power = @()
$ValidIDs = @()
foreach ($Row in $File) {
    $Id = ($Row -split ": ")[0] -Replace "\D"
    $GameRecord = ($Row -split ": ")[1] -split ", " -split "; "
    $maxBlue, $maxRed, $maxGreen = 0, 0, 0

    foreach ($CubeSet in $GameRecord) {
        $No, $Color = $Cubeset -split " "
        $No = [int]$No

        switch ($Color) {
            "blue" { 
                if ($No -gt $maxBlue) {
                    $maxBlue = $No
                }
             }
            "red" { 
                if ($No -gt $maxRed) {
                    $maxRed = $No
                }
             }
            "green" { 
                if ($No -gt $maxGreen) {
                    $maxGreen = $No
                }
             }
        }        
    }

    $Power += ([int]$maxBlue * [int]$maxRed * [int]$maxGreen)
}

($Power | Measure-Object -Sum).Sum