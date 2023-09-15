#************************************************************************************************************************
$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy remotesigned -Force $ErrorActionPreference
Clear-Host
Write-Host "*******************************************************************************"-foregroundcolor "Green"
Write-Host "File Name      : Windows_Daily_Servers_Health_Check_Reports"                                         -foregroundcolor "Green"                                                                                         
Write-Host "Purpose        : Windows_Daily_Servers_Health_Check_Reports to sent an email"                 -foregroundcolor "Green"                        
#Write-Host "Version              : 01.00"                                                                   -foregroundcolor "Green"
#Write-Host "Date          : 8/31/2022"                                                        -foregroundcolor "Green"
Write-Host "*******************************************************************************" -foregroundcolor "Green"
#**************************** Output Standard Color Code and Output Path Information ****
$OKColor = "Green"
$WarningColor = "Orange"
$CriticalColor = "Red"
$OfflineColor = "DarkRed"
$ToolName = "Windows_Daily_Servers_Health_Check_Reports"
$OutputPath = "C:\Temp\Health Check\$ToolName"

#************** Check and Create Historical Folder Structure **********
$HistoricalReportsDir = "$OutputPath\Historical_Reports"
If(-Not(Test-Path $HistoricalReportsDir))
{
    New-Item $HistoricalReportsDir -type directory | Out-null
}
#****************************************************************************************
#**************************** Config File Creation and Others Information ***************

Add-Type -AssemblyName System.Windows.Forms
$ConfigFile = "$OutputPath\ConfigFile.xml"
$LogDir = "$OutputPath"
If(-Not(Test-Path -path $LogDir))
{
    New-Item $LogDir -type directory | Out-null
}
If(Test-Path -path $ConfigFile)
{
    [xml]$ConfigFile = Get-Content "$OutputPath\ConfigFile.xml"
}
Else
{
       $ErrorConfigfile = "$Outputpath\Log\Error_Config_File_Missing.log"
       Write-Host "Error: No ConfigXML File exists on Script Path :$OutputPath"
       Add-Content $ErrorConfigfile -Value "Error: No ConfigXML File exists on Script Path :$OutputPath"
       $Value = Read-Host "Do you want to create default ConfigXML File ? (Y/N)"
       $Value = $Value.toupper()
       If ($Value -eq "Y")
       {
              $ConfigFile = "$OutputPath\ConfigFile.xml"
              Write-Host "Information: Default ConfigXML File is created on Script Path :$OutputPath"
              Add-Content $ErrorConfigfile -Value "Information: Default ConfigXML File is created on Script Path :$OutputPath"
              Write-Host "Information: Please change the ConfigXML File values as per Requirements"
              Add-Content $ErrorConfigfile -Value "Information: Please change the ConfigXML File values as per Requirements" 
              $ConfigValue = @"
<Settings>
       <WindowsSettings>
              <ProjectName>Primark</ProjectName>  
              <OutputFileName>ConfigMgr_Daily_Servers_Health_Check_Reports</OutputFileName>
              <strServers>localhost</strServers>
              #<strMPServers>MPServer1</strMPServers>
              <strServicesServers>localhost</strServicesServers>
    </WindowsSettings>

       <EmailSettings>
              <TriggerMail>Yes</TriggerMail>
              <SMTPServer>smtp.primark.ie</SMTPServer>
              <FromAddress>AutoScript@primark.ie</FromAddress>
              <ToAddress>OMC-PRI-HCL-WINTEL@hcl.com</ToAddress>
              <CCAddress>venkatesh-sr@hcl.com</CCAddress>
              <BCCAddress></BCCAddress>
       </EmailSettings>

       <HealthCheckCustomSettings>
              <CheckServersAvailabilityRpt>Yes</CheckServersAvailabilityRpt>
              <CheckServersDiskSpaceRpt>Yes</CheckServersDiskSpaceRpt>
              <CheckSiteServersServicesRpt>Yes</CheckSiteServersServicesRpt>
              <CheckBackupsRpt>Yes</CheckBackupsRpt>
              <GenerateCSVRpt>Yes</GenerateCSVRpt>        
       </HealthCheckCustomSettings>

       <DefaultSettings>
              <WarningDiskSpacePercentage>20</WarningDiskSpacePercentage>
              <CriticalDiskSpacePercentage>10</CriticalDiskSpacePercentage>
              <HistoryRpt>-30</HistoryRpt>
       </DefaultSettings>

       <HTMLSettings>
              <HeaderBGColor>#425563</HeaderBGColor>
              <FooterBGColor>#425563</FooterBGColor>
              <TableHeaderBGColor>#16264c</TableHeaderBGColor>
              <TableHeaderRowBGColor>#CCCCCC</TableHeaderRowBGColor>
              <TextColor>white</TextColor>
       </HTMLSettings>            
</Settings>
"@
              Add-Content $ConfigFile -Value "$ConfigValue"
       }      
    Exit 1
}  

