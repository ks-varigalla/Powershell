######################################## RESTART THE COMPUTER AND PING THE AVAILABILITY STATUS #############################################################

# Getting the list of Servers
$servers = Get-Content -Path "C:\Temp\reboot-servers.txt"

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

Function Restart-Ping() {

param( 
$computername =$env:computername 
) 

if(Test-Connection -ComputerName $computername -Quiet ){ 

    Write-Host "Ping Successfull and initiating the restart.." -BackgroundColor Green

    Restart-Computer -ComputerName MADWINTEL01 -Force -Wait -For PowerShell -Timeout 300 -Delay 2

    sleep -Seconds 10

    if(Test-Connection -ComputerName $computername -Quiet -Count 2 -Delay 2){
        
         Write-Host "Restart Successfull" -BackgroundColor Green

         $obj = [PSCustomObject]@{

         ServerName = $computername

         Rebooted = "YES"

         Status = "Reachable"

         }

         #"Successful" | Out-File ./testconn.txt
    }

    else{

        Write-Host "Unable to connect  to the host after the reboot"

        $obj = [PSCustomObject]@{

         ServerName = $computername

         Rebooted = "YES"

         Status = "Unreachable"

         }
    }
}

else{
    Write-Host "Host is Unreachable" -BackgroundColor Red

    $obj = [PSCustomObject]@{

    ServerName = $computername

    Rebooted = "NO"

    Status = "Unreachable"

    }
}

$obj

}


# Calling the function on the remote servers

foreach ($name in $servers){
    
     #Write-Host "Fetching the utilization report for the server '$name'... "

     $output1 = Invoke-Command -ComputerName $name -ScriptBlock ${function:Restart-Ping}

     $output1 | Select ServerName, Rebooted, Status| Export-Excel -Path "C:\temp\Reboot-Status-$date.xlsx" -BoldTopRow -AutoSize -Append # -WorksheetName "Before Restart"
   
     }

