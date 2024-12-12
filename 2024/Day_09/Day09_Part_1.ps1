$Data = Get-Content .\Input.txt

$AllValues = [System.Collections.Generic.List[long]]::new()

$Id = 0
for ($x = 0; $x -lt $Data.Length; $x += 2) {
    $noOfFiles = [int][string]$Data[$x]
    $noOfWhiteSpace = [int][string] $Data[$x + 1]

    for ($i = 0; $i -lt $noOfFiles; $i++) {
        $AllValues.Add($Id)
    }

    for ($i = 0; $i -lt $noOfWhiteSpace; $i++) {
        $AllValues.Add(-1)
    }
    $Id += 1
}

# Re-sort
$Back = $AlLValues.Count - 1
for ($x = 0; $x -lt $AllValues.Count; $x++) {
    # Skip if there is already a valid Id
    if ($AllValues[$x] -ge 0) {
        continue
    }

    # Skip if AllValues is empty space
    while ($AllValues[$Back] -eq -1) {
        $Back -= 1
        continue
    }

    # Finish if the front has gone past the back
    if ($x -ge $Back) {
        break
    }

    $Moving = $AllValues[$Back]
    $AllValues[$x] = $Moving
    $AllValues[$Back] = -1
    $Back -= 1
}


$Result = 0
for ($x = 0; $x -lt $AllValues.Count; $x++) {
    if ($AllValues[$x] -eq -1) {
        break
    }
    $Result += ($AllValues[$x] * $x)
}

Write-Host $Result