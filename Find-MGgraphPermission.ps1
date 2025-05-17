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

# Ask the user for the command keyword
$read = Read-Host "What command are you looking for?"
Write-Host "Searching for commands containing: $read" -ForegroundColor Cyan
Start-Sleep -Seconds 1

# Search for matching Graph commands
try {
    $search = Find-MgGraphCommand -Command * | Where-Object { $_.Command -like "*$read*" } | Select-Object -First 50

    if (-not $search) {
        Write-Host "No results found for: $read" -ForegroundColor Red
        return
    }

    $search | Format-Table Command, Uri -AutoSize
}
catch {
    Write-Host "Error occurred during search: $_" -ForegroundColor Red
    return
}

# Grouping logic for permissions output
function Show-PermissionDetails {
    param ([array]$inputCommands)

    $grouped = $inputCommands | Group-Object { "$($_.Command)|$($_.Uri)|$($_.Method)|$($_.ApiVersion)" }

    foreach ($group in $grouped) {
        $cmd = $group.Group[0]
        Write-Host "`nCommand: $($cmd.Command) $($cmd.Uri) Method: $($cmd.Method) Api: $($cmd.ApiVersion)" -ForegroundColor Cyan

        $permissionList = @()
        foreach ($entry in $group.Group) {
            foreach ($perm in $entry.Permissions) {
                $permissionList += [PSCustomObject]@{
                    Permission  = $perm.Name
                    IsAdmin     = $perm.IsAdmin
                    Description = $perm.Description
                }
            }
        }

        $permissionList | Sort-Object Permission | Format-Table -AutoSize
    }
}

# Decision logic
if ($search.Count -gt 20) {
    Write-Host "`nMore than 20 commands found. Do you want to narrow your search within the current results? (Yes/No):" -NoNewline -ForegroundColor Cyan
    $response = Read-Host

    if ($response.ToLower() -eq 'yes') {
        $refine = Read-Host "Type more specific keyword to filter these results"
        $filtered = $search | Where-Object { $_.Command -like "*$refine*" }

        if (-not $filtered) {
            Write-Host "No results matched your refined keyword." -ForegroundColor Red
            return
        }

        Write-Host "`nFiltered results with permissions:" -ForegroundColor Green
        Show-PermissionDetails -inputCommands $filtered
    }
    else {
        Write-Host "`nShowing all results with permissions:" -ForegroundColor Green
        Show-PermissionDetails -inputCommands $search
    }
}
else {
    Write-Host "`nFewer than or equal to 20 results. Showing detailed permissions automatically..." -ForegroundColor Green
    Show-PermissionDetails -inputCommands $search
}
