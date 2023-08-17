﻿#***************************************************************************************
################## INSTALLING VMWARE TOOLS ON THE REMOTE NODES #########################
#***************************************************************************************

$servers = Get-Content "C:\Temp\testservers.txt"

$sourcefile = "\\FISMGMT003\VMware tools (12.1.0)"

$version = "12.1.0.20219665"

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

    #Copy-Item -Path $sourcefile -Destination $destinationFolder -Recurse

    # Installing the .exe file
    
    Invoke-Command -ComputerName $computer -ScriptBlock { 

    Start-Process "C:\Temp\VMware tools (12.1.0)\setup64.exe" -Wait -ArgumentList "/quiet", "/norestart" -PassThru  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    Write-Host "Installation completed Successfully. " -BackgroundColor Green
    
    # restart the server

    #Restart-Computer  -ComputerName $computer -Wait -For PowerShell -Timeout 120 -Delay 2 

   #  Get-CimInstance -ClassName win32_operatingsystem | select lastbootuptime

    }
}