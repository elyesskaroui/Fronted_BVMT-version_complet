param(
    [string]$Message = "Update project $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$status = git status --porcelain

if (-not $status) {
    Write-Host "No local changes to commit."
    exit 0
}

git add .

if ($LASTEXITCODE -ne 0) {
    Write-Error "git add failed."
    exit $LASTEXITCODE
}

git commit -m $Message

if ($LASTEXITCODE -ne 0) {
    Write-Error "git commit failed."
    exit $LASTEXITCODE
}

git push

if ($LASTEXITCODE -ne 0) {
    Write-Error "git push failed."
    exit $LASTEXITCODE
}

Write-Host "Changes pushed to GitHub."