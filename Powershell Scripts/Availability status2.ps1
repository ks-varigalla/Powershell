# Get the Availability status

Start-Transcript

$servers = "MADWINTEL01","FISMGMT003", "IECWXWVPCRT003", "DITDC1-primark.ie"

#$servers = "IECWXWVPCRT001", "IECWXWVPCRT002", "IECWXWVPCRT003", "DITDC1-primark.ie"

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

$desc = "Root CA", "Issuing CA1", "Issuing CA2", "Old PKI Root CA server"

$ip = "10.150.22.59", "10.150.22.55", "10.150.22.56", "10.150.22.57"

$count = $servers.count

$arr =@()

for($i = 0;$i -lt $count;$i++){

    if(Test-Connection -ComputerName $servers[$i] -Quiet){

        Write-Host "Ping is success"

        $service = Get-Service -ComputerName $servers[$i] -Name EventLog  ## Service to check

        $pstable = [pscustomobject]@{

        "Description" = $desc[$i]

        "ServerName" = $servers[$i]

        "IP"         = $ip[$i]

        "Status"     = "Server is up and running"

        "ADCS service status" = $service.Status

        }

    }

    else{

        Write-Host "Ping failed"
        
        $pstable = [pscustomobject]@{

        "Description" = $desc[$i]

        "ServerName" = $servers[$i]

        "IP"         = $ip[$i]

        "Status"     = "Server not avaiable"

        "ADCS service status" = $service.Status

        }
    }

    $arr+=$pstable
  

}

#$pstable | Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -Append -AutoSize

#$arr | Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -WorksheetName "Availability Status"  -Title "PKI Servers HealthCheck Report"-AutoSize -TitleBold # -BoldTopRow

#$arr | Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -WorksheetName "Availability Status"  -Title "PKI Servers CDL check"-AutoSize -TitleBold -Append # -BoldTopRow

 #Export-Excel -Path C:\temp\HealthCheckReport-$date.xlsx -WorksheetName "Availability Status" -Title "PKI Servers HealthCheck Report" -TitleBold

$arr | Export-Excel -Path "C:\temp\Health Check Report-$date.xlsx" -WorksheetName "Availability Status" -AutoSize -BoldTopRow

$arr | Export-Csv -Path "C:\temp\Health Check Report-$date.csv" -Append -NoTypeInformation -UseCulture

 

Stop-Transcript

