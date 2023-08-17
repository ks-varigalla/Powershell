$date = Get-Date -Format "ddMMyyyyThhmmss"
New-Item -Path "C:\Temp\$date.txt" -ItemType Directory
$v = Get-ChildItem -literalpath "\\10.134.9.4\Laserfiche\test\Opentext\Invoice_archive\"
#$v | Out-File -path "$date12.txt"
$v | Out-File -FilePath "C:\Temp\$date12.txt"