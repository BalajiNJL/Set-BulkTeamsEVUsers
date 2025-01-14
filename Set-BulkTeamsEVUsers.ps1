# ============================================================================
# Set-BulkTeamsEVUsers.ps1
# ============================================================================
# Script to bulk enable Teams Phone system (EV) for users
#
# This script is designed to bulk enable Teams Phone System (Enterprise Voice) for users using a CSV file as input.
# It connects to Microsoft Teams Online and performs necessary configurations for each user listed in the CSV.
#
# Usage:
#   .\Set-BulkTeamsEVUsers.ps1 -msFQDN <tenant_domain> -CSVFilePath <path_to_csv_file>
#
# Parameters:
#   -msFQDN: The fully qualified domain name (FQDN) for the tenant's onmicrosoft.com domain (e.g., example.onmicrosoft.com)
#   -CSVFilePath: The path to the CSV file containing the user data (e.g., c:\path_to_file\TeamsEVUsersTemplate.csv)
#
# CSV File Format: (refer to TeamsEVUsersTemplate.csv)
#   The CSV file should contain the following columns:
#     - UPN: User Principal Name
#     - PhoneNumber: Direct phone number with extension if applicable
#     - OnlineVoiceRoutingPolicy: Name of the voice routing policy
#     - Privateline: (Optional) Private line number
#
# Example CSV File:
#   UPN,PhoneNumber,OnlineVoiceRoutingPolicy,Privateline
#   user1@example.com,+12065551234;ext=1234,No Restrictions,+12065556789
#   user2@example.com,+12065551235;ext=1235,No Restrictions,
#
# ============================================================================
# $msFQDN = "example.onmicrosoft.com"
# $CSVFilePath = "c:\path_to_file\TeamsEVUsersTemplate.csv"

# define parameters
param (
    [string]$msFQDN,
    [string]$CSVFilePath
)

if (!$msFQDN -or !$CSVFilePath) {
    Write-Host "Error: Both msFQDN and CSVFilePath parameters are required."
    exit 1
}

# define and set variables
$userEvEnabled = $true

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