# OS details
Get-WmiObject -Class win32_operatingsystem

# Diskspace details
Get-WmiObject -Class win32_logicaldisk | select @{n="Size(GB)";e={[math]::Ceiling($_.size/1GB)}},@{n="Freespace(GB)";e={[math]::Ceiling($_.Freespace/1gb)}},
@{n="Free(%)";e={[math]::Ceiling(($_.Freespace/$_.size)*100)}},
@{n="Used(%)";e={[math]::Ceiling(($_.size - $_.freespace)/$_.size * 100)}}

# RAM
Get-WmiObject -Class win32_physicalmemory | select @{n="capacity(GB)";e={$_.capacity/1gb}}

# CPU
Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor | select Percentprocessortime

# Listing WMI classes
Get-WmiObject -List | ? {$_.name -match "disk"}

# Array
$a = @(1,2,3,5,9,0)
$name = 'krishna','sai','varigalla' #An array can be created as a comma-separated list as well.
$name+='ksv' #Inserting elemrnts to array
$a | sort -Descending
$testMultidimensionalArrays = @(1,2,3), @(4,5,6), @(7,8,9) 
#Looping in arrays
for($i=0;$i -lt $a.Length;$i++){
    $a[$i] + 2
}

#Interactive static array
$arr = @()
$size = Read-Host -Prompt "enter size of array"
for($i=0;$i -lt $size;$i++){
    $no = Read-Host -Prompt "enter no." -Debug
    $arr+=$no
}

#The following is the syntax to create an ARRAY LIST (DYNAMIC ARRAY--When the capacity of the existing array is full and when we try to add new elements
#to the array,a new array will be created by copying the elements to the new array by increasing the array size)
$myarray = [System.Collections.ArrayList]::new()
$myarray.Add(1)
$myarray.Add(2)
$myarray.Insert(1,3)
$myarray.Capacity
$myarray.Count

# HASH TABLE (Structured array)
# Hash table is used to implement a structured array. In the hash table, the values are stored in a key-value format. 
# They are also known as Dictionary or Associative array.
$hash_table = @{}
$ex_hash = [ordered]@{
    name = "Krishna"
    age = "23"
    company = "HCL"
}
$ex_hash.Add("YOE",2)
$ex_hash | Sort-Object -Property age








### PS Objects

$obj = [pscustomobject] @{
Name="Krish"
Company="HCLTECH"
Role="Analyst"

}

$nobj = New-Object psobject
$nobj | Add-Member NoteProperty Name Krish
$nobj | Add-Member NoteProperty Company HCL

$hash = @{
Name="krish"
Company = "HCLT"
}


