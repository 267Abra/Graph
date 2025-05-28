<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script will get users and their signin activity logs

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

# Get all Users to check from file

$users = Get-Content -Path "C:\Xypy\Graph\EntraID\Licenses\EMS+WinTenterprise\users.txt"

# Create an array to store the SignInActivity information along with userPrincipalName and id
$signInActivities = @()

# Set up the progress bar
$totalUsers = $users.Count
$progress = 0

# Iterate over each user and call Get-MgBetaUser
foreach ($user in $users) {
    # Increment progress
    $progress++
    
    # Update progress bar
    Write-Progress -Activity "Processing Users" -Status "Progress: $progress out of $totalUsers" -PercentComplete (($progress / $totalUsers) * 100)
    
    # Fetch the user data with SignInActivity property
    $userDetails = Get-MgUser -Filter "UserPrincipalName eq '$user'" -Property userPrincipalName, id, SignInActivity, CreatedDateTime
    
    # Collect the SignInActivity information along with userPrincipalName and id
    if ($userDetails.SignInActivity) {
        foreach ($signInActivity in $userDetails.SignInActivity) {
            $signInActivity | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $userDetails.userPrincipalName
            $signInActivity | Add-Member -MemberType NoteProperty -Name "Id" -Value $userDetails.id
            $signInActivity | Add-Member -MemberType NoteProperty -Name "CreatedDateTime" -Value $userDetails.CreatedDateTime
            $signInActivities += $signInActivity
        }
    }
}

# Save the collected SignInActivity information to a CSV file
$csvPath = "C:\Xypy\Graph\EntraID\Licenses\EMS+WinTenterprise\User_Device_license-SignIn-external.csv"

$signInActivities | Export-Csv -Path $csvPath -NoTypeInformation

# Display a message indicating successful export
Write-Host "SignInActivity data has been exported to: $csvPath" 
