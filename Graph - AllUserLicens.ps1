<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script allows interactive searching of Microsoft Graph PowerShell commands using a keyword.
    It optionally lets you refine the search, and expands useful details like URI, Module, and Permissions.

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

# Starting
$users = Get-MgUser -All
$results = @()

foreach ($user in $users) {
    try {
        $licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id |
                          Where-Object { $_.SkuPartNumber -match '^(SPE_E3|STANDARDPACK)' }

        # Add result if license matches
        if ($licenseDetails) {
            $results += [PSCustomObject]@{
                DisplayName = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                Licenses = ($licenseDetails | Select-Object -ExpandProperty SkuPartNumber) -join ', '
            }
        }

    } catch {
        Write-Warning "Failed to get license for $($user.UserPrincipalName): $_"
    }
}

# Export or display results
$results | Export-Csv -Path "C:\Xypy\Graph\EntraID\UserLicenses.csv" -NoTypeInformation -Encoding UTF8
