﻿#************************************************************************************************************************************************
#********************************************************* SPLUNK BACKUP ************************************************************************
#************************************************************************************************************************************************

$computer = "FISMGMT003"

$date = Get-Date

$week = (Get-WmiObject win32_localtime).weekinmonth

$format = $date.GetDateTimeFormats() | select -First 7 | select -Last 1

$ad = $format.Substring(3)

$Folder1 = "\\$computer\C$\Temp\$ad\"

$Folder2 = "\\$computer\C$\Temp\$ad\week$week\" 

$Folder3 = "\\$computer\C$\Temp\$ad\week$week\Splunk\"
   
# Cheking the destination path. If the Folder does not exist it will create one.

if (!(Test-Path -path $Folder1))
{

     New-Item $Folder1 -Type Directory

}

if (!(Test-Path -path $Folder2))
{

     New-Item $Folder2 -Type Directory

}

if (!(Test-Path -path $Folder3))
{

     New-Item $Folder3 -Type Directory

}

# Copy the files to destination folder

Write-Host " Copying the files to $Folder3" 

Start-Process pscp.exe -ArgumentList ("-scp -r -pw Welcome123 ext_vkrishna@10.125.97.210:/home/ext_vkrishna/local3 $Folder3\$computer") -PassThru





#********************************************************* END OF THE SCRIPT ********************************************************************