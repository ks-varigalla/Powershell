# Get the Availability status
$servers = "MADWINTEL01","FISMGMT003", "IECWXWVPCRT003", "DITDC1-primark.ie"

#$servers = "IECWXWVPCRT001", "IECWXWVPCRT002", "IECWXWVPCRT003", "DITDC1-primark.ie"

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

$desc = "Root CA", "Issuing CA1", "Issuing CA2", "Old PKI Root CA server"

$ip = "10.150.22.59", "10.150.22.55", "10.150.22.56", "10.150.22.57"

$count = $servers.count

for($i = 0;$i -lt $count;$i++){

    if(Test-Connection -ComputerName $servers[$i] -Quiet){

        Write-Host "Ping is success"

        $pstable = [pscustomobject]@{

        "Description" = $desc[$i]

        "ServerName" = $servers[$i]

        "IP"         = $ip[$i]

        "Status"     = "Server is up and running"

        }

    }

    else{
        
        $pstable = [pscustomobject]@{

        "Description" = $desc[$i]

        "ServerName" = $servers[$i]

        "IP"         = $ip[$i]

        "Status"     = "Server not avaiable"

        }
    }

  $pstable | Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -WorksheetName "Availability Status" -Append -AutoSize -BoldTopRow #-Title "PKI Servers HealthCheck Report"

}

#$pstable | Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -Append -AutoSize

 