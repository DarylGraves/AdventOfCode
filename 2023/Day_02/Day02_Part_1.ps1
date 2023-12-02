$File = Get-Content .\Input.txt

$MaxCubes = @{
    red = 12
    green = 13
    blue = 14
}

$ValidIDs = @()
foreach ($Row in $File) {
    $Id = ($Row -split ": ")[0] -Replace "\D"
    $GameRecord = ($Row -split ": ")[1] -split ", " -split "; "
    
    $isValid = $True
    foreach ($CubeSet in $GameRecord) {
        $Number, $Color = $CubeSet -split " "

        if ([int]$Number -gt $MaxCubes[$Color]) {
            $isValid = $False
            break
        }
    }

    if($isValid)
    {
        $ValidIds += $Id
    }
}

($ValidIDs | Measure-Object -Sum).Sum