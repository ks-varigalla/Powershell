#***************************************************************************************
################## INSTALLING  TOOLS ON THE REMOTE NODES #########################
#***************************************************************************************

$servers = Get-Content "C:\Temp\newfold\iisservers.txt"

$sourcefile = "\\FISMGMT005\D$\wintel\softwares\IISCrypto.exe"

# Looping through each server
 
foreach ($computer in $servers) 
{
    Write-Host "Installing VMWare tools on $computer.."

    $destinationFolder = "\\$computer\C$\Temp"
    
    # Cheking the destination path. If the Folder does not exist it will create one.

    if (!(Test-Path -path $destinationFolder))
    {

        New-Item $destinationFolder -Type Directory

    }

    # Copying the Source file to remote destination

    Copy-Item -Path $sourcefile -Destination $destinationFolder -Recurse

    # Installing the .exe file
    
    Invoke-Command -ComputerName $computer -ScriptBlock { 

    #Start-Process $sourcefile -Wait -ArgumentList "/quiet", "/norestart" -PassThru  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    Start-Process 'C:\temp\IIScrypto.exe' -Wait -PassThru -ErrorAction SilentlyContinue

    Write-Host "Installation completed Successfully. " -BackgroundColor Green
    
    # restart the server

    #Restart-Computer  -ComputerName $computer -Wait -For PowerShell -Timeout 120 -Delay 2 

    }
}