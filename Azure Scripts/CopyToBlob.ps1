<# 
Powershell Script to copy data to Azure Storage from local server 
Requirements: 
- Contributor Access to Storage Account.
- a Local/domain user account with permission on source directory. permission must be read, write, list and delete. this user is used to run the task inside task scheduler. 
- install az module on source server. 
- open port 443 outbound to access azure. 
AM#>

#Logging Start
Start-Transcript

#Local File Path
#$Localpath = "C:\Invoice_archive", "D:\hyper"
$Localpath = "C:\Windows\Temp\Invoice_archive"
#Configure Parallel Jobs count
[int]$ThreadCount = 75


#Get Files Locally: 
$filesfetch = Get-ChildItem -Recurse -Path $Localpath | ? { $_.Extension -eq ".pdf" }
$TotalFiles = $filesfetch.Count
Write-Output "Uploading $TotalFiles Files"

$Starttime  = get-date

if ($filesfetch.Count -ge 1) {
 #   foreach ($item in $filesfetch) {
   #     Upload-Blob -FileToUpload $item.FullName -StorageContext $Context -Localpath $Localpath
#   -ThrottleLimit $ThreadCount
        $filesfetch | Foreach-Object -ThrottleLimit $ThreadCount  -Parallel {
            $FileToUpload = $_.FullName
            $ContainerName = ($FileToUpload.Split('\') | Select -Skip 2 | Select -first 1).tolower()
           # $OrgContName = $FileToUpload.Split('\') | Select -Skip 2 | Select -first 1

                #$BlobName = $FileToUpload.Replace($Localpath, '').trimstart('\') #.Replace($OrgContName,'').trimstart('\')
                #update due to target containing hardcoded underscores in front of year folders. 
                Write-Output "printing file toupload $FileToUpload"
#                $list = $FileToUpload.Replace($Localpath, '').trimstart('\').Split('\')
                $list = $filetoupload.Split('\') | select -Skip  2 
                $BlobName = $list[0] + "\" + "__"  + $list[1] + "\" + $list[2] + "\" + $list[3]
                try {

                    $UploadStatus = Set-AzStorageBlobContent -Container $ContainerName -Blob $BlobName -File $FileToUpload -Force -Context $using:Context -ErrorAction Stop  
                    sleep -Seconds 5
                    if ($UploadStatus) {
                        Remove-Item -Path $FileToUpload -Force
                            }
                }
                catch {
                    $er = $_.Exception.Message 
                    if ($er -like "*does not exist*")
                        {
                            Write-Output "Container $($ContainerName) does not exist, creating"
                            New-AzStorageContainer -Name $ContainerName -Context $using:Context -ErrorAction Inquire
                            $UploadStatus = Set-AzStorageBlobContent -Container $ContainerName -Blob $BlobName -File $FileToUpload -Force -Context $using:Context -ErrorAction Stop  
                            if ($UploadStatus) {
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

  #  }

}
else {
    Write-Output "There are no new files to be uploaded to blob"
}
$Etime  = get-date
Write-Output "Start Time is $($Starttime)"          
Write-Output "Endtime is $($Etime)"

#Logging Stop
Stop-Transcript

