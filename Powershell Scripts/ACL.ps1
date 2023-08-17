clear-host

 

$dt=get-date -Format "MM-dd-yyyy"
#Start-Transcript -Path "‪C:\Users\adm_kasirajam\Desktop\ACL Report\transcript-$dt.txt"

 

$Domain = (Get-ADDomain).NetBIOSName 
$paths = Get-Content -Path C:\Temp\ACL\Paths.txt
forEach ($path in $paths){

 


   Write-Verbose "...and all sub-folders"
    Write-Verbose "Gathering all folder names, this could take a long time on bigger folder trees..."
    $Folders = Get-ChildItem -Path $Path -Recurse  | Where { $_.PSisContainer -eq $true }


Write-Verbose "Gathering ACL's for $($Folders.Count) folders..."
$final =
ForEach ($Folder in $Folders)
{   Write-Verbose "Working on $($Folder.FullName)..."
    $ACLs = Get-Acl $Folder.FullName | ForEach-Object { $_.Access }
    ForEach ($ACL in $ACLs) 

     { if ($Acl.IdentityReference -notlike "BUILTIN\Administrators" -and
    $Acl.IdentityReference -notlike "NT AUTHORITY\SYSTEM" -and $Acl.FileSystemRights -notlike "Domain Admins")

 

    {   If ($ACL.IdentityReference -match "\\")
        {   If ($ACL.IdentityReference.Value.Split("\")[0].ToUpper() -eq $Domain.ToUpper())
            {   $Name1 = $ACL.IdentityReference.Value.Split("\")[1]

                If ((Get-ADObject -Filter 'SamAccountName -eq $Name1').ObjectClass -eq "group")

                { ForEach ($User in (Get-ADgroupmember $Name1 | Where objectclass -eq 'user' | foreach { Get-ADUser $_ -Properties * | select Name,samaccountname,title,country, department, office, manager, emailaddress, description, enabled, whencreated, accountexpirationdate, lastlogondate }))

                    {   $Result = New-Object PSObject -Property @{
                           Path = $Folder.Fullname
                            Group = $Name1
                            User = $User.Name
                            samaccountname = $User.samaccountname
                            title = $user.title
                            country = $user.country
                            department = $user.department
                            office = $user.office
                            manager = $user.manager
                            emailaddress = $user.emailaddress
                            description = $user.description
                            enabled = $user.enabled
                            whencreated = $user.whencreated
                            accountexpirationdate = $user.accountexpirationdate
                            FileSystemRights = $ACL.FileSystemRights
                            AccessControlType = $ACL.AccessControlType
                            Inherited = $ACL.IsInherited
                                                                  }
                        $Result | Select Path,User,samaccountname, emailaddress,Group, FilesystemRights,AccessControlType,Inherited
                    }
                }
                Else
                {    $Result = New-Object PSObject -Property @{
                        Path = $Folder.Fullname
                        Group = ""
                        User = Get-ADUser $Name1 | Select samaccountname,title,country, department, office, manager, emailaddress, description, enabled, whencreated, accountexpirationdate, lastlogondate
                        samaccountname = $User.samaccountname
                        title = $user.title
                        country = $user.country
                        department = $user.department
                        office = $user.office
                        manager = $user.manager
                        emailaddress = $user.emailaddress
                        description = $user.description
                        enabled = $user.enabled
                        whencreated =  $user.whencreated
                        accountexpirationdate = $user.accountexpirationdate
                        FileSystemRights = $ACL.FileSystemRights
                        AccessControlType = $ACL.AccessControlType
                        Inherited = $ACL.IsInherited
                                                               }
                    $Result | Select Path,User,samaccountname, emailaddress,Group, FilesystemRights,AccessControlType,Inherited
                 }            
                    }

        }
        }
    }
    }

$filename = $Folders.name
$WorkBookName = "‪C:\Temp\ACL\filename.xlsx"
$final | Export-csv -Path ‪filename30.csv -Force
}

 


 

#Stop-Transcript