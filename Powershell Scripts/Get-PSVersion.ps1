## Define Variable for Server Count

$z = 0 

## Set Default Script Location 

Set-Location $PSScriptRoot 

## Provide List of Servers to Check for the Disconnected user session 

$Servers = Get-Content "C:\Temp\Localusers-servers.txt" 

## Get Servers Count 

$count = $Servers.count 


##  Get the list of users against each server in $Servers 

foreach($name in $Servers){


       $z+=1

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue        

       Invoke-Command -ComputerName $name -ScriptBlock {

            $PSVersionTable.PSVersion

        } |

        Select PSComputerName, Major, Minor | Export-Excel "C:\temp\VersionList.xlsx" -Append -BoldTopRow -AutoSize

       Write-Host "Successful" -BackgroundColor Green

}