# Patch StartAllBackX64.dll - Rename & Replace Method
$dllPath = "C:\Program Files\StartAllBack\StartAllBackX64.dll"
$backupPath = $dllPath + ".backup"
$renamedPath = $dllPath + ".old"
$tempPath = "$env:TEMP\StartAllBackX64_temp.dll"

Write-Host "Stopping Windows Explorer and StartAllBack..." -ForegroundColor Yellow

# Stop processes
Get-Process -Name "StartAllBack" -ErrorAction SilentlyContinue | Stop-Process -Force
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Create backup if it doesn't exist
if (-not (Test-Path $backupPath)) {
    Copy-Item $dllPath $backupPath -Force
    Write-Host "Backup created: $backupPath" -ForegroundColor Green
}

# Copy original to temp for patching
Copy-Item $dllPath $tempPath -Force
Write-Host "Copied to temp location" -ForegroundColor Cyan

# Read and patch temp file
$bytes = [System.IO.File]::ReadAllBytes($tempPath)
$searchPattern = @(0x48, 0x89, 0x5C, 0x24, 0x18, 0x57, 0x48, 0x83, 0xEC, 0x30, 0x48, 0x8D, 0x4C, 0x24, 0x48)
$replacementBytes = @(0x31, 0xC0, 0xC3)

$count = 0
$maxReplacements = 3

for ($i = 0; $i -le $bytes.Length - $searchPattern.Length -and $count -lt $maxReplacements; $i++) {
    $match = $true
    for ($j = 0; $j -lt $searchPattern.Length; $j++) {
        if ($bytes[$i + $j] -ne $searchPattern[$j]) {
            $match = $false
            break
        }
    }
    if ($match) {
        $bytes[$i] = $replacementBytes[0]
        $bytes[$i + 1] = $replacementBytes[1]
        $bytes[$i + 2] = $replacementBytes[2]
        $count++
        Write-Host "Replaced occurrence $count at offset: 0x$("{0:X}" -f $i)" -ForegroundColor Cyan
        $i += $searchPattern.Length - 1
    }
}

# Save patched temp file
[System.IO.File]::WriteAllBytes($tempPath, $bytes)
Write-Host "Patched temp file. Total replacements: $count" -ForegroundColor Green

# Rename original DLL (instead of deleting)
try {
    Rename-Item $dllPath $renamedPath -Force -ErrorAction Stop
    Write-Host "Renamed original DLL to .old" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Could not rename original DLL - still locked" -ForegroundColor Red
    Start-Process explorer.exe
    exit 1
}

# Copy patched temp file to original location
try {
    Copy-Item $tempPath $dllPath -Force -ErrorAction Stop
    Write-Host "Successfully copied patched DLL!" -ForegroundColor Green
    
    # Clean up
    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
    Remove-Item $renamedPath -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: Could not copy patched file" -ForegroundColor Red
    # Restore original if copy failed
    Rename-Item $renamedPath $dllPath -Force -ErrorAction SilentlyContinue
}

# Restart Explorer
Start-Sleep -Seconds 1
Start-Process explorer.exe
Write-Host "Done! Explorer restarted." -ForegroundColor Green
