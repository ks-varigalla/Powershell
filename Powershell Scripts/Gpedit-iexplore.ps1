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

$Servers = Get-Content "C:\Temp\Servers1.txt" 

## Get Servers Count 

$count = $Servers.count 


## Setting the registry keys against each server in $Servers 

foreach($name in $Servers){


       $z+=1

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue        

       Invoke-Command -ComputerName $name -ScriptBlock {

       REGEDIT /E C:\Regbkp.REG 
       
       REG ADD "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" /v iexplore.exe /t REG_DWORD /d 1 /f 
       
       REG ADD "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX" /v iexplore.exe /t REG_DWORD /d 1 /f 
       
       }

}