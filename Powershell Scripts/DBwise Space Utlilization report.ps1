#***************************************************************************************************************************************************************
#*************************************************************** DATABASE SPACE UTILIZATION REPORT ******************************************************************************
#***************************************************************************************************************************************************************

# Place the list of servers here..

#Import-Module sqlserver

$servers = Get-Content -Path "D:\DBReports\DB_Servers.txt"

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

$outarr = @()

$totarr = @()

# Query to be executed

$query = "

    SELECT d.NAME DB_Name,

    ROUND(SUM(CAST(mf.size AS bigint)) * 8 / 1024, 0) Size_MBs,
    
    (SUM(CAST(mf.size AS bigint)) * 8 / 1024) / 1024 AS Size_GBs,

    @@servername Instance_Name
    
    FROM sys.master_files mf
    
    INNER JOIN sys.databases d ON d.database_id = mf.database_id
    
    GROUP BY d.NAME
    
    ORDER BY d.NAME
    
    "


# Run the query against each server specified in DB-Servers.txt file

foreach($server in $servers){

    $output = Invoke-Sqlcmd -ServerInstance $server -Query $query 

    $count = $output.Count

    #Get the total used space

    $mbtotal = 0

    $gbtotal = 0

    foreach($item in $output){

        $mb = $item.'Size_MBs'

        $mbtotal+=$mb

        $gb = $item."Size_GBs"

        $gbtotal+=$gb

    }

    $obj = "" | Select @{Name="ServerName";Expression={$server}}, @{Name="No.of Databases";e={$count}}, @{Name="Total DB Size(MB)";e={$mbtotal}}, @{Name="Total DB Size(GB)";e={$gbtotal}}

    $totarr+=$obj

    $outarr+=$output

}

#$outarr | Export-Csv "D:\DBReports\DB_Size_Report.csv" -NoTypeInformation 
$outarr | Export-Excel "D:\DBReports\DB_Size_Report.xlsx" -WorksheetName "DB size" -AutoSize -AutoFilter -BoldTopRow

$totarr | Export-Excel "D:\DBReports\DB_Size_Report.xlsx" -WorksheetName "Total DB size" -AutoSize -AutoFilter -BoldTopRow

# Sending an email notification

$from = ""

$to = ""

$subject = "SQL Server Database Size Report"

$attach = "D:\DBReports\DB_Size_Report.xlsx"

Send-MailMessage -SmtpServer smtp -From $from -To $to -Subject $subject -Attachments $attach


#********************************************************* END OF THE SCRIPT *****************************************************************************************
