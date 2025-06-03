# Import Microsoft Graph Module and Connect
Import-Module Microsoft.Graph.Authentication
Connect-MgGraph -Scopes AuditLog.Read.All -ContextScope Process

# Load user IDs or UPNs from the file
$userIds = Get-Content 'C:\Xypy\Graph\EntraID\Licenses\EMS+WinTenterprise\users.id.test.txt'

# Initialize an array to collect all results
$allReports = @()

# Loop through each user
foreach ($userId in $userIds) {
    # Construct the URI for the API call
    $uri = @"
beta/auditLogs/signIns?\$filter=(userId eq '$userId' and appDisplayName eq 'Windows Sign In')&\$orderby=createdDateTime desc&\$top=5
"@

    # Call Microsoft Graph API
    try {
        $response = Invoke-MgGraphRequest -Uri $uri

        if ($response.value) {
            foreach ($entry in $response.value) {
                $allReports += [pscustomobject]@{
                    userId            = $userId
                    createdDateTime   = $entry.createdDateTime
                    userDisplayName   = $entry.userDisplayName
                    ipAddress         = $entry.ipAddress
                    deviceId          = $entry.deviceDetail.deviceId
                    deviceDisplayName = $entry.deviceDetail.displayName
                    correlationId     = $entry.correlationId
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to retrieve data for userId $userId $_"
    }
}

# Save the output to a CSV file
$outputFile = "C:\Xypy\Graph\EntraID\Licenses\EMS+WinTenterprise\SignInReports-WindowsLogins-Ext.csv"
$allReports | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

# Display completion message
Write-Output "Sign-in report saved to $outputFile"
