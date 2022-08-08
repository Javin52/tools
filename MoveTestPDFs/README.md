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