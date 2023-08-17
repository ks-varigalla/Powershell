#***************************************************************************************
################## INSTALLING VMWARE TOOLS ON THE REMOTE NODES #########################
#***************************************************************************************

$servers = Get-Content "C:\Temp\testservers.txt"

$sourcefile = "\\FISMGMT003\VMware tools (12.1.0)"

$version = "12.1.0.20219665"

# Looping through each server
 
foreach ($computer in $servers) 
{
    Write-Host "Installing VMWare tools on $computer"

    $destinationFolder = "\\$computer\C$\Temp"
    
    # Cheking the destination path. If the Folder does not exist it will create one.

    if (!(Test-Path -path $destinationFolder))
    {

        New-Item $destinationFolder -Type Directory

    }

    # Copying the Source file to remote destination

    Copy-Item -Path $sourcefile -Destination $destinationFolder -Recurse

    # Installing the .exe file
    
    $out = Invoke-Command -ComputerName $computer -ScriptBlock { 

    Start-Process "C:\Temp\VMware tools (12.1.0)\setup64.exe" -ArgumentList "/s", "/v/qn" -PassThru -Wait 
    
    # restart the server

    #Restart-Computer 
    
    $installed_version = Get-WmiObject -class win32_product | Where-Object{$_.Name -like "VMware Tools"}
    
    if($installed_version.version.Equals($version)){
    
        Write-Host "Installation completed successfully"
    
        $Pstable= [PSCustomObject]@{
    
        ServerName = $env:COMPUTERNAME
    
        Version = $installed_version
    
        Installation_Status = "Success"
    
        }
    }
    
    else{
    
        Write-Host "Installation failed"
    
        $Pstable= [PSCustomObject]@{
    
        ServerName = $env:COMPUTERNAME
    
        Version = $installed_version
    
        Installation_Status = "Fail"
    
        }
    }

    try{

    Restart-Computer }

    catch{
    
    $Pstable } #| Export-Csv -Path "C:\Temp\VMtools_status.csv" -Append -NoTypeInformation  }   

    }

    $out | Export-Csv -Path "C:\Temp\VMtools_status.csv" -Append -NoTypeInformation
}

#  Get-WmiObject -class win32_product | Where-Object{$_.Name -like "VMware Tools"}



