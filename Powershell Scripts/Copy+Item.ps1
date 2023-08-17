$source = "\\FISMGMT003\C$\Users\ext_vkrishna\Desktop\Powershell Scripts\Disc_Practice.ps1"

$destination = "\\MADWINTEL01\C$\"

$date = Get-Date -Format dd-MM-yyyy-Thhmm

$path = $destination + $date

New-Item -ItemType Directory -Path $path

Copy-Item -LiteralPath $source -Destination $path -Recurse -Force 
