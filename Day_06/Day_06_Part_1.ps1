function Find-Buffer {
    param (
        [string]$Datastream
    )
    
    $result = 4
    for ($i = 0; $i -lt $Datastream.Length; $i++) {
        if (
            ($Datastream[$i], $Datastream[$i+1], $Datastream[$i+2], $Datastream[$i+3] |
                Group-Object |
                Sort-Object Count -Descending |
                Select-Object -First 1).Count -eq 1
            ) {
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
    Find-Buffer -Datastream $Row
}