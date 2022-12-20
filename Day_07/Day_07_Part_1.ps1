enum ItemType {
    File
    Directory
}

class Item {
    [Item]$Parent;
    [System.Collections.ArrayList]$Contents;
    [String]$Name;
    [Double]$Size;
    [ItemType]$Type
}

# If I'm honest I'm not happy using a global variable here but it saves time when we can add the folder
# in to this list as we work. Otherwise we have to go through all the file structure again searhing for them later on.
$Global:Folders = New-Object System.Collections.ArrayList

function New-FileOrFolder {
    # Creates files and folders for the New-FolderStructure function
    param (
        [Switch]$Root,
        [Switch]$Directory,
        [Switch]$File,
        [String]$Name,
        [Int]$Size
    )

    if ($Root) {
        return New-Object -TypeName Item -Property @{
            Parent = $null;
            Contents = New-Object -Type System.Collections.ArrayList
            Name = "/"
            Size = 0
            Type = [ItemType]::Directory
        }
    }
    elseif ($File) {
        return New-Object -TypeName Item -Property @{
            Parent = $FolderStructure
            Contents = New-Object -Type System.Collections.ArrayList
            Name = $Name
            Size = $Size 
            Type = [ItemType]::File
        }
    }
    elseif ($Directory) {
        return New-Object -TypeName Item -Property @{
            Parent = $FolderStructure
            Contents = New-Object -Type System.Collections.ArrayList
            Name = $Name
            Size = 0
            Type = [ItemType]::Directory
        }
    }
}

function Get-Output {
    param (
        [int]$StartRow,
        [string[]]$Data
    )
    # This goes through the next rows and stops when it finds a row which begins with "$"
    # Rows without "$" can be considered the output from an "Ls"

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
        # Create the file and folders structure based on the data passed through

    $FolderStructure = $null
    for ($i = 0; $i -lt $Data.Count; $i++) {
        if ($Data[$i][0] -eq '$') {
            # On each row of text act differently depending on if it's a "cd", "ls", etc
            switch -Regex ($Data[$i]) {
                '\$ cd \/' { 
                    # "cd /"
                    $NewItem = New-FileOrFolder -Root
                    $FolderStructure = $NewItem
                    $Folders.Add($NewItem)

                    break;
                }

                '\$ ls' { 
                    # ls command so need to add dirs and files to FolderStructure
                    $TextToParse = Get-Output -StartRow ($i+1) -Data $Data
                    $i = ($TextToParse[1] - 1)

                    for ($y = $TextToParse[0]; $y -lt $TextToParse[1]; $y++) {
                        switch -Regex ($Data[$y]) {
                            'dir (\w.*)' { 
                                # Creating Directory
                                $NewItem = New-FileOrFolder -Directory -Name $Matches[1]
                                $folderStructure.Contents.Add($NewItem) | Out-Null
                                $Folders.Add($NewItem) | Out-Null
                                break;
                            }

                            '(\d.*) (\w.*)' {
                                # Creating File
                                $NewItem = New-FileOrFolder -File -Name $Matches[2] -Size $Matches[1]
                                $FolderStructure.Contents.Add($NewItem) | Out-Null
                                break;
                            }
                            Default {}
                        }
                    }
                    break;
                }
                
                '(\$ cd )(\w.*)' { 
                    # cd ___ so going forward in the linked list
                    $FolderStructure = ($FolderStructure.Contents | Where-Object { $_.Name -eq $Matches[2] } )
                    break;
                }
                
                '\$ cd ..' { 
                    # cd .. so going back in the linked list
                    $FolderStructure = $FolderStructure.Parent
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

function Get-FolderSize {
    param(
        [Object]$Folder
    )
    
    $Size = 0
    foreach ($Item in $Folder.Contents) {
        if ($Item.Type -eq "File") {
            $Size += $Item.Size
        }
        elseif ($Item.Type -eq "Directory") {
            $Size += (Get-FolderSize -Folder $Item).Size
        }
    }

    return [PSCustomObject]@{
        Name = $Folder.Name
        Size = $Size
    }
}

$Content = New-FolderStructure -Data (Get-Content .\input.txt)
$FolderSizes = foreach ($Folder in $Folders) { Get-FolderSize -Folder $Folder }
($FolderSizes | Where-Object { $_.Size -le 100000 } | Measure-Object -Sum Size).Sum