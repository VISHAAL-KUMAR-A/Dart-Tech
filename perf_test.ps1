# Performance Test Script
# Sends 100 requests to measure P95 latency

$baseUrl = "http://localhost:8080"
$apiKey = "hello"
$iterations = 100

Write-Host "Starting performance test with $iterations requests..." -ForegroundColor Green
Write-Host "Note: Will wait after 50 requests to avoid rate limiting" -ForegroundColor Yellow

# Create a test note first
$createBody = @{
    title = "Performance Test Note"
    content = "This is a test note for performance measurement"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v1/notes" `
        -Method Post `
        -Headers @{"X-API-Key" = $apiKey; "Content-Type" = "application/json"} `
        -Body $createBody `
        -ErrorAction Stop
    
    $noteId = $response.id
    Write-Host "Created test note with ID: $noteId" -ForegroundColor Cyan
} catch {
    Write-Host "Error creating note: $_" -ForegroundColor Red
    exit 1
}

# Measure latencies
$latencies = @()

Write-Host "`nRunning $iterations GET requests..." -ForegroundColor Yellow

for ($i = 1; $i -le $iterations; $i++) {
    $start = Get-Date
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/v1/notes/$noteId" `
            -Method Get `
            -Headers @{"X-API-Key" = $apiKey} `
            -ErrorAction Stop
        
        $end = Get-Date
        $latencyMs = ($end - $start).TotalMilliseconds
        $latencies += $latencyMs
        
        if ($i % 10 -eq 0) {
            Write-Host "  Completed $i requests..." -ForegroundColor Gray
        }
        
        # Wait after 50 requests to avoid rate limiting
        if ($i -eq 50) {
            Write-Host "`n  Waiting 65 seconds to reset rate limit..." -ForegroundColor Yellow
            Start-Sleep -Seconds 65
        }
    } catch {
        Write-Host "Request $i failed: $_" -ForegroundColor Red
    }
}

# Calculate statistics
$latencies = $latencies | Sort-Object
$count = $latencies.Count
$min = $latencies[0]
$max = $latencies[-1]
$avg = ($latencies | Measure-Object -Average).Average
$median = $latencies[[Math]::Floor($count / 2)]
$p95Index = [Math]::Floor($count * 0.95)
$p95 = $latencies[$p95Index]
$p99Index = [Math]::Floor($count * 0.99)
$p99 = $latencies[$p99Index]

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "PERFORMANCE TEST RESULTS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Total Requests: $count"
Write-Host "Min Latency:    $([Math]::Round($min, 2)) ms"
Write-Host "Max Latency:    $([Math]::Round($max, 2)) ms"
Write-Host "Avg Latency:    $([Math]::Round($avg, 2)) ms"
Write-Host "Median (P50):   $([Math]::Round($median, 2)) ms"
Write-Host "P95 Latency:    $([Math]::Round($p95, 2)) ms" -ForegroundColor Cyan
Write-Host "P99 Latency:    $([Math]::Round($p99, 2)) ms"
Write-Host "========================================" -ForegroundColor Green

# Clean up test note
try {
    Invoke-RestMethod -Uri "$baseUrl/v1/notes/$noteId" `
        -Method Delete `
        -Headers @{"X-API-Key" = $apiKey} `
        -ErrorAction Stop | Out-Null
    Write-Host "`nCleaned up test note" -ForegroundColor Gray
} catch {
    Write-Host "`nFailed to clean up test note: $_" -ForegroundColor Yellow
}

