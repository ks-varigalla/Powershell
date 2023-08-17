# Define an array of server names
$serverNames = "MADWINTEL01"
 
# Getting Server names
# $Server = Get-Content -Path "C:\Temp\Servers.txt"
 
# Loop through each server name and pull the scheduled tasks
foreach ($server in $serverNames) {
 
    Write-Host "Retrieving scheduled tasks from $server..."
    $scheduledTasks = Get-ScheduledTask -CimSession $server -ErrorAction SilentlyContinue
    if ($scheduledTasks) {
        Write-Host "Scheduled tasks found on $server"
        $scheduledTasks | Select-Object TaskName, TaskPath, State |Out-File "c:\temp\test2.csv" -Append
    } else {
        Write-Host "No scheduled tasks found on $server."
       
    }
}
$Output | Out-File "c:\temp\test.csv"
