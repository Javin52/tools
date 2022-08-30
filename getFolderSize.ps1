param (
    [string]$path=$PSScriptRoot
)

function getLength {
    param (
        $object
    )
    
    $source = $path, $object.Name -join "\"
    $total = "{0}" -f ((Get-ChildItem $source -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum)
    if ( [string]::isNullorWhiteSpace($total) ) {
        $total = 0
    }
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
    
    if ( $length -eq 0) {
        $mag = 1
    } else {
        $mag = [Math]::Ceiling( [Math]::Log10($length) )
    }
    $fill = 15 - $mag
    $space = ""
    for ( $i = 0; $i -lt $fill; $i++ ) {
        $space = $space, " " -join ""
    }
    
    $name = $object.Name
    $output = $mode, "        ", $writeTime, $space, $length, " ", $name -join ""
    Write-Output $output
}

Write-Host "`n`n`t" ( "Directory:", $path, "`n`n" -join " " )
Write-Host "Mode                 LastWriteTime         Length Name"
Write-Host "----                 -------------         ------ ----"

foreach ( $object in Get-ChildItem -Path $path -directory) {
    $output = writeInfo $object $false
    Write-Host $output
}

foreach ( $object in Get-ChildItem -Path $path -file ) {
    $output = writeInfo $object $true
    Write-Host $output
}