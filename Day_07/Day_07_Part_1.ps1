enum ItemType {
    File
    Directory
}
class Item {
    [Item]$Parent;
    [System.Collections.ArrayList]$Contents;
    [String]$Name;
    [Double]$Size;
    [ItemType]$ItemType
}

function New-Content {
    param (
        [Switch]$Root,
        [String]$Name
    )

    if ($Root) {
        return New-Object -TypeName Item -Property @{
            Parent = $null;
            Contents = New-Object -Type System.Collections.ArrayList
            Name = "\"
            Size = 0
            ItemType = [ItemType]::Directory
        }
    }
    elseif ($File) {
        # TODO: Not working yet
    }
    elseif ($Directory) {
        # TODO: Not working yet
    }
    
}

function Get-Output {
    param (
        [int]$StartRow,
        [string[]]$Data
    )
    # Returns row numbers which do not begin "$"
    for ($i = $StartRow; $i -lt $Data.Count; $i++) {
        if ($Data[$i][0] -eq "$") {
            Return $StartRow, $i
        }
    }    

    # If we reach the end of the file, still return.
    return $StartRow, $Data.Count
}

function New-FolderStructure {
    param (
        [string[]]$Data
    )
    
    $FolderStructure = $null

    for ($i = 0; $i -lt $Data.Count; $i++) {
        if ($Data[$i][0] -eq '$') {
            switch -Regex ($Data[$i]) {
                '\$ cd \/' { 
                    Write-Host "Root Directory"
                    $FolderStructure = New-Content -Root
                    break;
                }

                '\$ ls' { 
                    Write-Host "Ls - Get-Output"
                    $TextToParse = Get-Output -StartRow ($i+1) -Data $Data
                    $i = ($TextToParse[1] - 1)

                    for ($y = $TextToParse[0]; $y -lt $TextToParse[1]; $y++) {
                        switch -Regex ($Data[$y]) {
                            'dir (\w.*)' { 
                                # Creating Directory
                                $NewItem = New-Object -TypeName Item -Property @{
                                    Parent = $FolderStructure
                                    Contents = New-Object -Type System.Collections.ArrayList
                                    Name = $Matches[1]
                                    Size = 0
                                    ItemType = [ItemType]::Directory
                                }

                                $folderStructure.Contents.Add($NewItem)
                                break;
                            }

                            '(\d.*) (\w.*)' {
                                # Creating File
                                $NewItem = New-Object -TypeName Item -Property @{
                                    Parent = $FolderStructure
                                    Contents = New-Object -Type System.Collections.ArrayList
                                    Name = $Matches[2]
                                    Size = $Matches[1] 
                                    ItemType = [ItemType]::File
                                }

                                $FolderStructure.Contents.Add($NewItem)
                                break;
                            }
                            Default {}
                        }
                    }
                    break;
                }
                
                '\$ cd ..' { 
                    Write-Host "cd .."
                    $FolderStructure = $FolderStructure.Parent
                    break;
                }

                '(\$ cd )(\w.*)' { 
                    Write-Host "cd $($Matches[2])"
                    Write-Host $FolderStructure.Contents.Name -ForegroundColor Yellow
                    $FolderStructure = ($FolderStructure.Contents | Where-Object { $_.Name -eq $Matches[2] } )
                    break;
                }

                Default {}
            }
        }
    }

    # Rewind back to the Root

    while($FolderStructure.Parent -ne $null)
    {
        $FolderStructure = $FolderStructure.Parent
    }

    return $FolderStructure
}

function Get-FolderSizes {
    param (
        [Item[]]$Data
    )
    
    $Data
}

$Content = New-FolderStructure -Data (Get-Content .\input.txt)
$Content