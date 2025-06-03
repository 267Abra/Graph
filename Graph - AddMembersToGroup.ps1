<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script adds users to a group in Microsoft Entra ID (Azure AD) based on specific criteria.
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

# Declaring variables for users to be added to the group
$properties = @(
     "DisplayName" 
     "City"           
     "CompanyName"
     "Id"    
#    "Department"    # Filtered Out
#    "Country"       # Filtered Out 
)
$users = get-mguser -all -Property $properties | Where-Object {
        $_.CompanyName -like "Xypy" -and   # Change $_. to other values if needed 
        $_.City -like "Gdansk"      -and   # Change $_. to other values if needed
        $_.UserType -ne "Guest"
       }|
        Select-Object Id      
$users | Out-Null

# Define group parameters
$GroupParam = @{
    DisplayName         = "Xypy: Users - Run Event | Assigned"
    SecurityEnabled     = $true
    IsAssignableToRole  = $false
    MailEnabled         = $false
    Description         = "All users for RunEvent - excluding guest accounts"
    MailNickname        = (New-Guid).Guid.Substring(0, 10)
    "Owners@odata.bind" = @(
        "https://graph.microsoft.com/v1.0/users/labadmin@xypy6.onmicrosoft.com"
    )
}

# Function to create a group and return it
function New-MgGroupWithReturn {
    return New-MgGroup -BodyParameter $GroupParam
}

# Call function and capture the created group
$createdGroup = New-MgGroupWithReturn

# Retrieve group again using GroupId
$retrievedGroup = Get-MgGroup -GroupId $createdGroup.Id

# Show the group
$retrievedGroup | Format-List DisplayName, Id, Description

Function Add-Users {
    foreach ($user in $users ) {
        New-MgGroupMember -GroupId $retrievedGroup.id `
    -BodyParameter @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.id)"
        }
    }
}
Add-users
