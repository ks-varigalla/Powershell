<# 
Powershell Script to copy data to Azure VM from local server 
Requirements: 
- Contributor Access to Storage Account.
- a Local/domain user account with permission on source directory. permission must be read, write, list and delete. this user is used to run the task inside task scheduler. 
- install az module on source server. 
- open port 443 outbound to access azure. 
AM#>

#Logging Start
Start-Transcript

# Read the encrypted credentials from the file
$SecurePassword = Get-Content 'C:\temp\secure_password.txt' | ConvertTo-SecureString

# Create a PSCredential object using the encrypted password
$UserName = 'capadm1'

$Credential = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

#Local File Path
$Localpath = "C:\Invoice_archive"

#Destination server path
$remotepath = "\\fis-prd-laserf1\C$\Temp\"

#$date = Get-Date -Format dd-MM-yyyyT-HH:MM

#$path = $remotepath +  $date

New-Item -Path $path -ItemType Directory

Copy-Item -Path $Localpath -Destination $remotepath -Recurse -Force -Credential $Credential

Write-Output "Files copied successfully on $date"

#Logging Stop
Stop-Transcript