#****************************************************************************************
$ProjectName = $ConfigFile.Settings.WindowsSettings.ProjectName
$OutputFileName = $ConfigFile.Settings.WindowsSettings.OutputFileName
$strServers = $ConfigFile.Settings.WindowsSettings.strServers
#$strMPServers = $ConfigFile.Settings.WindowsSettings.strMPServers
$strServicesServers = $ConfigFile.Settings.WindowsSettings.strServicesServers                              

#****************************************************************************************  
$TriggerMail = $ConfigFile.Settings.EmailSettings.TriggerMail
$SMTPServer = $ConfigFile.Settings.EmailSettings.SMTPServer
$FromAddress = $ConfigFile.Settings.EmailSettings.FromAddress
$ToAddress = $ConfigFile.Settings.EmailSettings.ToAddress
$CCAddress = $ConfigFile.Settings.EmailSettings.CCAddress
$BCCAddress = $ConfigFile.Settings.EmailSettings.BCCAddress
#****************************************************************************************  
$CheckServersAvailabilityRpt = $ConfigFile.Settings.HealthCheckCustomSettings.CheckServersAvailabilityRpt
$CheckServersDiskSpaceRpt = $ConfigFile.Settings.HealthCheckCustomSettings.CheckServersDiskSpaceRpt
$CheckServersMPRpt = $ConfigFile.Settings.HealthCheckCustomSettings.CheckServersMPRpt
$CheckSiteServersServicesRpt = $ConfigFile.Settings.HealthCheckCustomSettings.CheckSiteServersServicesRpt
$CheckBackupsRpt = $ConfigFile.Settings.HealthCheckCustomSettings.CheckBackupsRpt
$GenerateCSVRpt = $ConfigFile.Settings.HealthCheckCustomSettings.GenerateCSVRpt
#****************************************************************************************  
$WarningDiskSpacePercentage = $ConfigFile.Settings.DefaultSettings.WarningDiskSpacePercentage
$CriticalDiskSpacePercentage = $ConfigFile.Settings.DefaultSettings.CriticalDiskSpacePercentage
$HistoryRpt = $ConfigFile.Settings.DefaultSettings.HistoryRpt
#****************************************************************************************
$HeaderBGColor = $ConfigFile.Settings.HTMLSettings.HeaderBGColor
$FooterBGColor = $ConfigFile.Settings.HTMLSettings.FooterBGColor
$TableHeaderBGColor = $ConfigFile.Settings.HTMLSettings.TableHeaderBGColor
$TableHeaderRowBGColor = $ConfigFile.Settings.HTMLSettings.TableHeaderRowBGColor
$TextColor = $ConfigFile.Settings.HTMLSettings.TextColor
#**************************** Script Owner developer and email Information **************
$CompanyName = "Name"
#$ScriptDevelopedBy = "Ashwin Kumar J"
#$ScriptDeveloperEmailID = ashwinkumarj.a@hcl.com
#****************************************************************************************  
#**************************** Adjust Services Infromation **************************************************************
$ADServices = "W32Time","NTDS","ADWS","DFS","DFSR","DNS","Netlogon","DHCPServer"
#$SQLServices = "NTDS","W32Time","ADWS","SMS_REPORTING_POINT","ReportServer","MSSQLSERVER"
#****************************************************************************************
$New_OutputFileName = "$OutputFileName-$(get-date -format MM-dd-yyyy_HH-mm).html"
Rename-Item "$OutputPath\$OutputFileName.html" -newname "$OutputPath\$New_OutputFileName.html" -Force
Move-Item "$OutputPath\$New_OutputFileName.html" -destination "$HistoricalReportsDir\$New_OutputFileName" -Force
Remove-Item -path "$OutputPath\*.html" -Force
$New_OutputFileName = "$OutputFileName-$(get-date -format MM-dd-yyyy_HH-mm).CSV"
Rename-Item "$OutputPath\$OutputFileName.CSV" -newname "$OutputPath\$New_OutputFileName.CSV" -Force
Move-Item "$OutputPath\$New_OutputFileName.CSV" -destination "$HistoricalReportsDir\$New_OutputFileName" -Force
Remove-Item -path "$OutputPath\*.CSV" -Force
Start-sleep -milliseconds 500
$CurrentDate = Get-Date
$DateToDelete = $CurrentDate.AddDays($HistoryRpt)
Get-ChildItem $HistoricalReportsDir | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
#****************************************************************************************
$Report = "$OutputPath\Windows_Daily_Servers_Health_Check_Reports.html"
$CSVReport = "$OutputPath\Windows_Daily_Servers_Health_Check_Reports.CSV"
$Logfile = "$OutputPath\Windows_Daily_Servers_Health_Check_Reports.log"
#****************************************** Start ***********************************************
$StartTime = "05:00:00 PM"
$EndTime = "06:00:00 AM"
$a = Get-Date
$b = $a.AddDays(-1)
$b = $b.ToShortDateString()
$c = Get-Date
$c = $c.ToShortDateString()
$after = $b + " " + $StartTime
$before = $c + " " + $EndTime
$after = [datetime]$after
$before = [datetime]$before
#****************************************** End ***********************************************
#**************************** Script Path Validation End **************************************
$ReportTitle = "$ProjectName - Windows Daily Servers Health Check Reports - $(get-date -Format F)"
#************************************************************************************************************************ 

