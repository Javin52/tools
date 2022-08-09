# Script to update multiple files from one folder to another at once
# while getting a list of PDFs that were updated so they can be compared 
# later if needed.

# Fill in source and destination folder if you want a default value
# to add folders on input, use config flag
param (
    [switch]$config = $false,
    [string]$source = "",
    [string]$dest = ""
)

if ($config) {
    $source = $( Read-Host "Input Source dir" )
    $dest = $( Read-Host "Input Dest dir" )
}

Write-Host "The source dir is set as " $source -ForegroundColor green
Write-Host "The destination dir is set as " $dest -ForegroundColor green

$path = $( "FilesUpdated.txt" )
$tempFile = New-TemporaryFile

if ( Test-Path -Path .\$path -PathType Leaf ) {
    rm FilesUpdated.txt
}

robocopy $source $dest /L /XL | Tee-Object -file $tempFile |
    foreach { if ( $_ -match "Newer" ) { $_.Split("`t")[-1] >> $path }}

gc $tempFile
rm $tempFile

Write-Host "Proceed to update all files from "$source" to "$dest"? 
y for Yes and n for No" -ForegroundColor red

$confirmMove = $( Read-Host )

if ($confirmMove -eq "y") {
    robocopy $source $dest /XL
}

Write-Host "Updating files has been completed."