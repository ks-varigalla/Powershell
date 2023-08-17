# Getting the System event logs 

Clear-Host

$server = "localhost"

$reboot_time = "3/14/2023 11:04:49 PM"       ## As mentioned in ticket discription

$events = Get-EventLog -ComputerName $server -LogName System |  Where-Object {$_.source -eq "user32" -and $_.TimeGenerated -eq $reboot_time}

$name = $events.UserName

if($events.UserName -like "HCLTech\*"){

    $events.Message 

    Write-Host "Restart initiated by the user $name "
}

else{

    $events.Message

    Write-Host "Restart initiated by the System "
}
