# getFolderSize.ps1

## Getting current directory

Previously in scripts I made a reference using the "." character and changing to the directory needed in the script. This made the code a little confusing to read as you needed to keep track of the current directory you were in. 

In addition, when providing output, it was not very useful as you would just see something like "current directory is .".

However, with powershell 3.0 and above, there is an automatic variable set called 
```Powershell
$PSScriptRoot
```

Which will return the current directory the script is running in. With this, you can also use the join function to traverse the current directory. 

## Last Write Time

I learned that properties are stored a little differently for directories and files for some reason. For example, let us say we have two objects 
```Powershell
# get the first (sub) directory in the current directory
$dir = Get-ChildItem -directory | Select-Object -First 1
# get the first file in the current directory
$file = Get-ChildItem -file | Select-Object -First 1
```
If we want to obtain the property of an object, we usually use 
```Powershell
$object.PropertyName
```
So to get the LastWriteTime property we use:
```Powershell 
# for a directory 
$dir.LastWriteTime
# for a file
$file.LastWriteTime
```
However, they will give different outputs. For a directory, it gives the value such as 
```
2022-08-26 6:13:04 PM
```
However, for a file, it will give a mapping between different keys and values to detailed information. For eaxample, it could look like:

```
Date        : 2022-08-26 12:00:00 AM
Day         : 26
DayOfWeek   : Friday
DayOfYear   : 238
Hour        : 18
Kind        : Local
Millisecond : 913
Minute      : 16
Month       : 8
Second      : 40
Ticks       : 637971346009130151
TimeOfDay   : 18:16:40.9130151
Year        : 2022
DateTime    : August 26, 2022 6:16:40 PM
```

This caused an issue when I wanted to determine the LastWriteTime of a directory, since I did not test the first command and thought the value should be the LastWriteTime of the most recent file editted within the file. 
This meant, I needed to obtain and join all the required information from the mapping using a verbose script like:
```Powershell
function getLastWriteTime {
    param (
        $object
    )

    # determine the source file
    $source = $PSScriptRoot, $object.Name -join "\"
    Write-Output $source
    
    # get the property list for the LastWriteTime of the file
    $propList = [datetime](Get-ItemProperty -Path $source -Name LastWriteTime).lastwritetime

    $year = $propList.Year
    $month = $propList.Month
    $day = $propList.Day
    $hour = $propList.Hour
    $minute = $propList.Minute

    # formatting output
    $half = "AM"
    if ( $hour -gt 12 ) {
        $hour = $hour - 12
        $half = "PM"
    }

    if ( $month -lt 10 ) {
        $month = "0", $month -join ""
    }

    if ( $day -lt 10 ) {
        $day = "0", $day -join ""
    }

    $date = ${year}, ${month}, ${day} -join "-"
    $time = ${hour}, ${minute} -join ":"
    $out =  $date, "   ", $time, " ", $half -join ""
    Write-Output $out
}
```

and compare with every other file in the directory, using a recursive method to check nested folders.

After searching a little more, since this felt too verbose, I realized this method was not needed and we can simply use a filter and sort:
```powershell
Get-ChildItem $source -recurse  | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```
which will return the LastWriteTime of the most recent file within the folder (also checks recursively). 

However, while testing, I realized that the LastWriteTime when using ```dir``` and the command above was different. Looking into it a little more, it turns out they are distinct. The LastWriteTime of a file is updated when a change to the file is made; however, a directory does not care about the changes to files, only addition, removals and renames (essentially what changes in the directory itself). Therefore, you can use the command 
```powershell
$dir.LastWriteTime
```
To get the required property. 

## Formatting
```powershell
Get-FormatData -PowerShellVersion $PSVersionTable.PSVersion -TypeName System.IO.DirectoryInfo |
   Export-FormatData -Path ./folderView.Format.ps1xml
Update-FormatData -AppendPath ./folderView.Format.ps1xml
```

This is a more complex way of formatting output by creating your own template/view when using ```Format-Table``` command
More information can be found:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.2&viewFallbackFrom=powershell-6
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_format.ps1xml?view=powershell-7.2#sample-xml-for-a-format-table-custom-view
