﻿#*****************************************************************************************************************************************************
#****************************** AUTOMATICALLY REMOVING DISCONNECTED USER SESSIONS AFTER A SPECIFIED IDLE TIME ****************************************
#*****************************************************************************************************************************************************

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

Function DisconnectedUsers($Computer)
{
$final = @()

quser /server:$Computer| ?{ $_ -notmatch '^ SESSIONNAME' } | %{

$item = "" | Select @{Name = 'ServerName'; Expression = {$env:COMPUTERNAME}},"Username", "Id", "State", "IdleTime", "LogonTime"

$item.UserName = $_.Substring(1,20).Trim()

$item.Id = $_.Substring(39,5).Trim()

$item.State = $_.Substring(45,8).Trim()

$item.IdleTime = $_.Substring(56,9).Trim()

$item.LogonTime = $_.Substring(66).Trim()

$item.IdleTime = '{0} days, {1} hours, {2} minutes' -f ([int[]]([regex]'^(?:(\d+)\+)?(\d+):(\d+)').Match($item.IdleTime).Groups[1..3].Value | ForEach-Object { $_ })
  
# Check for the disconnected users

    if ($item.State -eq "Disc"){

        $d, $h, $m = [int[]]([regex]'(\d+) days, (\d+) hours, (\d+) minutes').Match($item.IdleTime).Groups[1..3].Value

         if ($h -ge 1){

            # been idle for more than 3 hours, so logoff the user here

            #$item.UserName, $item.IdleTime, $item.ServerName

            $obj = New-Object -TypeName psobject -Property ([ordered]@{

            USERNAME = $item.UserName

            IDLETIME = $item.IdleTime

            SERVERNAME = $item.ServerName }) 

            $final+=$obj

            Write-Host "Logging off $($item.UserName) from computer $($item.ServerName).."

            logoff $item.Id /SERVER:$($item.ServerName)

        }

    }

  }  
  $final     
}

<#
# Calling the function locally

$Computer="localhost"
$op = DisconnectedUsers($Computer)
$op | Export-Csv -Path .\outpu.csv -NoTypeInformation #>

# Calling the function on remote servers

foreach($name in $Servers){
 
       $z+=1 

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue

       $op = Invoke-Command -ComputerName $name -ScriptBlock ${function:DisconnectedUsers} -ArgumentList $name

       $op | Select-Object USERNAME,IDLETIME,SERVERNAME | Export-Csv -Path C:\Temp\DisconnectedUsersList-$date.csv -Append -NoTypeInformation
       

}  

# Sending email

#Send-MailMessage -SmtpServer smtp.primark.ie -From  -To  -Cc  -Subject "DisconnectedUsers List" -Attachments "C:\Temp\DisconnectedUsersList.csv"

