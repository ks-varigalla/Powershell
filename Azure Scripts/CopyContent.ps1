<# 
Powershell Script to copy data to Azure VM from local server 
Requirements: 
- Contributor Access to Azure VM.
- a Local/domain user account with permission on source directory. permission must be read, write, list and delete. this user is used to run the task inside task scheduler. 
- install az module on source server. 
- open port 443 outbound to access azure. 
AM#>

#Logging Start
Start-Transcript

# Read the encrypted credentials from the file
$SecurePassword = Get-Content 'C:\temp\securepassword.txt' | ConvertTo-SecureString

# Create a PSCredential object using the encrypted password
$UserName = 'ext_vkrishna'

$Credential = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

#Local File Path
$Localpath = "C:\Windows\Temp\Invoice_archive"

#Destination server path
#$remotepath = "C:\Temp\"

$remotepath = "\\10.134.9.4\Laserfiche\test\Opentext"
#$remotepath = "Laserfiche\test\Opentext"

#$date = Get-Date -Format dd-MM-yyyyT-HH:MM

#$path = $remotepath +  $date

#New-Item -Path $path -ItemType Directory

$session = New-PSSession fis-prd-laserf1 -Credential $Credential

#Copy-Item -Path $Localpath -Destination $remotepath -Recurse -Force -ToSession $session #-Credential $Credential -

Copy-Item -Path $Localpath -Destination $remotepath -Recurse -Force #-ToSession $session

Remove-PSSession -Session $session

#Write-Output "Files copied successfully on $date"

#Logging Stop
Stop-Transcript
