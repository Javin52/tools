# Move and Test PDFs

The goal of this is to simplify updating files from the source folder to a target location. 

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
Has two paramaters source and dest that can be set within the files for a default value; however, if you want to provide them as arguments when calling the function, you will have to provide the -config flag, where the program will then ask for input of the two directories.

The program will generate a file called FilesUpdated.txt that will outline the names 
of all files updated from the source to destination folder.

## compareFiles.ps1
Has two paramaters source and test that can be set within the files for a default value; however, if you want to provide them as arguments when calling the function, you will have to provide the -config flag, where the program will then ask for input of the two directories.

The program will look for a file called FilesUpdated.txt to get the list of file names
to be compared between the test and source folder.

# Example Uses of these tools

If you have an Application that allows the user to download a file of some sort, like a PDF, and you want to update the files. You can use the updateFiles.ps1 script to move all new files into the folder location of the application while getting a list of all files that have been changed.

Then after you can run your application follow your specific workflow to download all or some files that were updated into a temporary folder. At this point, you can run the compareFiles.ps1 script to determine if all the files in your application are the new files you wanted to update. 

The files are compared using an MD5 hash. 