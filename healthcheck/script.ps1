$payload = Invoke-RestMethod -Uri "http://localhost:8081"

$status = $payload.alpha.status
# Write-Output $status

if ($status -eq "healthy") {
    return 0
} else {
    return 1
}