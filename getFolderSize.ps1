Get-ChildItem
Write-Output "------------------------------------------------------------------"

function getVal{
    param (
        $object, 
        $propName
    )
    $list = $object | select -expand LastWriteTime | Select-Object -Property $propName
    Write-Output $list.$propName
}

function getDirLastWriteTime {
    param (
        $object
    )
    $source = $PSScriptRoot, $object.Name -join "\"
    Write-Host $source
    $latest = Get-ChildItem $source -recurse  | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Output $latest.LastWriteTime
}

function getLength {
    param (
        $object
    )
    
    $source = $PSScriptRoot, $object.Name -join "\"
    # Write-Host $source
    $total = "{0}" -f ((Get-ChildItem $source -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum)
    Write-Output $total
}

Write-Host "Mode                 LastWriteTime         Length Name"
Write-Host "----                 -------------         ------ ----"

foreach ( $object in Get-ChildItem -directory) {
    # Write-Output $object " is a folder/directory"
    $mode =  $object.Mode
    $hour = $object.LastWriteTime.Hour
    if ( $hour -eq 12 -or $hour -eq 0 ) {
        $writeTime = $object.LastWriteTime.ToString("yyyy-MM-dd  h:mm tt")
    } else {
        $writeTime = $object.LastWriteTime.ToString("yyyy-MM-dd   h:mm tt")
    }

    $length = getLength $object
    $mag = [Math]::Ceiling( [Math]::Log10($length) )
    $fill = 15 - $mag
    $space = ""
    for ( $i = 0; $i -lt $fill; $i++ ) {
        $space = $space, " " -join ""
    }
    
    $name = $object.Name
    $output = $mode, "        ", $writeTime, $space, $length, " ", $name -join ""
    Write-Host $output
}

foreach ( $object in Get-ChildItem -file ) {
    Write-Output $object
}