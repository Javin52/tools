Write-Host "`n`n`t" ( "Directory:", $PSScriptRoot, "`n`n" -join " " )

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

function doubleDig {
    param (
        $hour
    )
    $hour12 = $hour % 12
    Write-Output (($hour12 -le 12 -and $hour12 -ge 10 ) -or $hour12 -eq 0 )
}

function writeInfo {
    param  (
        $object,
        [switch]$isFile
    )
    $mode =  $object.Mode
    $hour = $object.LastWriteTime.Hour
    if ( ( doubleDig $hour ) ) {
        $writeTime = $object.LastWriteTime.ToString("yyyy-MM-dd  h:mm tt")
    } else {
        $writeTime = $object.LastWriteTime.ToString("yyyy-MM-dd   h:mm tt")
    }

    if ( $isFile ) {
        $length = $object.Length
    } else {
        $length = getLength $object
    }

    $mag = [Math]::Ceiling( [Math]::Log10($length) )
    $fill = 15 - $mag
    $space = ""
    for ( $i = 0; $i -lt $fill; $i++ ) {
        $space = $space, " " -join ""
    }
    
    $name = $object.Name
    $output = $mode, "        ", $writeTime, $space, $length, " ", $name -join ""
    Write-Output $output
}

Write-Host "Mode                 LastWriteTime         Length Name"
Write-Host "----                 -------------         ------ ----"

foreach ( $object in Get-ChildItem -directory) {
    $output = writeInfo $object $false
    Write-Host $output
}

foreach ( $object in Get-ChildItem -file ) {
    $output = writeInfo $object $true
    Write-Host $output
}