#*************************************************************************************************************************************************************** 
#******************************************** Getting CPU and Memory Utilisation Of the Running Processes *****************************************************
#***************************************************************************************************************************************************************             

# Getting the list of Servers

$Server = Get-Content -Path "C:\Temp\Servers.txt"

$name = "localhost"

Function Get-Details
{ 
    
    
    $Processor = (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
    
    $ComputerMemory = Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop
    
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize) 
    
    $RoundMemory = [math]::Round($Memory, 2) 
    
    $Pstable= [PSCustomObject]@{
    
    ServerName = $env:COMPUTERNAME

    "Total CPU(%)" = $Processor

    "Total Memory(%)" = $RoundMemory

    } 

    #$Pstable
    

    $RAM = Get-WMIObject Win32_PhysicalMemory | Measure -Property capacity -Sum | %{$_.sum/1Mb}
    
    $cores = (Get-WmiObject Win32_Processor).NumberOfLogicalProcessors

    $count = $cores.count
    
    $tmp = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | 
    
    Select-Object -property @{n="ServerName";e={$env:COMPUTERNAME}}, @{n="ProcessName";e={$_.Name}}, @{Name = "CPU(%)"; Expression = {[math]::Round(($_.PercentProcessorTime/$count),2)}}, @{Name = "PID"; Expression = {$_.IDProcess}}, @{"Name" = "Memory(MB)"; Expression = {[int]($_.WorkingSetPrivate/1mb)}}, @{"Name" = "Memory(%)"; Expression = {([math]::Round(($_.WorkingSetPrivate/1Mb)/$RAM*100,2))}} |
    
    Where-Object {$_.ProcessName -notmatch "^(idle|_total|system)$"} |
    
    Sort-Object -Property "Memory(%)" -Descending|
    
    Select-Object -First 5;

    $tmp | Add-Member noteproperty "Total CPU(%)" $Processor

    $tmp | Add-Member noteproperty "Total Memory(%)" $RoundMemory
    
    cls

    $tmp | Format-Table -Autosize -Property ServerName,ProcessName, PID, "CPU(%)", "Memory(%)", "Memory(MB)","Total CPU(%)","Total Memory(%)";
    
    Start-Sleep 3 #>
}

<#
# Calling the Function locally

$Output = Get-Details
$Output | select Servername, "CPU(%)","Memory(%)" | Export-Csv "C:\Temp\CPU&MEMORY UtilizationReport.csv" -Append -NoTypeInformation

#>


# Calling the function on the remote servers

 foreach ($name in $Server){

       Write-Host "The CPU and Memory utilisation of the server '$name' are: "

       $Output = Invoke-Command -ComputerName $name -ScriptBlock ${function:Get-Details}

       #$Output | select Servername, "CPU(%)","Memory(%)" | Export-Csv "C:\Temp\CPU&Memory Utilization Report.csv" -Append -NoTypeInformation 

       $Output | select ServerName,ProcessName, PID, "CPU(%)", "Memory(%)", "Memory(MB)" | Export-Csv "C:\Temp\CPU&MEMORY UtilizationReport3.csv" -Append -NoTypeInformation

 } 



 #*************************************************************** END OF THE SCRIPT ****************************************************************************
