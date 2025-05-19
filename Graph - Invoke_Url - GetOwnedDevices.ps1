<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script allows to created dynamic groups and will be tighted users which are synced from AD only.
.AUTHOR
    Krystian Wojno

.VERSION
    1.0.0
    2.0.0

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

.VERSION
    1.0.0
# Start function - Connect to Graph 

Function Connect-Graph {
Connect-MgGraph -NoWelcome
}
Connect-Graph

# Connection + variables 
$endpoint = 'v1.0' # or `beta`
$user = 'krystian.wojno@xypy6.onmicrosoft.com' # Can use user's Id or UPN here
$response = Invoke-MgGraphRequest GET ('{0}/users/{1}?$expand=ownedDevices' -f $endpoint, $user)
$response['ownedDevices'] | ForEach-Object {
    [pscustomobject]@{
        DeviceOwner                         = $response['userPrincipalName']
        DeviceId                            = $_['deviceId']
        DeviceDisplayName                   = $_['displayName']
        DeviceEnabled                       = $_['accountEnabled']
        DeviceApproximateLastSignInDateTime = $_['approximateLastSignInDateTime']
    }
}

.VERSION
    2.0.0

    $endpoint = 'v1.0'

# Get all users (you can filter or limit this to avoid throttling)
$users = Get-MgUser -All -Property Id, UserPrincipalName, DisplayName

# Loop through each user and get their owned devices
$results = foreach ($user in $users) {
    try {
        $response = Invoke-MgGraphRequest -Method GET -Uri "$endpoint/users/$($user.Id)?`$expand=ownedDevices"

        foreach ($device in $response.ownedDevices) {
            [pscustomobject]@{
                UserPrincipalName                  = $user.UserPrincipalName
                UserDisplayName                    = $user.DisplayName
                DeviceId                           = $device.deviceId
                DeviceDisplayName                  = $device.displayName
                DeviceEnabled                      = $device.accountEnabled
                ApproximateLastSignInDateTime      = $device.approximateLastSignInDateTime
            }
        }
    }
    catch {
        Write-Warning "Failed to get devices for $($user.UserPrincipalName): $_"
    }
}

# Output or export results
$results | Format-Table -AutoSize
# Optionally export:
# $results | Export-Csv -Path "UserDevices.csv" -NoTypeInformation
