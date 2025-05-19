<#
.SYNOPSIS
    Microsoft Graph Command Search Utility

.DESCRIPTION
    This script allows to created dynamic groups and will be tighted users which are synced from AD only.
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

# Declaring variables 
$properties = @(
    "DisplayName" 
    "City"           
    "OnPremisesSyncEnabled"
                
)

$GroupParam = @{
    DisplayName = "Users - AD Sync | Dynamic"
    GroupTypes = @(
        'DynamicMembership'
    )
    SecurityEnabled               = $true
    IsAssignableToRole            = $false
    MailEnabled                   = $false
    membershipRuleProcessingState = 'On'
    MembershipRule = '(User.AccountEnabled -eq true) and (User.dirSyncEnabled -eq true)'
    Description                   = "All users synced from AD"
    MailNickName                  =  (New-Guid).Guid.Substring(0,10)
    "Owners@odata.bind" = @(
    "https://graph.microsoft.com/v1.0/users/labadmin@xypy6.onmicrosoft.com"
)
}

# Get users
$users = get-mguser -All -Property $properties | Where-Object { $_.OnPremisesSyncEnabled -eq $true -and $_.DisplayName -notlike "*Synchronization Service Account*" } | Select-Object $properties | Out-Null
$users | Out-File -FilePath $env:ALLUSERSPROFILE\AD-Sync.csv -Encoding utf8
# Create group "Users - AD sync"
Function CreateGroup {
    New-MgGroup -BodyParameter $GroupParam
}

CreateGroup









