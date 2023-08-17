# Editing the Switch config file

$switches = Get-Content -Path "C:\Users\ext_vkrishna\Desktop\Powershell Scripts\switch-config\test-switches.txt"

#$creds = Get-Credential

foreach($switch in $switches){

$ssh = New-SSHSession -ComputerName $switch -Credential $creds -ConnectionTimeout 300 -Force

$stream = $ssh.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)

Write-Host "Configuring switch $switch"

$stream.Write("configure terminal`n")

# SNMP ACL

$stream.Write("ip access-list extended SNMP-ACL`n")

$stream.Write("permit udp host 10.125.173.15 any eq 161 162`n")

$stream.Write("permit udp host 10.125.173.16 any eq 161 162`n")

$stream.Write("deny ip any any`n")

$stream.Write("snmp-server community F1sk@rs@hcl22 RW SNMP-ACL`n")

# ssh ACL for authenticated source access

$stream.Write(" no ip access-list extended 155`n")

$stream.Write("ip access-list extended 155`n")

#$stream.Write("permit ip 10.125.0.0 0.0.0.255 any eq 22`n")

$stream.write("permit tcp host 10.125.97.35 any eq 22`n")

$stream.write("permit tcp host 10.125.97.189 any eq 22`n")

$stream.write("permit tcp 10.22.50.0 0.0.254.255 any eq 22`n")

$stream.Write("deny ip any any`n")

#$stream.Write("`n")

# Disable http and https services

$stream.Write("no ip http server`n")

$stream.Write("ip http secure-server`n")

$stream.write("line vty 0 4`n")

$stream.Write("transport input ssh`n")

$stream.write("access-class 155 in`n")

# Disable level 7 passsword and enable password 5

$stream.Write("!enable ssh v2`n")

$stream.Write("ip ssh version 2`n")

$stream.Write("Exit`n")

$stream.Write("copy running-config startup-config`n")

#$stream.Write("show running-config`n")
#$stream.Write("show version`n")

$stream.Write(" `n")

$stream.Read()

#$stream.Close()

#$ssh.Disconnect()

}