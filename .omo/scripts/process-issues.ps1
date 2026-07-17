param(
    [string]$RepoPath = "E:\user\Documents\football-game",
    [string]$Action = "check"
)

if ($Action -eq "check") {
    $gh = Get-Command "gh" -ErrorAction SilentlyContinue
    if ($gh) {
        Write-Output "gh CLI available — run 'gh issue list' to check open issues"
    } else {
        Write-Output "gh CLI not available. Install from https://cli.github.com/ or use GitHub web UI."
    }
}
