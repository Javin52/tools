# Move and Test PDFs

The goal of this is to simplify updating files from the source folder to a target location. An example of this would be to update files for an application. 

**Note:** The algorithms used for comparing files are and MD5 Hash function that is targeted towards comparing PDFs. 

These are powershell scripts that may not run on windows based on the system Execution Policy.
run 
```
Get-ExecutionPolicy
```
to see the exection policy currently set up. If the policy is restricted, then you will need to create a bypass to run the script.
A single exception can be made to run a certain script by using the command 
```
powershell -ep Bypass ./updateFiles.ps1
```
to run the script. 

# Paramaters
## updateFiles.ps1
Has two paramaters source and dest that can be set within the files for a default value; however, you can also give the arguments when running the program.

The program will generate a file called FilesUpdated.txt that will outline the names 
of all files updated from the source to destination folder. It will also make sure all files that are going to be updated have been changed in some way (The first is from RoboCopy that looks for files that are older within the source file and the second is using the MD5 hash function). 

## compareFiles.ps1
Has two paramaters source and test that can be set within the files for a default value; however, if you want to provide them as arguments when calling the function, you will have to provide the -config flag, where the program will then ask for input of the two directories.

The program will look for a file called FilesUpdated.txt to get the list of file names
to be compared between the test and source folder.

# Example Uses of these tools

If you have an Application that allows the user to download a file of some sort, specifically a PDF, and you want to update the files, you can use the updateFiles.ps1 script to move all new files into the folder location of the application while getting a list of all files that have been changed.

Then after you can run your application follow your specific workflow to download all or some files that were updated into a temporary folder. At this point, you can run the compareFiles.ps1 script to determine if all the files in your application are the new files you wanted to update. 

The files are compared using an MD5 hash. 

The updateFiles script is just a template and can be further added onto. For example, at the end of the script you can add 

```Powershell 
$folderName = $parentParts[-1]

Write-Host "Proceed to rename files in an different folder called $folderName-renamed?
y for Yes and n for No"
$confirmMove = $( Read-Host )

if ( $confirmMove -eq "n" ) {
    exit
}

# ensure the renamed folder is not there from previous attempts
if ( Test-Path -Path .\$folderName-Renamed  ) {
    Write-Host "proceed to delete " $folderName "-Renamed?
    y for Yes and n for No"
    $conifrmMove = $ ( Read-Host )
    if ( $confirmMove -eq "n" ) {
        exit
    }
    Remove-Item $folderName-Renamed -recurse
}

# creates the renamed folder in the parent directory of source
cd $parent
Copy-Item $source $folderName-Renamed -recurse
cd $folderName-Renamed

# Removes a specific type of file
Remove-Item ele-*-ann-en.pdf

# Renames all files, change prefix, then suffix for both english and french
ls | Rename-Item -NewName {$_.name -replace "prefix-", ""}
ls | Rename-Item -NewName {$_.name -replace "-suffix-en", "_E"}
ls | Rename-Item -NewName {$_.name -replace "-suffix-fr","_F"}    

# run the update function again
updateBatch . $dest
```

This will create another folder to:
- remove a specific type of file, 
- change the prefix of all files,
- change the suffix of all english and french files.

This would have been needed if the application files could be of either format (This was the case at my job where the name of the file could either be **This** or **That** but the content is the same).