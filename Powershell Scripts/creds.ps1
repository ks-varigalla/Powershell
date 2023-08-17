# Create a secure creddential object for the user to access the Azure VM
# Type the password in the console when prompted 
$Credential = Get-Credential -UserName 'ext_vkrishna' -Message 'Enter your password'

# Save the encrypted password to a file
$Credential.Password | ConvertFrom-SecureString | Set-Content 'C:\temp\secure_password.txt'
