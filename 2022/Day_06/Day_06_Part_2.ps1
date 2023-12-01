function Find-Buffer {
    param (
        [string]$Datastream,
        [int]$ConsecutiveNos
    )
    
    $result = $ConsecutiveNos
    for ($i = 0; $i -lt $Datastream.Length; $i++) {
        if ( ($Datastream[$i..($i+($ConsecutiveNos-1))] |
                Group-Object |
                Sort-Object Count -Descending |
                Select-Object -First 1).Count -eq 1
        )   {
            break
        }
        else {
            $result++
        }
    }

    $result
}

$Data = Get-Content .\input.txt
foreach ($Row in $Data) {
    Find-Buffer -Datastream $Row -ConsecutiveNos 14
}