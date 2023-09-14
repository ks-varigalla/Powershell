#Encrypting the SNOW Credentials

$password = ConvertTo-SecureString 'jvh9I6XMJvVw' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('admin', $password)


#SNOW Url

$url = 'https://dev93436.service-now.com/api/now/table/incident'


#Invoking SNOW and getting the Disk alert incidents
$reponse = Invoke-RestMethod -Uri $url -Method Get -Credential $credential -ContentType "application/json"
$response
$filtered_inc = $reponse.result | select Number,Short_description,sys_id,description, state | Where-Object { ($_.Short_description -eq  "Percentage Logical Disk Free Space is low"  ) -and ( $_.state -eq "2" ) } 
$filtered_inc 
#Filtering the Sys_id of incidents
$sys_id = $filtered_inc | select  sys_id

#Ticket body to be updated after resolution
$updated_body = @{
    
    "state" = "In Progress" 
}
#$updated_body.GetType()
$body = $updated_body | ConvertTo-Json 
$link = 'https://dev93436.service-now.com/api/now/table/incident/'
 
#Iterating through the incidents

for($i=0; $i -lt $sys_id.Length ; $i++){
 
    $ur = $sys_id[$i].sys_id   
    $updated_url = $link + $ur
    $updated_url
    $server_id = $filtered_inc[$i].description.Split(':')[4].substring(1,23)
    $server_id
    $drive_id  = $filtered_inc[$i].description.Split(':')[2]
    $drive_id
    $increase_in_threshold = $filtered_inc.description.Split(':').split(' ')[36].substring(0,4)
    $increase_in_threshold

    #Remote login to $server_id to perform actions on $drive_id
    <#

                #LOGIC

    #>

    #Remediation to Cleanup/extension of the Space in $server_id
    <#


                #LOGIC


    #>

    #Updating the ticket after resolving
    $update = Invoke-RestMethod -Uri $updated_url -Method Patch -Body $body -Credential $credential -ContentType "application/json"
    $update.result
}


