$cpu = Get-WmiObject -ComputerName $server -Class Win32_Processor | select Name

$count = $cpu.Count

$cname=  $cpu[0].Name

$RAM = Get-WmiObject -ComputerName $server -Class Win32_Computersystem | select @{n="RAM(GB)";e={[math]::Ceiling(($_.TotalPhysicalMemory)/1GB)}}

$OS = Get-WmiObject -ComputerName $server -Class Win32_operatingSystem | select Caption

$Hash = [pscustomobject]@{

    "ServerName" = $server

    "CPU Version" = $cname

    "No.of Cores" = $count

    "RAM" = $RAM.'RAM(GB)'

}
 