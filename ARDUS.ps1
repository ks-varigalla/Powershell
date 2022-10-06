## Clear Host Console
Clear-Host

## Define Variable for Server Count
$z = 0

##Set Default Script Location
Set-Location $PSScriptRoot

## Provide List of Servers to Check for the Disconnected user session
$Servers = Get-Content "C:\Temp\Servers.txt"

## Get Servers Count
$count = $Servers.count

#$Computer="localhost"

# Function for removing disconnected user sessions
Function DisconnectedUsers($Computer)
{
$serverName = "localhost"

$sessions = quser /server:$Computer| ?{ $_ -notmatch '^ SESSIONNAME' } | %{

$item = "" | Select @{Name = 'ServerName'; Expression = {$env:COMPUTERNAME}},"Username", "Id", "State", "IdleTime", "LogonTime"

$item.UserName = $_.Substring(1,20).Trim()

$item.Id = $_.Substring(39,5).Trim()

$item.State = $_.Substring(45,8).Trim()

$item.IdleTime = $_.Substring(56,9).Trim()

$item.LogonTime = $_.Substring(66).Trim()

$item.IdleTime = '{0} days, {1} hours, {2} minutes' -f ([int[]]([regex]'^(?:(\d+)\+)?(\d+):(\d+)').Match($item.IdleTime).Groups[1..3].Value | ForEach-Object { $_ })
 $item       
} 

foreach ($session in $sessions){

    # Check for the disconnected users

    if ($session.State -eq "Active"){

        $session.UserName, $session.ServerName, $session.IdleTime

        $d, $h, $m = [int[]]([regex]'(\d+) days, (\d+) hours, (\d+) minutes').Match($session.IdleTime).Groups[1..3].Value

         if ($h -ge 20){

            # been idle for more than 3 hours, so logoff the user here

            Write-Host "Logging off $($session.UserName) from computer $($session.ServerName).."

            logoff $session.Id /SERVER:$($session.ServerName)

            $session

        }

    }
}

}

# Calling the finction locally
$Computer="localhost"
$op = DisconnectedUsers($Computer)
$op | Out-File -Append "C:\Temp\new\$computer.csv"| ConvertTo-Csv | Format-Table

# Calling the function on each remote server in '$Servers'
 foreach($name in $Servers){
        
       $z+=1 

       Write-Host "Processing server-$z : $name, out of $count servers" -BackgroundColor Blue

       $output = Invoke-Command -ComputerName $name -ScriptBlock ${function:DisconnectedUsers} -ArgumentList $name

       $output

 }  


        #logoff /server $serverName $session.Id    }} #>
