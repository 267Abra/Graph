<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script finds Groups with no owners.

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

# 1 case 
$groups = get-mggroup -all -ExpandProperty owners `
| Sort-Object -Property DisplayName `
| Select-Object DisplayName, Owners, Id

# 2 case
$NoOwner = $groups | Where-Object {-not $_.owners} `
| select Displayname, ID

# Get results
$OwnersDetails = foreach ($group in $groups) {
    foreach ($owner in $group.Owners) {
        $ownerUser = Get-MgUser -UserId $owner.Id

        [PSCustomObject]@{
            GroupName   = $group.DisplayName
            GroupId     = $group.Id
            OwnerName   = $ownerUser.DisplayName
        }
    }
}

# SaveToFile
$OwnersDetails | Export-Csv -Path "C:\Xypy\Graph\EntraID\GroupsOwners.csv" -Encoding utf8
$NoOwner | Export-Csv -Path "C:\Xypy\Graph\EntraID\Groups - NoOwners.csv" -Encoding utf8