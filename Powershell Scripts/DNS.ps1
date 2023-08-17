## Clear Host Console

Clear-Host

## Define Variable for Server Count

$z = 0

$date = Get-Date -Format "dd-MM-yyyy"

##Set Default Script Location

Set-Location $PSScriptRoot

## Provide List of Servers to Check for the Disconnected user session

$Servers = Get-Content "C:\Temp\Servers.txt"

## Get Servers Count

$count = $Servers.count

$script = {

$dns = Get-DnsClientServerAddress -AddressFamily IPv4

#$dns[0].Address

#$dns[0].InterfaceAlias

$obj = New-Object -TypeName psobject -Property ([ordered]@{

    SERVERNAME = $env:COMPUTERNAME

    INTERFACE =  $dns[0].InterfaceAlias

    PreferredDNS = $dns[0].Address[0]

    AlternateDNS = $dns[0].Address[1] })

$obj

}

# Calling each server

foreach($name in $Servers){
 
       $z+=1 

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue

       $op = Invoke-Command -ComputerName $name -ScriptBlock $script

       $op | Select-Object SERVERNAME,INTERFACE,PreferredDNS,AlternateDNS | Export-Csv -Path C:\Temp\DNS2-$date.csv -Append -NoTypeInformation
       

}  
