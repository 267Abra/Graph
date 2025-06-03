<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script allows to repeated assigned groups and will be tighted users which are included for specific events.
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

$users = Get-Content -Path "C:\Xypy\Graph\EntraID\M365+E1users.txt.txt"
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



#2

$users = Get-Content -Path "C:\Xypy\Graph\EntraID\M365+E1users.txt.txt"
$results = @()

foreach ($userUPN in $users) {
    try {
        # Get full user object from UPN
        $user = Get-MgUser -UserId $userUPN

        # Get licenses for the user
        $licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id
        $skuList = $licenseDetails.SkuPartNumber

        # Check if BOTH licenses are present
        if ($skuList -match '^(SPE_E3|STANDARDPACK)') {
            $results += [PSCustomObject]@{
                DisplayName        = $user.DisplayName
                UserPrincipalName  = $user.UserPrincipalName
                Licenses           = ($skuList -join ', ')
            }
        }

    } catch {
        Write-Warning "Failed to get license for $userUPN $_"
    }
}

# Export to CSV
$results | Export-Csv -Path "C:\Xypy\Graph\EntraID\Users_With_Both_Licenses.csv" -NoTypeInformation -Encoding UTF8


# 3

$users = Get-Content -Path "C:\Xypy\Graph\EntraID\M365+E1users.txt.txt"
$results = @()

foreach ($userUPN in $users) {
    try {
        $user = Get-MgUser -UserId $userUPN
        $licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id
        $skuList = $licenseDetails.SkuPartNumber

        # Only include users with BOTH licenses
        if ($skuList -contains 'SPE_E3' -and $skuList -contains 'STANDARDPACK') {
            $results += [PSCustomObject]@{
                DisplayName        = $user.DisplayName
                UserPrincipalName  = $user.UserPrincipalName
                Licenses           = ($skuList -join ', ')
            }
        }
    } catch {
        Write-Warning "Failed to get license for $userUPN $_"
    }
}

$results | Export-Csv -Path "C:\Xypy\Graph\EntraID\Users_With_Both_Licenses.csv" -NoTypeInformation -Encoding UTF8




# Path to the user list file
$userListPath = "C:\Xypy\Graph\EntraID\M365+E1users.txt.txt"

# Output CSV path
$outputCsvPath = "C:\Xypy\Graph\EntraID\Users_With_SPE_E3_And_STANDARDPACK.csv"

# Read user UPNs from file
$users = Get-Content -Path $userListPath

# Prepare results array
$results = @()

foreach ($userUPN in $users) {
    try {
        # Get user object
        $user = Get-MgUser -UserId $userUPN

        # Get license details
        $licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id
        $skuList = $licenseDetails | ForEach-Object { $_.SkuPartNumber }

        # Check for both target licenses
        if ($skuList -contains 'SPE_E3' -and $skuList -contains 'STANDARDPACK') {
            # Filter to only the target licenses for output
            $filteredLicenses = $skuList | Where-Object { $_ -in @('SPE_E3', 'STANDARDPACK') }

            $results += [PSCustomObject]@{
                DisplayName        = $user.DisplayName
                UserPrincipalName  = $user.UserPrincipalName
                Licenses           = ($filteredLicenses -join ', ')
            }
        }
    } catch {
        Write-Warning "Failed to get license for $userUPN $_"
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Done. Output saved to: $outputCsvPath"

