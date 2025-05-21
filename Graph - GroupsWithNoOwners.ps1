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

# Function: Get all groups and filter out groups with no owners
function Get-AllGroups {

    $groups = Get-MgGroup -All -ExpandProperty Owners |
        Sort-Object -Property DisplayName |
        Select-Object DisplayName, Owners, Id, OnPremisesSyncEnabled

    return $groups
}

# Function: Extract group owner details
function Get-GroupsWithOwners {
    param ([array]$Groups)

    $ownerDetails = foreach ($group in $Groups) {
        foreach ($owner in $group.Owners) {
            $ownerUser = Get-MgUser -UserId $owner.Id

            [PSCustomObject]@{
                GroupName = $group.DisplayName
                GroupId   = $group.Id
                OwnerName = $ownerUser.DisplayName
            }
        }
    }

    return $ownerDetails
}

# Function: Extract groups with no owners
function Get-GroupsWithoutOwners {
    param ([array]$Groups)

    $noOwnerGroups = $Groups | Where-Object { -not $_.Owners }
    $result = @()

    foreach ($group in $noOwnerGroups) {
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName"  -Value $group.DisplayName
        $obj | Add-Member -MemberType NoteProperty -Name "ID"           -Value $group.Id
        $obj | Add-Member -MemberType NoteProperty -Name "Owners"       -Value $null
        $obj | Add-Member -MemberType NoteProperty -Name "OnPremiseSyn" -Value $group.OnPremisesSyncEnabled

        $result += $obj
    }

    return $result
}

# Function: Save results to CSV
function Save-ResultsToCSV {
    param (
        [array]$WithOwners,
        [array]$WithoutOwners
    )

    $WithOwners     | Export-Csv -Path "C:\Xypy\Graph\EntraID\GroupsOwners.csv" -Encoding UTF8 -NoTypeInformation
    $WithoutOwners  | Export-Csv -Path "C:\Xypy\Graph\EntraID\Groups - NoOwners.csv" -Encoding UTF8 -NoTypeInformation

}

# ---- Main Execution ----

$allGroups      = Get-AllGroups
$groupsWithOwners = Get-GroupsWithOwners -Groups $allGroups
$groupsWithoutOwners = Get-GroupsWithoutOwners -Groups $allGroups
Save-ResultsToCSV -WithOwners $groupsWithOwners -WithoutOwners $groupsWithoutOwners
