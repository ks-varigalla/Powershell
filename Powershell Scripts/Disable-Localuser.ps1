#*********************************************************************************************************************************************************************
#********************************************************************* DISABLE LOCAL USERS ***************************************************************************
#********************************************************************************************************************************************************************* 

## Clear Host Console 

Clear-Host 

## Define Variable for Server Count

$z = 0 

## Set Default Script Location 

Set-Location $PSScriptRoot 

## Provide List of Servers here

$Servers = Get-Content "C:\Temp\Fujitsu-Scripts\Localusers-servers1.txt" 

## Get Servers Count 

$count = $Servers.count 


##  Get the list of users against each server in $Servers 

foreach($name in $Servers){


       $z+=1

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue        

       Invoke-Command -ComputerName $name -ScriptBlock {

       Get-LocalUser | where {($_.Name -like "Guest1") -or ($_.Name -like "Patrol") -or ($_.Name -like "BladeLogicRSCD") -or

       ($_.Name -like "fuj-admin") -or ($_.Name -like "fujitsu_admin") -or ($_.Name -like "fujitsuadmin") -or ($_.Name -like "fuj_admin")  -or 
       
       ($_.Name -like "fujadmin") -or ($_.Name -like "patrol_local") -or ($_.Name -like "FJbackup") -or ($_.Name -like "adm_fj") -or ($_.Name -like "fsk_fujiidaas") } } |

       select @{n="ServerName";e={$name}},Name, Enabled, Description | Export-Excel "C:\temp\Fujitsu-Scripts\Output-UserList.xlsx" -Append -BoldTopRow -AutoSize -AutoFilter

       Write-Host "Successful" -BackgroundColor Green

}

$z = 0

##  Disable users against each server in $Servers 
<#
foreach($name in $Servers){


       $z+=1

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue        

       #Invoke-Command -ComputerName $name -ScriptBlock {

       #Get-LocalUser | where {($_.Name -like "Guest1") -or ($_.Name -like "Pilot") -or ($_.Name -like "Administrator") } } | Disable-LocalUser

       Write-Host "Successfully disabled." -BackgroundColor Green

}
#>




