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

##$arr | Export-Excel -Path "C:\Temp\PKI Health Check Reports\PKI Health Check Status-$date.xlsx" -WorksheetName "Availability Status" -AutoSize -BoldTopRow

$arr | Export-Csv -Path "C:\Temp\PKI Health Check Reports\PKI Health Check Status-$date.csv" -Append -NoTypeInformation -UseCulture

 
#Stop-Transcript

# Import the required modules 

Import-Module PSPKI

Import-Module PKITools

#$CertAuth =  "IECWXWVPCRT002.primark.local", "IECWXWVPCRT003.primark.local", "DITDC1.primark.local" 

# Consolidated Output array

$outarr = @()

# CA1

$op =  Get-EnterprisePKIHealthStatus -CertificateAuthority "IECWXWVPCRT002.primark.local" 

$var = $op.Childs

# Root CA

$caname = $var[1].Name

$url = $var[1].URLs

$cname = $url.Name

$RootCDP = $url.ExpirationDate


# Create hash for Root CA

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $cname

"Expiration Date" = $RootCDP

}

$outarr+=$PStable

$caname = $var[0].Name

$URLs = $var[0].URLs

# AIA for CA1

$CA1AIA = $URLs[0].Name

$CA1AIADate = $URLs[0].ExpirationDate


# Create hash for CA1

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CA1AIA

"Expiration Date" = $CA1AIADate

}

$outarr+=$PStable

# CDP for CA1

$CA1CDP = $URLs[1].Name

$CA1CDPDate = $URLs[1].ExpirationDate

# Create hash for CA1

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CA1CDP

"Expiration Date" = $CA1CDPDate

}

$outarr+=$PStable
 

# CA2

$op =  Get-EnterprisePKIHealthStatus -CertificateAuthority "IECWXWVPCRT003.primark.local" 

$var = $op.Childs

$caname = $var[0].Name

$URLs = $var[0].URLs

# AIA for CA2

$CA2AIA = $URLs[0].Name

$CA2AIADate = $URLs[0].ExpirationDate

# Create hash for CA2

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CA2AIA

"Expiration Date" = $CA2AIADate

}

$outarr+=$PStable

# CDP for CA2

$CA2CDP = $URLs[1].Name

$CA2CDPDate = $URLs[1].ExpirationDate

# Create hash for CA2

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CA2CDP

"Expiration Date" = $CA2CDPDate

}

$outarr+=$PStable
 

# DIDTC

$op =  Get-EnterprisePKIHealthStatus -CertificateAuthority "DITDC1.primark.local" 

$var = $op.Childs

$caname = $var[0].Name

$URLs = $var[0].URLs

# Delta CRL #2

$CRLname = $URLs[4].Name

$CRLeDate = $URLs[4].ExpirationDate

# Create hash for DIDTC

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CRLname

"Expiration Date" = $CRLeDate

}

$outarr+=$PStable

# CDP for DIDTC

$CDPname = $URLs[5].Name

$DICDPDate = $URLs[5].ExpirationDate

# Create hash for DIDTC

$PStable = [pscustomobject] @{

"Name" = $caname

"URL Name" = $CDPname

"Expiration Date" = $DICDPDate

}

$outarr+=$PStable
 
#$outarr | Export-Excel -Path "C:\Temp\PKI Health Check Reports\PKI Health Check Status-$date.xlsx" -WorksheetName "Expiry Dates" -BoldTopRow -AutoSize

$outarr | Export-Csv -Path "C:\Temp\PKI Health Check Reports\PKI Health Check Status-$date.csv" -Append -NoTypeInformation -UseCulture

Stop-Transcript

#***************************************************************** END OF THE SCRIPT **************************************************************************************


