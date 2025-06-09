<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script retrieves device information for a specific user in Microsoft Entra ID.

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
function Get-UserDeviceInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Enter the user's UPN (email).")]
        [string]$UserPrincipalName
    )

    try {
        Write-Verbose "Fetching user info for $UserPrincipalName"

        # Get the user with their owned devices expanded
        $user = Get-MgUser -Filter "UserPrincipalName eq '$UserPrincipalName'" -ExpandProperty OwnedDevices

        if (-not $user) {
            Write-Warning "User not found: $UserPrincipalName"
            return
        }

        # Loop through each owned device and fetch full details
        $deviceDetails = foreach ($device in $user.OwnedDevices) {
            Get-MgDevice -DeviceId $device.Id
        }

        # Construct and return formatted object(s)
        $results = [System.Collections.Generic.List[object]]::new()

        foreach ($device in $deviceDetails) {
            $obj = [pscustomobject]@{
                DisplayName     = $user.DisplayName
                OperatingSystem = $device.OperatingSystem
                DeviceName      = $device.DisplayName
            }
            $results.Add($obj)
        }

        return $results
    }
    catch {
        Write-Error "Failed to retrieve device info: $_"
    }
}


# Get-UserDeviceInfo # UserPrincipalName // continue with the UPN of the user you want to query
