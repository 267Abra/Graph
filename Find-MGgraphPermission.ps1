# Ask the user for the command keyword
$read = Read-Host "What command are you looking for?"
Write-Host "Searching for commands containing: $read" -ForegroundColor Cyan
Start-Sleep -Seconds 1

# Search for matching Graph commands
try {
    $search = Find-MgGraphCommand -Command * | Where-Object { $_.Command -like "*$read*" } | Select-Object -First 20

    if (-not $search) {
        Write-Host "No results found for: $read"
        return
    } else {
        $search | Format-Table Command, Uri, HttpMethod -AutoSize
    }
}
catch {
    Write-Host "Error occurred during search: $_"
    return
}

# If more than 10, ask to refine
if ($search.Count -gt 10) {
    Write-Host "`nMore than 10 commands found. Do you want to narrow your search within the current results? (Yes/No):" -NoNewline -ForegroundColor Cyan
    $response = Read-Host

    if ($response.ToLower() -eq 'yes') {
        $refine = Read-Host "Type more specific keyword to filter these results"
        $filtered = $search | Where-Object { $_.Command -like "$refine" }

        if (-not $filtered) {
            Write-Host "No results matched your refined keyword." -ForegroundColor Red
        } else {
            Write-Host "`nFiltered results with permissions:" -ForegroundColor Green

            $filtered | ForEach-Object {
                [PSCustomObject]@{
                    Command     = $_.Command
                    Module      = $_.Module
                    Uri         = $_.Uri
                }
            } | Format-Table -AutoSize
        }
    } else {
        Write-Host "Showing all results above." -ForegroundColor Green
    }
}
