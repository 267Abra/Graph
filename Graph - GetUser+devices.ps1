<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script will fetch the user + device info details.
    If want to get more context scope, define parameters as below and change the syntax:

    .VERSION = 2.0.0

    switch filter:
.1   -All -ExpandProperty OwnedDevices | where-object {$_.UserPrincipalName -like "*" -and $_.City -like "Warsaw"}
.2   -Filter "startswith(DisplayName,'Krystian')" or -Filter "AccountEnabled eq true"
.3   -Filter "Department eq 'IT'" or -Filter "JobTitle eq 'Security Analyst'"
.4   -Filter "Department eq 'HR' and AccountEnabled eq true" or -Filter "City eq 'Warsaw'"
.5   -Filter "OnPremisesSyncEnabled eq false and JobTitle eq 'HR Analyst'" 
.6   -Filter "OnPremisesSyncEnabled eq true" | Where-Object { $_.CompanyName -eq "Xypy" }
.7   $params = @{
     Filter = "AccountEnabled eq true and Department eq 'IT'"
     Property = @("Id", "DisplayName", "Department")
     All = $true
}
Get-MgUser @params
.8   -Filter "(Department eq 'IT' or Department eq 'Security') and AccountEnabled eq true"
.9   -Filter "AccountEnabled eq true and not (Department eq 'HR' or Department eq 'Finance')"
.10  -Filter "(JobTitle eq 'Cloud Engineer' or JobTitle eq 'System Admin') and OnPremisesSyncEnabled eq true"


.AUTHOR
    Krystian Wojno

.VERSION
    1.0.0

.LASTUPDATED
    2025-05-14

.REQUIREMENTS
    - Microsoft.Graph PowerShell SDK
    - Connected MgGraph session (`Connect-MgGraph`)

.NOTES
    Great for discovering Microsoft Graph commands with visibility into scopes and permissions.
    Perfect for use in internal automation tooling or pre-deployment audits.

.LINK
    https://github.com/267Abra/Graph.git
#>

function GetUserDevice {
    $user = Get-MgUser -Filter "UserPrincipalName eq 'Krystian.Wojno@xypy6.onmicrosoft.com'" -ExpandProperty OwnedDevices

    $deviceDetails = foreach ($device in $user.OwnedDevices) {
        Get-MgDevice -DeviceId $device.Id
    }

    $deviceDetails | ForEach-Object {
        [pscustomobject]@{
            DisplayName     = $user.DisplayName
            OperatingSystem = $_.OperatingSystem
            DeviceName      = $_.DisplayName
        }
    }
}

# Call the function
GetUserDevice



