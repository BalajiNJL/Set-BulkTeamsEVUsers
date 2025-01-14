# Script to bulk enable Teams Phone system (EV) for users

# define and set variables
$userEvEnabled = $true
$msFQDN = "example.onmicrosoft.com"
$CSVFilePath = "c:\path_to_file\TeamsEVUsersTemplate.csv"

try {
    # Connect to TeamsOnline
    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams -TenantDomain $msFQDN

    try {
        # Load user list CSV file
        $TeamEVUsers = Import-Csv -Path $CSVFilePath

        # Iterate through each user and enable Teams EV
        $TeamEVUsers | ForEach-Object {
            try {
                # Enable EV, Assign Phone number, Assign Policy
                 Set-CsPhoneNumberAssignment -Identity $_.UPN -EnterpriseVoiceEnabled $True 
                 Set-CsPhoneNumberAssignment -Identity $_.UPN -PhoneNumber $_.PhoneNumber -PhoneNumberType DirectRouting 
                 Grant-CsOnlineVoiceRoutingPolicy -PolicyName $_.OnlineVoiceRoutingPolicy -Identity $_.UPN

                # Assign private number
                if (![string]::IsNullOrEmpty($_.Privateline)) {
                    Set-CsPhoneNumberAssignment -Identity $_.UPN -PhoneNumber $_.Privateline -PhoneNumberType DirectRouting -AssignmentCategory Private
                    } 

                # Check user
				Get-CsOnlineUser -Identity $_.UPN | FL DisplayName, EnterpriseVoiceEnabled, LineURI, FeatureTypes, OnlineVoiceRoutingPolicy, PrivateLine
                # Get-CsOnlineUser -Identity $_.UPN 
                 }
            catch {
                $userEvEnabled = $false
                Write-host -f Red "Error enabling EV for the user:" $_.UPN
                Write-host -f Red  $_.Exception.Message
            }
        }
        if ($userEvEnabled) {
            Write-host -f Green "Enabled Teams Phone System (EV) for all users"
        }
    }
    catch {
        Write-host -f Red "Unable to read the file" $_.Exception.Message
    }
    # Disconnect from Teams Online
    Disconnect-MicrosoftTeams
    Write-host -f Green "Disconnected from Teams Online"
}
catch {
    Write-host -f Red "Unable to connect to Teams online. Error:" $_.Exception.Message
}