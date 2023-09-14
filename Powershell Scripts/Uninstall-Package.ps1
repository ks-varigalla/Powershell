## Provide List of Servers to Check for the Disconnected user session

$servers = Get-Content "C:\Temp\Servers.txt"

## Get Servers Count

$count = $Servers.count

## Adding the inactive servers to a hash table

$inactive_servers = @{}

$i = 1

$block = {
    
        $prog = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq "Microsoft Silverlight" }

        $prog.Uninstall()



        if($?){

            Write-host "Uninstalled Successfully"

        }

}


foreach($name in $servers){
 
       $z+=1 

       Write-Host "Processing server-$z :$name, out of $count servers" -BackgroundColor Blue

       if (Test-Connection -ComputerName $name -Quiet){

            Invoke-Command -ComputerName $name -ScriptBlock $block -ArgumentList $name

        }

        else{

            Write-Host "Server $name is unavailable at the moment"

            $inactive_servers.Add("$i","$name")

            $i+=1

        }  

}

# List of inactive servers

$inactive_servers | Out-File C:\Temp\inactive_servers.txt