Function Get-DailyHTMLReport
{
       Add-Content $logfile -Value "****************** Start Time: $(Get-Date) *******************"
   Write-Host "****************** Start Time: $(Get-Date) *******************"
       #Create a new report file to be emailed out
       New-Item -ItemType File -Name $Report -Force | Out-Null
       New-Item -ItemType File -Name $CSVReport -Force | Out-Null
       #Write the HTML header information to file
       writeHtmlHeader "$Path\$Report"
    #Checking Servers Details Status
    If ($CheckServersAvailabilityRpt -eq "Yes")
    {
        Add-Content $logfile -Value "01. $(Get-Date) - Checking Servers Availability Details"
        Write-Host "01. $(Get-Date) - Checking Servers Availability  Details"
        $rptheader=@"
        <table width='100%'><tbody>
           <tr bgcolor=$TableHeaderBGColor> <td> <b> <Font color = 'white'> Servers Availability Details Status </Font> </b> </td> </tr>
        </table>
        <table width='100%' border = 0 > <tbody>
           <tr bgcolor=$TableHeaderRowBGColor>
        <td width='5%'>SNo</td>
        <td width='20%'>ServerName</td>
        <td width='10%'>IPAddress</td>
        <td width='20%'>Operating System</td>
           <td width='20%'>Domain</td>
           <td width='5%'>Status</td>
           </tr>
        </table>
"@
        Add-Content "$Report" $rptheader
              If ($GenerateCSVRpt -eq "Yes")
              {
                     Add-Content $CSVReport -Value "Servers Availability Details Status"
                     Add-Content $CSVReport -Value "SNo,ServerName,IPAddress,Operating System,Domain,Status"
              }
        $i = 0
        $strServers = $strServers.Split(",")
        foreach ($Server in $Strservers)
        #foreach ($Server in $strServers)
        {
            #$i++
            $Server = $Server.toupper()
            $IP = [System.Net.Dns]::GetHostEntry($Server).AddressList | %{$_.IPAddressToString}
            $IP | %{$HostName = [System.Net.Dns]::GetHostEntry($_).HostName}
                  $Ping = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Server'"
                  $IP = $Ping.IPV4Address
            If ($IP)
            {
                if (Test-Connection -ComputerName $Server -Quiet -Count 1)
                {
                    if (Test-Path \\$Server\admin`$ )#Test to make sure computer is up and that you are using the proper credentials
                    {
                        $wmi = Get-WmiObject -ComputerName $Server -Namespace root\cimv2 -class Win32_OperatingSystem
                        If ($wmi)
                        {
                        
                            $OS = (Get-WmiObject Win32_OperatingSystem -computername $Server).caption
                            $SystemInfo = Get-WmiObject -Class Win32_OperatingSystem -computername $Server | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
                            $ModelInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server | Select-Object Manufacturer, Model,DNSHostName,Domain
                            $TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB
                            $FreeRAM = $SystemInfo.FreePhysicalMemory/1MB
                            $UsedRAM = $TotalRAM - $FreeRAM
                            $RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
                            $TotalRAM = [Math]::Round($TotalRAM, 2)
                            $FreeRAM = [Math]::Round($FreeRAM, 2)
                            $UsedRAM = [Math]::Round($UsedRAM, 2)
                            $RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
                            $Made = $ModelInfo.manufacturer
                            $Model = $ModelInfo.model
                            $Domain = $ModelInfo.Domain
                            $SystemUptime = Get-HostUptime -ComputerName $Server
                            $Status = "Ok"
                            $color = "$OkColor"

                            $i++
                            $Rpt=@"
                            <table width='100%' border = 0 > <tbody>
                               <tr>
                            <td width='5%' align='center' >$i</td>
                            <td width='20%' align='left'>&nbsp$Server</td>
                            <td width='10%' align='center'>$IP</td>
                            <td width='20%' align='center'>$OS</td>
                               <td width='20%' align='center'>$Domain</td>
                               <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                               </tr>
                            </table>
"@
                            Add-Content "$Report" $Rpt 
                                                If ($GenerateCSVRpt -eq "Yes")
                                                {
                                                       Add-Content $CSVReport -Value "$i,$Server,$IP,$OS,$Domain,$Status"
                                                }
                           # }
                                                                           
                        }
                        else
                        {
                            #$i++
                            $Status = "WMI_Issue"
                            $t = 1
                            $color = "$WarningColor"
                            if ($t -eq 1)
                            {
                            $i++
                            $Rpt=@"
                            <table width='100%' border = 0 > <tbody>
                               <tr>
                            <td width='5%' align='center'>$i</td>
                            <td width='20%' align='left'>&nbsp$Server</td>
                            <td width='10%' align='center'>$IP</td>
                            <td width='20%' align='center'>NA</td>
                               <td width='20%' align='center'>NA</td>
                               <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                               </tr>
                            </table>
"@
                            Add-Content "$Report" $Rpt 
                                                If ($GenerateCSVRpt -eq "Yes")
                                                {
                                                       Add-Content $CSVReport -Value "$i,$Server,$IP,NA,NA,$Status"
                                                }
                            }                                              
                        }
                    }
                    else
                    {
                        #$i++
                        $Status = "ADM_Issue"
                        $t = 1
                        $color = "$WarningColor"
                        if ($t -eq 1)
                        {
                        $i++
                        $Rpt=@"
                        <table width='100%' border = 0 > <tbody>
                           <tr>
                        <td width='5%' align='center' >$i</td>
                                         <td width='20%' align='left'>&nbsp$Server</td>
                        <td width='10%' align='center'>$IP</td>
                        <td width='20%' align='center'>NA</td>
                           <td width='20%' align='center'>NA</td>
                           <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                           </tr>
                        </table>
"@
                        Add-Content "$Report" $Rpt  
                                         If ($GenerateCSVRpt -eq "Yes")
                                         {
                                                Add-Content $CSVReport -Value "$i,$Server,$IP,NA,NA,$Status"
                                         }
                        }
                    }
                }
                else
                {
                    #$i++
                    $Status = "Offline"
                    $t = 1
                    $color = "$CriticalColor"
                    if (($t -eq 1) -and ($server -ne "testserver.com"))
                    {
                    $i++
                    $Rpt=@"
                    <table width='100%' border = 0 > <tbody>
                       <tr>
                    <td width='5%' align='center' >$i</td>
                                  <td width='20%' align='left'>&nbsp$Server</td>
                    <td width='10%' align='center'>$IP</td>
                    <td width='20%' align='center'>NA</td>
                       <td width='20%' align='center'>NA</td>
                       <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                       </tr>
                    </table>
"@
                    Add-Content "$Report" $Rpt 
                                  If ($GenerateCSVRpt -eq "Yes")
                                  {
                                         Add-Content $CSVReport -Value "$i,$Server,$IP,NA,NA,$Status"
                                  }
                    }                                 
                }
            }
            else
            {
                #$i++
                $Status = "DNS_Issue"
                $t = 1
                $color = "$CriticalColor"
                if ($t -eq 1)
                {
                $i++
                $Rpt=@"
                <table width='100%' border = 0 > <tbody>
                   <tr>
                <td width='5%' align='center' >$i</td>
                           <td width='20%' align='left'>&nbsp$Server</td>
                <td width='10%' align='center'>$IP</td>
                <td width='20%' align='center'>NA</td>
                   <td width='20%' align='center'>NA</td>
                   <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                   </tr>
                </table>
"@
                Add-Content "$Report" $Rpt 
                           If ($GenerateCSVRpt -eq "Yes")
                           {
                                  Add-Content $CSVReport -Value "$i,$Server,$IP,NA,NA,$Status"
                           }
                }                        
            }
        }
    }
    Else
    {
        Add-Content $logfile -Value "01. $(Get-Date) - Skipping Servers Availability Details"
        Write-Host "01. $(Get-Date) - Skipping Servers Availability Details"
    }
    #Checking Servers Disk Space Details Status
    If ($CheckServersDiskSpaceRpt -eq "Yes")
    {
        Add-Content $logfile -Value "02. $(Get-Date) - Checking Servers Disk Space Details"
        Write-Host "02. $(Get-Date) - Checking Servers Disk Space Details"
        $rptheader=@"
        <table width='100%'><tbody>
              <tr bgcolor=$TableHeaderBGColor> <td> <b> <Font color = 'white'> Servers Disk Space Status </Font> </b> </td> </tr>
        </table>
        <table width='100%' border = 0 > <tbody>
           <tr bgcolor=$TableHeaderRowBGColor>
        <td width='5%'>SNo</td>
        <td width='20%'>ServerName</td> 
        <td width='5%'>Drive</td> 
        <td width='10%'>VolName</td>    
        <td width='10%'>Total Capacity(GB)</td>
           <td width='10%'>Used Capacity(GB)</td>
        <td width='10%'>Free Space(GB)</td>
           <td width='5%'>Free Space%</td>
        <td width='5%'>Status</td>
           </tr>
        </table>
"@
        Add-Content "$Report" $rptheader
              If ($GenerateCSVRpt -eq "Yes")
              {
                     Add-Content $CSVReport -Value "Servers Disk Space Details"
                     Add-Content $CSVReport -Value "SNo,ServerName,Drive,VolName,Total_Capacity(GB),Used_Capacity(GB),Free_Space(GB),Free_Space%,Status"
              }
        $i = 0
        foreach ($Server in $strservers)
        #foreach ($Server in $strServers)
        {
            $Server = $Server.toupper()
            $IP = [System.Net.Dns]::GetHostEntry($Server).AddressList | %{$_.IPAddressToString}
            $IP | %{$HostName = [System.Net.Dns]::GetHostEntry($_).HostName}
                  $Ping = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Server'"
                  $IP = $Ping.IPV4Address
            If ($IP)
            {
                if (Test-Connection -ComputerName $Server -Quiet -Count 1)
                {
                    if (Test-Path \\$Server\admin`$ )#Test to make sure computer is up and that you are using the proper credentials
                    {
                        $wmi = Get-WmiObject -ComputerName $Server -Namespace root\cimv2 -class Win32_OperatingSystem
                        If ($wmi)
                        {
                            $disks = Get-WmiObject -ComputerName $Server -Class Win32_LogicalDisk -Filter "DriveType = 3"
                            $Server = $Server.toupper()
                            foreach($disk in $disks)
                            {        
                                #$i++
                                      $deviceID = $disk.DeviceID
                                $volName = $disk.VolumeName
                                      [float]$size = $disk.Size
                                      [float]$freespace = $disk.FreeSpace;                                      
                                      $sizeGB = [Math]::Round($size / 1073741824, 2)
                                      $FreeSpaceGB = [Math]::Round($freespace / 1073741824, 2)
                                                       $FreeSpacePercentage = [Math]::Round(($FreeSpace / $size) * 100, 2)
                                $UsedSpaceGB = $sizeGB - $FreeSpaceGB
                                # Set background color to $WarningColor if just a Warning
                               If($FreeSpacePercentage -lt $WarningDiskSpacePercentage)  
                                                       #If($FreeSpaceGB -lt $WarningDiskSpacePercentage)                                                     
                                {                                    
                                    $t = 1
                                    $status = "Warning"
                                    $color = "$WarningColor"
                                    # Set background color to $WarningColor if space is Critical 
                                    If($FreeSpacePercentage -lt $CriticalDiskSpacePercentage)                                                           
                                    #If($FreeSpaceGB -lt $CriticalDiskSpacePercentage)
                                    {
                                        $t = 1
                                        $status = "Critical"
                                        $color = "$CriticalColor"
                                    }  
                                }  
                                else
                                {
                                    $status = "Ok"
                                    $color = "$OkColor"
                                }
                                #if ($t -eq 1)
                                if (($t -eq 1) -or ($status -eq "Ok"))
                                {
                                $i++
                                $Rpt=@"
                                <table width='100%' border = 0 > <tbody>
                                <tr align= 'center'>
                                <td width='5%' align='center' >$i</td> 
                                                       <td width='20%' align='left'>&nbsp$Server</td>
                                <td width='5%'>$deviceID</td>    
                                <td width='10%'>$volName</td> 
                                <td width='10%'>$sizeGB</td>
                                <td width='10%'>$UsedSpaceGB</td>
                                   <td width='10%'>$FreeSpaceGB</td>
                                <td width='5%'>$FreeSpacePercentage</td>
                                   <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                                   </tr>
                                </table>
"@
                                Add-Content "$Report" $Rpt
                                                       If ($GenerateCSVRpt -eq "Yes")
                                                       {
                                                              Add-Content $CSVReport -Value "$i,$Server,$deviceID,$volName,$sizeGB,$UsedSpaceGB,$FreeSpaceGB,$FreeSpacePercentage,$Status"
                                                       }
                                }
                            }
                        }
                        else
                        {
                            $i++
                            $Status = "WMI_Issue"
                            $color = "$WarningColor"
                            $Rpt=@"
                            <table width='100%' border = 0 > <tbody>
                            <tr align= 'center'>
                            <td width='5%' align='center' >$i</td>
                            <td width='20%' align='left'>&nbsp$Server</td>  
                            <td width='5%'>NA</td>    
                            <td width='10%'>NA</td> 
                            <td width='10%'>NA</td>
                           <td width='10%'>NA</td>
                               <td width='10%'>NA</td>
                            <td width='5%'>NA</td>
                               <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                               </tr>
                            </table>
"@
                            Add-Content "$Report" $Rpt 
                                                If ($GenerateCSVRpt -eq "Yes")
                                                {
                                                       Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,NA,NA,NA,$Status"
                                                }                                               
                        }
                    }
                    else
                    {
                        $i++
                        $Status = "ADM_Issue"
                        $color = "$WarningColor"
                        $Rpt=@"
                        <table width='100%' border = 0 > <tbody>
                        <tr align= 'center'>
                        <td width='5%' align='center' >$i</td>
                        <td width='20%' align='left'>&nbsp$Server</td> 
                        <td width='5%'>NA</td>    
                        <td width='10%'>NA</td> 
                        <td width='10%'>NA</td>
                        <td width='10%'>NA</td>
                           <td width='10%'>NA</td>
                        <td width='5%'>NA</td>
                           <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                           </tr>
                        </table>
"@
                        Add-Content "$Report" $Rpt 
                                         If ($GenerateCSVRpt -eq "Yes")
                                         {
                                                Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,NA,NA,NA,$Status"
                                         }                                        
                    }
                } 
                else
                {
                    
                    $t = 1
                    $Status = "Offline"
                    $color = "$CriticalColor"
                    if (($t -eq 1) -and ($server -ne "testserver.com"))
                    {
                    $i++
                    $Rpt=@"
                    <table width='100%' border = 0 > <tbody>
                    <tr align= 'center'>
                    <td width='5%' align='center' >$i</td>
                    <td width='20%' align='left'>&nbsp$Server</td>  
                    <td width='5%'>NA</td>    
                    <td width='10%'>NA</td> 
                    <td width='10%'>NA</td>
                    <td width='10%'>NA</td>
                       <td width='10%'>NA</td>
                    <td width='5%'>NA</td>
                       <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                       </tr>
                    </table>
"@
                    Add-Content "$Report" $Rpt  
                                  If ($GenerateCSVRpt -eq "Yes")
                                  {
                                         Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,NA,NA,NA,$Status"
                                  }
                    }
                }
            }
            else
            {
                $i++
                $Status = "DNS_Issue"
                $color = "$CriticalColor"
                $Rpt=@"
                <table width='100%' border = 0 > <tbody>
                <tr align= 'center'>
                <td width='5%' align='center' >$i</td>
                <td width='20%' align='left'>&nbsp$Server</td>  
                <td width='5%'>NA</td>    
                <td width='10%'>NA</td> 
                <td width='10%'>NA</td>
                <td width='10%'>NA</td>
                   <td width='10%'>NA</td>
                <td width='5%'>NA</td>
                   <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                   </tr>
                </table>
"@
                Add-Content "$Report" $Rpt  
                           If ($GenerateCSVRpt -eq "Yes")
                           {
                                  Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,NA,NA,NA,$Status"
                           }
            }
        }
    }
    Else
    {
        Add-Content $logfile -Value "02. $(Get-Date) - Skipping Servers Disk Space Details"
        Write-Host "02. $(Get-Date) - Skipping Servers Disk Space Details"
    } 

        #Checking Servers Services Details Status Report
    If ($CheckSiteServersServicesRpt -eq "Yes")
    {
        Add-Content $logfile -Value "03. $(Get-Date) - Checking Servers Services Details"
        Write-Host "03. $(Get-Date) - Checking Servers Services Details"
        $rptheader=@"
        <table width='100%'><tbody>
              <tr bgcolor=$TableHeaderBGColor> <td> <b> <Font color = 'white'> Servers Services Status </Font> </b> </td> </tr>
        </table>
        <table width='100%' border = 0 > <tbody>
           <tr bgcolor=$TableHeaderRowBGColor>
        <td width='5%'>SNo</td>
        <td width='20%'>ServerName</td>
        <td width='30%'>Display Name</td>
        <td width='15%'>Name</td>
           <td width='5%'>StartMode</td>
           <td width='5%'>Status</td>
           </tr>
        </table>
"@
        Add-Content "$Report" $rptheader
              If ($GenerateCSVRpt -eq "Yes")
              {
                     Add-Content $CSVReport -Value "Servers Services Details"
                     Add-Content $CSVReport -Value "SNo,ServerName,DisplayName,Name,StartMode,Status"
              }
        $i = 0
        $strServicesServers = $strServicesServers.Split(",")
        foreach ($Server in $strServicesServers)
        {
            $Server = $Server.toupper()
            $IP = [System.Net.Dns]::GetHostEntry($Server).AddressList | %{$_.IPAddressToString}
            $IP | %{$HostName = [System.Net.Dns]::GetHostEntry($_).HostName}
                  $Ping = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Server'"
                  $IP = $Ping.IPV4Address
            If ($IP)
            {
                if (Test-Connection -ComputerName $Server -Quiet -Count 1)
                {
                    if (Test-Path \\$Server\admin`$ )#Test to make sure computer is up and that you are using the proper credentials
                    {
                        $wmi = Get-WmiObject -ComputerName $Server -Namespace root\cimv2 -class Win32_OperatingSystem
                        If ($wmi)
                        {
                             Foreach ($Service in $ADServices) 
                               {
                                   $SiteService = Get-WmiObject -Class Win32_Service -ComputerName $Server | Where {$_.Name -eq $Service}                            
                                $DisplayName = $SiteService.DisplayName
                                $Name = $SiteService.Name
                                $Status = $SiteService.State
                                $StartMode = $SiteService.StartMode
                                If ($StartMode -eq "Disabled")
                                {
                                    $color = "$CriticalColor"
                                    $status = "Critical"           
                                }
                                else
                                {
                                    $color = "$OkColor"
                                    $status = "Ok"
                                }
                                If ($StartMode -eq "Manual")
                                {
                                    $color = "$WarningColor"
                                    $status = "Warning"           
                                }

                                If ($DisplayName)
                                {
                                    $i++
                                    $rpt=@"
                                    <table width='100%' border = 0> <tbody>
                                       <tr align='Left'>
                                    <td width='5%' align='center'>$i</td>
                                    <td width='20%' align='left'>&nbsp$Server</td>
                                    <td width='30%'>$DisplayName</td>
                                    <td width='15%'>$Name</td>
                                       <td width='5%'>$StartMode</td>
                                       <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                                       </tr>
                                    </table>
"@
                                    Add-Content "$Report" $rpt  
                                                              If ($GenerateCSVRpt -eq "Yes")
                                                              {
                                                                     Add-Content $CSVReport -Value "$i,$Server,$DisplayName,$Name,$StartMode,$Status"
                                                              }
                                }
                            }                      
                        }
                        else
                        {
                            $i++
                            $Status = "WMI_Issue"
                            $color = "$WarningColor"
                            $Rpt=@"
                            <table width='100%' border = 0 > <tbody>
                               <tr align='Left'>
                            <td width='5%' align='center' >$i</td>
                            <td width='20%'>$Server</td>
                            <td width='30%'>NA</td>
                            <td width='15%'>NA</td>
                               <td width='5%'>NA</td>
                               <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                              </tr>
                            </table>
"@
                            Add-Content "$Report" $Rpt   
                                                If ($GenerateCSVRpt -eq "Yes")
                                                {
                                                       Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,$Status"
                                                }                                               
                        }
                    }
                    else
                    {
                        $i++
                        $Status = "ADM_Issue"
                        $color = "$WarningColor"
                        $Rpt=@"
                        <table width='100%' border = 0 > <tbody>
                           <tr align='Left'>
                        <td width='5%' align='center' >$i</td>
                        <td width='20%' align='left'>&nbsp$Server</td>
                        <td width='30%'>NA</td>
                        <td width='15%'>NA</td>
                           <td width='5%'>NA</td>
                           <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                           </tr>
                        </table>
"@
                        Add-Content "$Report" $Rpt 
                                         If ($GenerateCSVRpt -eq "Yes")
                                         {
                                                Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,$Status"
                                         }                                        
                    }
                }
                else
                {
                    $i++
                    $Status = "Offline"
                    $color = "$CriticalColor"
                    $Rpt=@"
                    <table width='100%' border = 0 > <tbody>
                       <tr align='Left'>
                    <td width='5%' align='center' >$i</td>
                    <td width='20%' align='left'>&nbsp$Server</td>
                    <td width='30%'>NA</td>
                    <td width='15%'>NA</td>
                       <td width='5%'>NA</td>
                       <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                       </tr>
                    </table>
"@
                    Add-Content "$Report" $Rpt  
                                  If ($GenerateCSVRpt -eq "Yes")
                                  {
                                         Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,$Status"
                                  }      
                }
            }
            else
            {
                $i++
                $Status = "DNS_Issue"
                $color = "$CriticalColor"
                $Rpt=@"
                <table width='100%' border = 0 > <tbody>
                   <tr align= 'Left'>
                <td width='5%' align='center' >$i</td>
                <td width='20%' align='left'>&nbsp$Server</td>
                <td width='30%'>NA</td>
                <td width='15%'>NA</td>
                <td width='5%'>NA</td>
                   <td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
                   </tr>
                </table>
"@
                Add-Content "$Report" $Rpt
                           If ($GenerateCSVRpt -eq "Yes")
                           {
                                  Add-Content $CSVReport -Value "$i,$Server,NA,NA,NA,$Status"
                           }                          
            }
        }
    }
    Else
    {
        Add-Content $logfile -Value "03. $(Get-Date) - Skipping Servers Services Details"
        Write-Host "03. $(Get-Date) - Skipping Servers Services Details"
    } 

    # Create table at end of report showing legend of colors for the Critical and Warning
       $tableDescription = "
    <table width='30%'>
    <tr bgcolor='White'> 
       <td width='10%' align='center' bgcolor='$OkColor'> <Font color = 'white'> <b> Normal </b> </Font> </td>  
       <td width='10%' align='center' bgcolor='$WarningColor'> <Font color = 'white'> <b> Warning  </b> </Font> </td>  
       <td width='10%' align='center' bgcolor='$CriticalColor'> <Font color = 'white'> <b> Critical  </b> </Font> </td>  
    </tr>
    </table>
    "

    Add-Content $Report $tableDescription      
       $RptFooter1 = @"
    <table width='100%' bgcolor = '$FooterBGColor'><tbody>
       <tr> <td align='center'> <b> <Font color = 'white'> Tool Developed By : $ScriptDevelopedBy ( $ScriptDeveloperEmailID ) - $(get-date -Format F) </Font> </b> </td> </tr>
       <tr> <td align='center'> <b> <Font color = 'white'> $CompanyName Restricted - Copyright 2018 </Font> </b> </td> </tr>
    </table>
"@


    #Add-Content $Report $RptFooter1
       #Add-Content "$Report" "</div></div></body></html>"
    # Finish up Report
    #Checking SMPT Mail Sent Details
    If ($TriggerMail -eq "Yes")
    {
        Add-Content $logfile -Value "04. $(Get-Date) - Sending SMTP Mail Sent Details"
        Write-Host "04. $(Get-Date) - Sending SMTP Mail Sent Details"
        $Subject = "$ReportTitle"
        $body = get-content "$Report"   
        $message = new-object System.Net.Mail.MailMessage 
        $message.From = $Fromaddress 
        $message.To.Add($Toaddress)
        $message.Cc.Add($CCAdress)
        $message.Bcc.Add($BCCAddress)
        $message.IsBodyHtml = $true
        $message.Subject = $Subject 
        $attach = new-object Net.Mail.Attachment($Report) 
        $message.Attachments.Add($attach) 
              If ($GenerateCSVRpt -eq "Yes")
              {
                     $attach = new-object Net.Mail.Attachment($CSVReport) 
                     $message.Attachments.Add($attach) 
              }
        $message.body = $body 
        $smtp = new-object Net.Mail.SmtpClient($smtpserver) 
        $smtp.Send($message) 
    }
    Else
    {
        Add-Content $logfile -Value "03. $(Get-Date) - Skipping SMTP Mail Sent Details"
        Write-Host "03. $(Get-Date) - Skipping SMTP Mail Sent Details"
    }
    Add-Content $logfile -Value "****************** End Time: $(Get-Date) *******************"
    Write-Host "****************** End Time: $(Get-Date) *******************"
} 

   


Function writeHtmlHeader
{
    $date = (get-date -Format F)
    $header = @"
   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd>
    <html xmlns=http://www.w3.org/1999/xhtml>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>$Title</title>
    <style type="text/css">
    <!--
    body {
            font: 100%/1.4 Verdana, Arial, Helvetica, sans-serIf;
            background: #FFFFFF;
            margin: 0;
            padding: 0;
            color: #000;
         }
    .container {
            width: 100%;
            margin: 0 auto;
            }
    h1 {
            font-size: 18px;
        }
    h2 {
            color: #FFF;
            padding: 0px;
            margin: 0px;
            font-size: 14px;
            background-color: #006400;
        }
    h3 {
            color: #FFF;
            padding: 0px;
            margin: 0px;
            font-size: 14px;
            background-color: #191970;
        }
    h4 {
            color: #348017;
            padding: 0px;
            margin: 0px;
            font-size: 10px;
            font-style: italic;
        }
    .header {
            text-align: center;
        }
    .container table {
            width: 100%;
            font-family: Verdana, Geneva, sans-serIf;
            font-size: 12px;
            font-style: normal;
            font-weight: bold;
            font-variant: normal;
            text-align: center;
            border: 0px solid black;
            padding: 0px;
            margin: 0px;
        }
    td {
            font-weight: normal;
            border: 1px solid grey;
            width='25%'
        }
    th {
            font-weight: bold;
            border: 1px solid grey;
            text-align: center;
       }
    -->
    </style></head>
    <body>
    <div class="container">
    <div class="content">  
"@
    Add-Content "$Report" $header 
       $RptHeaderSME1 = @"
       <table width='100%'><tbody>
       <tr bgcolor = '$HeaderBGColor'> <td align='center'> <b> 
       <Font color = 'white'> $ReportTitle </Font>
       </b> </td> </tr>
       </table>
"@
    Add-Content $Report $RptHeaderSME1
} 

Get-dailyHTMLReport $args[0] 
