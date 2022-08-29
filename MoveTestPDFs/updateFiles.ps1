param (
    [string]$source = "",
    [string]$dest = "",
    [string]$parent = ""
)

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

function testFilesDiffer {
    param (
        $differentFiles,
        $totalUpdates
    )

    $failed = 0
    foreach ($file in Get-Content $differentFiles) {
        if ( ( Test-Path -Path $updateDest\$file -PathType Leaf ) -and ( Test-Path -Path $updateSource\$file -PathType Leaf ) ) {
            if (!( compareFiles $updateSource\$file $updateDest\$file ) ) {
                $file >> $totalUpdates
            } else {
                Write-Host "File "$file" is the same between the source and test directory"
                $failed += 1
            }
        } else {
            # this case should not occur
            Write-Host "Error, "$file " does not exist in one of the directories"
            $failed += 1
        }
    }
    Write-Out $failed
}

function updateBatch {
    param (
        $updateSource,
        $updateDest
    )
    Write-Host "The source dir is set as " $updateSource -ForegroundColor green
    Write-Host "The destination dir is set as " $updateDest -ForegroundColor green

    $tempFile = New-TemporaryFile
    $differentFiles = New-TemporaryFile

    robocopy $updateSource $updateDest /L /XL | Tee-Object -file $tempFile |
    foreach { if ( $_ -match "Older" ) { $_.Split("`t")[-1] >> $differentFiles }}

    gc $tempFile
    Remove-Item $tempFile

    Write-Host "Starting comparisons of new files"

    $total = (Get-Content $differentFiles).Length
    if ( $total -eq 0 ) {
        Write-Host "There are no files that are different to be updated, will be skipping this section"
        return
    }

    $failed = testFilesDiffer $differentFiles $parent\$path
    
    Remove-Item $differentFiles
    if ( !( $failed -eq 0 ) ) {
        Write-Host $failed " of " $total " files are the same, different files are outlined in "$path -ForegroundColor red
        exit
    } else {
        Write-Host "There were no files that are the same"

        Write-Host "Proceed to update all files from "$updateSource" to "$updateDest"? 
        y for Yes and n for No" -ForegroundColor red

        $confirmMove = $( Read-Host )
        if ($confirmMove -eq "n") {
            exit
        }
        robocopy $updateSource $updateDest /XL
    }
}

if ( $source -eq "" -or $dest -eq "") {
    throw "Expected a source and destination file"
}

$path = $( "FilesUpdated.txt" )

$parentParts = $source.Split("\")
if ( $parent -eq "") {
    for ( $i = 0 ; $i -lt $parentParts.count - 1 ; $i++) {
        if ( ! $i -eq 0){
            $temp = $parent, "\", $parentParts[$i]
            $parent = -join $temp        
        } else {
            $parent = $parentParts[$i]
        }
    }
    Write-Host "parent directory is " $parent
}

if ( Test-Path -Path $parent\$path -PathType Leaf ) {
    rm FilesUpdated.txt
}

updateBatch $source $dest

Write-Host "Updating files has been completed."