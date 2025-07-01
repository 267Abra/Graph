<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
   This script retrievies user groups in entraID

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

# Function to get user group information
function Get-UserMgGroupInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserId
    )

    try {
        $user = get-mguser -UserId $UserId -ExpandProperty MemberOf | Select-Object DisplayName, Id, MemberOf
    } catch {
        Write-Error "Failed to retrieve user information for UserId: $UserId. Error: $_"
        return
    }

    foreach ($group in $user.MemberOf) {
        try {
            $groupDetails = Get-MgGroup -GroupId $group.Id -Property DisplayName, Id, SecurityEnabled
        } catch {
            Write-Warning "Failed to retrieve group information for GroupId: $($group.Id). Error: $_"
            continue
        }

        if ($groupDetails) {
            [PSCustomObject]@{
                GroupName    = $groupDetails.DisplayName
                GroupId      = $groupDetails.Id
                SecurityEnabled  = $groupDetails.SecurityEnabled
            }

        }
    }
    
        Write-Host ""
        Write-Host "Successfully retrieved group information for user $userid" -ForegroundColor Cyan
}


