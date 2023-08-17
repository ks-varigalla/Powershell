clear-host

$dt=get-date -Format "MM-dd-yyyy"

#$Domain = (Get-ADDomain).NetBIOSName 

$paths = Get-Content -Path C:\Temp\ACL\Paths.txt

forEach ($path in $paths){

Write-Host "Gathering all folder names, this could take a long time on bigger folder trees..."

$Folders = Get-ChildItem -Path $Path -Recurse  | Where { $_.PSisContainer -eq $true }

Write-Host "Gathering ACL's for $($Folders.Count) folders..."

$final =
ForEach ($Folder in $Folders)
{
Write-Host "Working on $($Folder.FullName)..."

$ACLs = Get-Acl $Folder.FullName | ForEach-Object { $_.Access }

ForEach ($ACL in $ACLs) 
{ 
    if ($ACL.IdentityReference -notlike "BUILTIN\Administrators" -and $ACL.IdentityReference -notlike "NT AUTHORITY\SYSTEM" ) 
    {   
                   $Name1 = $ACL.IdentityReference.Value.Split("\")[1]

                   $Result = New-Object PSObject -Property @{

                            Path = $Folder.Fullname
                            $User = Get-ADUser -identity $Name1 -Properties Name,samaccountname,emailaddress | Select Name,samaccountname,emailaddress
                            User = $User.Name
                            samaccountname = $User.samaccountname
                            #title = $user.title
                            #country = $user.country
                            #department = $user.department
                            #office = $user.office
                            #manager = $user.manager
                            Emailaddress = $user.emailaddress
                            #description = $user.description
                            #enabled = $user.enabled
                            #whencreated = $user.whencreated
                            #accountexpirationdate = $user.accountexpirationdate
                            FileSystemRights = $ACL.FileSystemRights
                            AccessControlType = $ACL.AccessControlType
                            Inherited = $ACL.IsInherited
                                                                  }
                   $Result | Select Path,User,Samaccountname, Emailaddress,FilesystemRights,AccessControlType,Inherited
   
    }

  }

}

$filename = $Folders.name

$WorkBookName = "‪C:\Users\adm_kasirajam\Desktop\ACL Report\$filename.xlsx"

#$final | Export-Excel -Path $WorkBookName -WorkSheetname "$filename" -BoldTopRow -AutoSize
$final | Export-csv -Path ‪ACLOutput.csv -Force -NoTypeInformation 

}
