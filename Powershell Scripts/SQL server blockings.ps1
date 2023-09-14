#********************************************************************************************************************************************************************************
#*********************************************************** IDENTIFYING BLOCKINGS ON SQL SERVER ********************************************************************************
#********************************************************************************************************************************************************************************

# Place the list of servers here..

$servers = Get-Content -Path "D:\DBReports\DB_Servers.txt"

$outarr = @()

# Query to be executed

$query = "

    USE master

    Go

    SELECT @@servername Instance_Name, Session_ID, Wait_Duration_ms, Wait_Type, Blocking_Session_ID

    FROM sys.dm_os_waiting_tasks
    
    WHERE blocking_session_id IS NOT NULL

    GO

    "


# Run the query against each server specified in DB-Servers.txt file

foreach($server in $servers){
 
    $output = Invoke-Sqlcmd -ServerInstance $server -Query $query

    $outarr+=$output

}

$outarr | Export-Excel "D:\DBReports\Blocked_Sessions.xlsx" -AutoSize -AutoFilter -BoldTopRow

# Sending an email notification

$from = ""

$to = ""

$subject = "SQL Server Blockings Report"

$attach = "D:\DBReports\Blocked_Sessions.xlsx"

Send-MailMessage -SmtpServer smtpserver -From $from -To $to -Subject $subject -Attachments $attach


#************************************************************************ END OF THE SCRIPT *****************************************************************************************

