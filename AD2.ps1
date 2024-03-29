﻿# Creating a new excel sheet

$Excel = New-Object -ComObject excel.application

$Excel.visible = $true

$Workbook = $Excel.Workbooks.Add()

$Workbook.Worksheets.Add()

$report = $Workbook.Worksheets.Item(1)

# Creating the Headers

$report.Cells.Item(1,1) = "Name"

$report.Cells.Item(1,2) = "SamAccountName"

$report.Cells.Item(1,3) = "Title"

$report.Cells.Item(1,4) = "Country"

$report.Cells.Item(1,5) = "Department"

$report.Cells.Item(1,6) = "Office"

$report.Cells.Item(1,7) = "EmailAddress"

$report.Cells.Item(1,8) = "Description"

$report.Cells.Item(1,9) = "Enabled"

$report.Cells.Item(1,10) = "WhenCreated"

$report.Cells.Item(1,11) = "AccountExpirationDate"

$report.Cells.Item(1,12) = "LastLogonDate"

$report.Cells.Item(1,13) = "Manager in ADM"

$report.Cells.Item(1,14) = "Manager in Normal AD"


# Formatting the Headers

for($i = 1; $i -le 14;$i++){

    $report.Cells.Item(1,$i).Font.Bold = $True

}


# Getting AD users data

$op = Get-ADUser -filter * -Properties name,manager,samaccountname,title,country,department,office,mail,description,enabled,whencreated,accountexpirationdate,lastlogondate

$count = $op.count

$row = 2

foreach($rec in $op){

    if(($rec.SamAccountName.StartsWith('esc_')) -or ($rec.SamAccountName.StartsWith('adm_'))){

        $rec.SamAccountName

        $report.Cells.Item($row,1) = $rec.Name

        $report.Cells.Item($row,2) = $rec.SamAccountName

        $report.Cells.Item($row,3) = $rec.Title

        $report.Cells.Item($row,4) = $rec.Country

        $report.Cells.Item($row,5) = $rec.Department

        $report.Cells.Item($row,6) = $rec.Office

        $report.Cells.Item($row,7) = $rec.mail

        $report.Cells.Item($row,8) = $rec.Description

        $report.Cells.Item($row,9) = $rec.Enabled

        $report.Cells.Item($row,10) = $rec.Whencreated

        $report.Cells.Item($row,11) = $rec.AccountExpirationDate

        $report.Cells.Item($row,12) = $rec.LastLogonDate

        if($rec.Manager -ne $null){

            $var  = $rec.Manager -split ',' | select -First 1

            $report.Cells.Item($row,13) = $var.Split('=')[1] 

        }

        else{
            
            $report.Cells.Item($row,13) = "Manager details not updated for escalation account"

            $report.Cells.Item($row,13).Interior.ColorIndex  = 3

        }


        # Checking for Manager in Std account

        $sname = $rec.Surname

        $gname = $rec.GivenName

        #$man = Get-ADUser -filter * -properties manager| Where-Object{($_.givenname -eq $rec.givenname) -and ($_.surname -eq $rec.Surname)}

        $man = Get-ADUser -filter { (SurName -eq $sname) -and (GivenName -eq $gname) }  -Properties manager -ErrorAction SilentlyContinue

        if($man.manager -ne $null){

            $var2  = $man.Manager -split ',' | select -First 1

            $report.Cells.Item($row,14) = $var2.Split('=')[1]

        }

        else{

            $report.Cells.Item($row,14) = "Standard account doesn't exist"

            $report.Cells.Item($row,14).Interior.ColorIndex  = 3


        }

        $row++

    }

}

# Saving and closing the file

$Workbook.ActiveSheet.Cells.EntireColumn.AutoFit()

$Workbook._SaveAs('AD_ESC_ADM_Users_List.xlsx')

$Workbook.Close()

