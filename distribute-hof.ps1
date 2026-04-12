param(
    [Parameter()]
    [string]$OMSI2Path = "C:\Program Files (x86)\Steam\steamapps\common\OMSI 2",
    
    [Parameter(Mandatory=$true)]
    [string]$HOFSourcePath
)
$processed = 0
$failed = 0

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

try {
    Write-ColorOutput "" -Color "White"
    Write-ColorOutput "OMSI 2 HOF File Distribution Script" -Color "Cyan"
    Write-ColorOutput "" -Color "White"
    
    if (!(Test-Path $OMSI2Path)) {
        Write-ColorOutput "ERROR: OMSI 2 path not found: $OMSI2Path" -Color "Red"
        Write-ColorOutput "Try to specify the correct path using -OMSI2Path parameter" -Color "Yellow"
        exit 1
    }
    
    if (!(Test-Path $HOFSourcePath)) {
        Write-ColorOutput "ERROR: HOF source path not found: $HOFSourcePath" -Color "Red"
        exit 1
    }
    
    $hofFiles = Get-ChildItem -Path $HOFSourcePath -Filter "*.hof" -Recurse
    
    if ($hofFiles.Count -eq 0) {
        Write-ColorOutput "ERROR: No HOF files found in: $HOFSourcePath" -Color "Red"
        exit 1
    }
    
    Write-ColorOutput "Found $($hofFiles.Count) HOF file(s) to distribute:" -Color "Green"
    foreach ($hof in $hofFiles) {
        Write-ColorOutput "  - $($hof.Name)" -Color "Gray"
    }
    Write-ColorOutput "" -Color "White"
    
    $vehiclesPath = Join-Path $OMSI2Path "Vehicles"
    if (!(Test-Path $vehiclesPath)) {
        Write-ColorOutput "ERROR: Vehicles directory not found: $vehiclesPath" -Color "Red"
        exit 1
    }
    $vehicleDirs = Get-ChildItem -Path $vehiclesPath -Directory
    
    Write-ColorOutput "Found $($vehicleDirs.Count) vehicle(s) installed" -Color "Green"
    Write-ColorOutput "" -Color "White"
    
    foreach ($vehicle in $vehicleDirs) {
        Write-ColorOutput "Processing: $($vehicle.Name)" -Color "Cyan"
        
        try {
            $copiedCount = 0
            foreach ($hofFile in $hofFiles) {
                $destPath = Join-Path $vehicle.FullName $hofFile.Name
                Copy-Item -Path $hofFile.FullName -Destination $destPath -Force
                $copiedCount++
            }
            
            Write-ColorOutput "    Copied $copiedCount HOF file(s)" -Color "Green"
            $processed++
            
        } catch {
            Write-ColorOutput "    ERROR: $($_.Exception.Message)" -Color "Red"
            $failed++
        }
        
        Write-ColorOutput "" -Color "White"
    }
    
    Write-ColorOutput "Summary:" -Color "Cyan"
    Write-ColorOutput "  Total vehicles: $($vehicleDirs.Count)" -Color "White"
    Write-ColorOutput "  Processed: $processed" -Color "Green"
    if ($failed -gt 0) {
        Write-ColorOutput "  Failed: $failed" -Color "Red"
    }
    Write-ColorOutput "" -Color "White"
}
catch {
    Write-ColorOutput "" -Color "White"
    Write-ColorOutput "EXEC ERROR: $($_.Exception.Message)" -Color "Red"
    Write-ColorOutput "" -Color "White"
    exit 1
}
