<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script gathersv info about:
    - owned devices
    - licenses assigned
    - Users
    
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

# Starting Script

$users = Get-Content -Path "C:\Xypy\Graph\EntraID\users.txt"
$results = @()

foreach ($userUPN in $users) {
    try {
        $user = Get-MgUser -UserId $userUPN -ExpandProperty OwnedDevices
        $licenseDetails = Get-MgUserLicenseDetail -UserId $userUPN |
                          Where-Object { $_.SkuPartNumber -match '^(EMS|Win10_VDA_E3)' }

        $licenseSkus = $licenseDetails.SkuPartNumber -join ', '

        if ($user.OwnedDevices) {
            foreach ($deviceRef in $user.OwnedDevices) {
                $device = Get-MgDevice -DeviceId $deviceRef.Id

                $results += [PSCustomObject]@{
                    UserPrincipalName = $user.UserPrincipalName
                    DisplayName       = $user.DisplayName
                    DeviceName        = $device.DisplayName
                    OperatingSystem   = $device.OperatingSystem
                    Licenses          = $licenseSkus
                }
            }
        }
        else {
            $results += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                DisplayName       = $user.DisplayName
                DeviceName        = 'None'
                OperatingSystem   = 'N/A'
                Licenses          = $licenseSkus
            }
        }
    }
    catch {
        Write-Warning "Failed to get data for $userUPN"
    }
}

# Export only if we got results
if ($results.Count -gt 0) {
    $results | Export-Csv -Path "C:\Xypy\Graph\EntraID\User_Device_Licenses.csv" -NoTypeInformation -Encoding UTF8
} else {
    Write-Host "No data to export."
}


$users = Get-Content -Path "C:\Xypy\Graph\EntraID\users-no-employeeid.txt.txt"

$noid = foreach ($user in $users) {
    get-aduser -filter "UserPrincipalName -like '$user'" -Properties UserPrincipalName, EmployeeId `
    | Select-Object UserPrincipalName, EmployeeId
}