# Script to test if files of the same name are different between two folders. 

# Fill in source and test folder if you want a default value
# to add folders on input, use config flag
param (
    [switch]$config = $false,
    [string]$source = "",
    [string]$test = ""
)

if ($config) {
    $source = $( Read-Host "Input Source dir" )
    $test = $( Read-Host "Input Dest dir" )
}

Write-Host "The source dir is set as " $source -ForegroundColor green
Write-Host "The test dir is set as " $test -ForegroundColor green

$failed = 0
$total = (Get-Content .\filesUpdated.txt).Length

function compareFiles {
    param (
        $original, 
        $target
    )
    $oHash = (Get-FileHash $original -Algorithm MD5).Hash
    $tHash = (Get-FileHash $target -Algorithm MD5).Hash
    $isSame = $( $oHash -eq $tHash )
    Write-Output $isSame
}

foreach ($file in Get-Content .\filesUpdated.txt) {
    if ( Test-Path -Path $test\$file -PathType Leaf ) {
        if (!( compareFiles $source\$file $test\$file ) ) {
            Write-Host "File "$file" is different between the source and test directory" -ForegroundColor red
            $failed += 1
        }
    }
}

Write-Host $failed -NoNewline -ForegroundColor Red
Write-Host " of " -NoNewline
Write-Host $total" files" -NoNewline -ForegroundColor green
Write-Host " are different between the source and test directories"
