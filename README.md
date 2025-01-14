# Set-BulkTeamsEVUsers

-----------------------------------------------------------------

_*Disclaimer:* This script is provided ‘as-is’ without any warranty or support. Use of this script is at your own risk and I accept no responsibility for any damage caused._
---------------------------------------------------------------------------

Script to bulk enable Teams Phone System (EV) users

# Bulk Enable Teams Phone System (EV) Users

This script is designed to bulk enable Teams Phone System (Enterprise Voice) for users using a CSV file as input. It connects to Microsoft Teams Online and performs necessary configurations for each user listed in the CSV.

## Prerequisites

- PowerShell 5.1 or later
- Microsoft Teams PowerShell Module
- An account with appropriate permissions to manage Teams Phone System settings

## Parameters

- **-fqdn**: The fully qualified domain name (FQDN) for the tenant's `onmicrosoft.com` domain (e.g., `-fqdn example.onmicrosoft.com`).
- **-CSVFilePath**: "c:\path_to_file\TeamsEVUsersTemplate.csv"
## Usage

1. Prepare a CSV file with the following columns: 
   - `UPN`: User Principal Name
   - `PhoneNumber`: Direct phone number with extension if applicable
   - `OnlineVoiceRoutingPolicy`: Name of the voice routing policy
   - `Privateline`: (Optional) Private line number

2. Update the script variables to point to your CSV file path:

   ```powershell
   $CSVFilePath = "c:\path_to_file\TeamsEVUsersTemplate.csv"
   ```

3. Run the script with PowerShell:

   ```powershell
   .\Set-BulkTeamsEVUsers.ps1 -fqdn example.onmicrosoft.com -csvfilepath "c:\path_to_file\TeamsEVUsersTemplate.csv"
   ```

## Script Workflow

1. The script imports the Microsoft Teams module and connects to Teams Online using the provided FQDN.
2. It loads user data from the specified CSV file.
3. For each user:
   - Enables Enterprise Voice.
   - Assigns the specified phone number and voice routing policy.
   - Optionally assigns a private line if provided.
   - Verifies the user's configuration.
4. Reports success or failure for each user and for the entire operation.
5. Disconnects from Microsoft Teams Online.

## Error Handling

- The script includes error handling to manage connection issues and failures during user configuration.
- Errors are logged and displayed in the console for review.

## Notes

- Ensure you have the necessary permissions and that the CSV file is correctly formatted before running the script.
- Modify the script as needed to fit your organization's requirements.
