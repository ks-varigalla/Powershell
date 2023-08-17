#*******************************************************************************************************************************************************************
#**************************************************** UPGRADING THE POWERSHELL FROM VERSION 4 TO 5 ON THE REMOTE SERVERS *********************************************
#*******************************************************************************************************************************************************************

$servers = Get-Content "C:\Temp\PSupgrade\PSv4-servers.txt"

$date = Get-Date -Format dd-MM-yyyy

$source_2008  = "\\FISMGMT003\c`$\temp\WMF5.1\Win7AndW2K8R2-KB3191566-x64"

$source_2012  = "\\FISMGMT003\c`$\temp\WMF5.1\Win8.1AndW2K12R2-KB3191564-x64.msu"

#$dest_dir = "C:\Windows\SoftwareDistribution\Download"

foreach ($computer in $servers) 
{

Write-Host "Upgrading PowerShell on $computer.."

$dest = "\\$computer\C$\Windows\SoftwareDistribution\Download"

$session = New-PSSession -ComputerName $computer -EnableNetworkAccess

#Copy-Item -Path $source -Destination $dest -ToSession $session -Recurse

$op = Invoke-Command -SessionName $session -ScriptBlock { 

    $current_version = $PSVersionTable.PSVersion.Major

    $os = Get-WmiObject -Class win32_operatingsystem | select Name

    if($os -like "*2008*"){

    if($current_version -lt 5){

    Copy-Item -Path $source_2008 -Destination $dest -ToSession $session -Recurse

    $hash1 = [pscustomobject]@{

            ServerName = $env:COMPUTERNAME

            PSVersion = $current_version

            Restart_Required = "YES"

        }

    #Copy-Item -Path $sourcefile -Destination 'C:\Temp' -Force

    Start-Process  "C:\Windows\SoftwareDistribution\Download\Win7AndW2K8R2-KB3191566-x64\Install-WMF5.1.ps1" -Wait -ArgumentList "/quiet", "/norestart" -PassThru  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    Write-Host "Installation completed Successfully." -BackgroundColor Green 

    }

    else{

        $hash1 = [pscustomobject]@{

            ServerName = $env:COMPUTERNAME

            PSVersion = $current_version

            Restart_Required = "NO"

        }
  

        Write-Host "Version:5 already exists" -BackgroundColor Cyan

   }

   $hash1

}


    if($os -like "*2012*"){

    if($current_version -lt 5){

    Copy-Item -Path $source_2012 -Destination $dest -ToSession $session -Recurse

    $hash1 = [pscustomobject]@{

            ServerName = $env:COMPUTERNAME

            PSVersion = $current_version

            Restart_Required = "YES"

        }

    #Copy-Item -Path $sourcefile -Destination 'C:\Temp' -Force

    Start-Process  "C:\Windows\SoftwareDistribution\Download\Win8.1AndW2K12R2-KB3191564-x64.msu" -Wait -ArgumentList "/quiet", "/norestart" -PassThru  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    Write-Host "Installation completed Successfully." -BackgroundColor Green 

    }

    else{

        $hash1 = [pscustomobject]@{

            ServerName = $env:COMPUTERNAME

            PSVersion = $current_version

            Restart_Required = "NO"

        }
  

        Write-Host "Version:5 already exists" -BackgroundColor Cyan

   }

   $hash1

}

}

$op |  select ServerName, PSVersion, Restart_Required | Export-Excel -Path "C:\Temp\PSupgrade\VersionInfo_$date.xlsx" -Append -AutoSize

}
