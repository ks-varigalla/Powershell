#***************************************************************************************************************************************************************
#****************************** SETTING THE REGISTRY KEYS ******************************************************************************************************
#*************************************************************************************************************************************************************** 

## Clear Host Console 

Clear-Host 

## Define Variable for Server Count

$z = 0 

## Set Default Script Location 

Set-Location $PSScriptRoot 

## Provide List of Servers to Check for the Disconnected user session 

$Servers = Get-Content "C:\Temp\SMB-Servers1.txt" 

## Get Servers Count 

$count = $Servers.count 


## Setting the registry keys against each server in $Servers 

foreach($name in $Servers){


       $z+=1

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue        

       Invoke-Command -ComputerName $name -ScriptBlock {

       #Get-Item -path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanManWorkstation\Parameters 

       Set-ItemProperty -path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanManWorkstation\Parameters -Name RequireSecuritySignature -Value 1

       Write-Host "Successfull" -BackgroundColor Green

       }

}

