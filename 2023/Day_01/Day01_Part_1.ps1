$File = Get-Content -Path .\input.txt

$Results = @()
foreach($Row in $File) {
    $Nums = $Row -Replace "[a-zA-z]", ""
    $Results += [string]$Nums[0] + [string]$Nums[-1]
}
($Results | Measure-Object -Sum).Sum
