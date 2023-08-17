<# 
Powershell Script to copy data to Azure VM from local server 
Requirements: 
- User Access to Destination VM.
- a Local/domain user account with permission on source directory. permission must be read, write, list and delete. this user is used to run the task inside task scheduler.  
- open port 443 outbound to access azure. 
AM#>

#Logging Start
Start-Transcript

#Local File Path
$Localpath = "C:\Invoice-archive"

#Remote Server Path
$remotepath = "\\10.134.9.4\Laserfiche\test\Opentext\Invoice_archive\"

#Configure Parallel Jobs count
[int]$ThreadCount = 75

#Get Files Locally: 
$filesfetch = Get-ChildItem -Recurse -Path $Localpath | ? { $_.Extension -eq ".pdf" }

Write-Output "Uploading $TotalFiles Files"

$Starttime  = Get-Date

if ($filesfetch.Count -ge 1) {
 
            $filesfetch | Foreach-Object { # -ThrottleLimit $ThreadCount  -Parallel {
            
            $FileToUpload = $_.FullName
            
            $ContainerName = ($FileToUpload.Split('\') | Select -Skip 2 | Select -first 1).tolower()
            
            #update due to target containing hardcoded underscores in front of year folders. 
            
            Write-Output "Printing the file to upload.. $FileToUpload"
            
            $list = $filetoupload.Split('\') | select -Skip  2 
            
            $BlobName = $list[0] + "\" + $list[1] + "\" + $list[2] + "\" + $list[3]
            
            $dir = $list[0] + "\" + $list[1] + "\" + $list[2]
            
            $directory = $remotepath + $dir
            
            $dest = $remotepath + $BlobName

                try{
                    
                    # Copy the files
                    Copy-Item -Path $FileToUpload -Destination $dest
            
                    sleep -Seconds 5
            
                    if (Test-Path $dest) {
            
                        Remove-Item -Path $FileToUpload -Force
            
                     }
                
                }
                
                 catch {
                
                    $er = $_.Exception.Message 
                
                    if ($er -like "*Could not find a part of the path*")
                
                    {
                
                            Write-Output "Directory $($ContainerName) does not exist, creating a new one.." 
                            
                            $level1 = $remotepath + $list[0]
                
                            if(!(Test-Path $level1)){
                
                                New-Item -Path $remotepath -Name $list[0] -ItemType Directory 
                            
                            }
                
                            $level2 = $level1 + '\' + $list[1]
                
                            if(!(Test-Path $level2)){
                
                                New-Item -Path $level2 -ItemType Directory 
                            
                            }
                
                            $level3 = $level2 + '\' + $list[2]
                
                            if(!(Test-Path $level3)){
                
                                New-Item -Path $level3 -ItemType Directory 
                            
                            }

                            # Copy the files
                            Copy-Item -Path $FileToUpload -Destination $dest
                
                            if (Test-Path $dest) {
                
                                Remove-Item -Path $FileToUpload -Force
                            
                            } 
        
                        }
                
                        else {
                
                            <# Action when all if and elseif conditions are false #>
                
                            Write-Warning "An Error occurred while uploading File: $FileToUpload, following is the exception captured. this upload will be retried in next run
                        
                            $er
                            "
                            $script:TriggerRemovalOnError = $true

                        }
                } 

       }

}

else {

    Write-Output "There are no new files to be uploaded to the server." 
}

$Etime  = Get-date

Write-Output "Start Time is $($Starttime)" 
         
Write-Output "Endtime is $($Etime)"

#Logging Stop
Stop-Transcript