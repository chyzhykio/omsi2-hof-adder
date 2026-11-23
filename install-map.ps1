param(
    [Parameter()]
    [string]$OMSI2Path = "C:\Program Files (x86)\Steam\steamapps\common\OMSI 2",

    [Parameter(Mandatory=$true)]
    [string]$MapSourcePath,

    [Parameter()]
    [switch]$Overwrite
)
$copied = 0
$replaced = 0
$identical = 0
$conflicts = 0
$failed = 0

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Get-MapFolders {
    param([string]$Root)

    $mapsPath = Join-Path $Root "maps"
    if (!(Test-Path -LiteralPath $mapsPath -PathType Container)) {
        return @()
    }
    return @(Get-ChildItem -LiteralPath $mapsPath -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "global.cfg") -PathType Leaf
    })
}

try {
    Write-ColorOutput "" -Color "White"
    Write-ColorOutput "OMSI 2 Map Installer" -Color "Cyan"
    Write-ColorOutput "" -Color "White"

    if (!(Test-Path -LiteralPath $OMSI2Path -PathType Container)) {
        Write-ColorOutput "ERROR: OMSI 2 path not found: $OMSI2Path" -Color "Red"
        Write-ColorOutput "Try to specify the correct path using -OMSI2Path parameter" -Color "Yellow"
        exit 1
    }

    if (!(Test-Path -LiteralPath (Join-Path $OMSI2Path "maps") -PathType Container)) {
        Write-ColorOutput "ERROR: This does not look like an OMSI 2 folder (no 'maps' directory): $OMSI2Path" -Color "Red"
        exit 1
    }

    if (!(Test-Path -LiteralPath $MapSourcePath -PathType Container)) {
        Write-ColorOutput "ERROR: Map source path not found: $MapSourcePath" -Color "Red"
        exit 1
    }

    $omsiRoot = (Resolve-Path -LiteralPath $OMSI2Path).ProviderPath.TrimEnd('\')
    $sourceRoot = (Resolve-Path -LiteralPath $MapSourcePath).ProviderPath.TrimEnd('\')

    if ($sourceRoot -ieq $omsiRoot) {
        Write-ColorOutput "ERROR: Map source path is the OMSI 2 folder itself" -Color "Red"
        exit 1
    }

    # Archives are often extracted with one extra wrapping folder
    $mapFolders = @(Get-MapFolders -Root $sourceRoot)
    if ($mapFolders.Count -eq 0) {
        $nested = @(Get-ChildItem -LiteralPath $sourceRoot -Directory | Where-Object {
            @(Get-MapFolders -Root $_.FullName).Count -gt 0
        })
        if ($nested.Count -eq 1) {
            $sourceRoot = $nested[0].FullName
            $mapFolders = @(Get-MapFolders -Root $sourceRoot)
        }
    }

    if ($mapFolders.Count -eq 0) {
        Write-ColorOutput "ERROR: No map found. Expected maps\<map name>\global.cfg in: $MapSourcePath" -Color "Red"
        exit 1
    }

    # Check write access up front instead of failing on every file
    $writeTest = Join-Path $omsiRoot ".install-map-write-test"
    try {
        [System.IO.File]::WriteAllText($writeTest, "")
        Remove-Item -LiteralPath $writeTest -Force
    } catch {
        Write-ColorOutput "ERROR: No write access to: $omsiRoot" -Color "Red"
        Write-ColorOutput "Try to run PowerShell as Administrator" -Color "Yellow"
        exit 1
    }

    Write-ColorOutput "Found $($mapFolders.Count) map(s) to install:" -Color "Green"
    foreach ($map in $mapFolders) {
        Write-ColorOutput "  - $($map.Name)" -Color "Gray"
    }
    Write-ColorOutput "" -Color "White"

    # Only folders are installed: loose files in the archive root are manuals and readmes
    $contentDirs = @(Get-ChildItem -LiteralPath $sourceRoot -Directory)
    $conflictList = New-Object System.Collections.Generic.List[string]

    foreach ($dir in $contentDirs) {
        Write-ColorOutput "Processing: $($dir.Name)" -Color "Cyan"

        $items = @(Get-ChildItem -LiteralPath $dir.FullName -Recurse -Force)
        $files = @($items | Where-Object { !$_.PSIsContainer })
        $index = 0

        [void][System.IO.Directory]::CreateDirectory((Join-Path $omsiRoot $dir.Name))
        foreach ($subDir in ($items | Where-Object { $_.PSIsContainer })) {
            $relative = $subDir.FullName.Substring($sourceRoot.Length + 1)
            [void][System.IO.Directory]::CreateDirectory((Join-Path $omsiRoot $relative))
        }

        foreach ($file in $files) {
            $index++
            if ($index % 50 -eq 0) {
                Write-Progress -Activity "Installing $($dir.Name)" -Status "$index / $($files.Count)" -PercentComplete (100 * $index / $files.Count)
            }

            $relative = $file.FullName.Substring($sourceRoot.Length + 1)
            $destPath = Join-Path $omsiRoot $relative

            try {
                $exists = Test-Path -LiteralPath $destPath -PathType Leaf
                if ($exists) {
                    $existing = Get-Item -LiteralPath $destPath -Force
                    if ($existing.Length -eq $file.Length -and $existing.LastWriteTimeUtc -eq $file.LastWriteTimeUtc) {
                        $identical++
                        continue
                    }
                    if (!$Overwrite) {
                        $conflicts++
                        $conflictList.Add($relative)
                        continue
                    }
                }

                Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force -ErrorAction Stop
                if ($exists) { $replaced++ } else { $copied++ }
            } catch {
                Write-ColorOutput "    ERROR: $relative - $($_.Exception.Message)" -Color "Red"
                $failed++
            }
        }

        Write-Progress -Activity "Installing $($dir.Name)" -Completed
        Write-ColorOutput "    Processed $($files.Count) file(s)" -Color "Green"
    }
    Write-ColorOutput "" -Color "White"

    if ($conflicts -gt 0) {
        Write-ColorOutput "Kept your existing version of $conflicts file(s) that differ from the map:" -Color "Yellow"
        foreach ($path in ($conflictList | Select-Object -First 10)) {
            Write-ColorOutput "  - $path" -Color "Gray"
        }
        if ($conflicts -gt 10) {
            Write-ColorOutput "  ... and $($conflicts - 10) more" -Color "Gray"
        }
        Write-ColorOutput "Run again with -Overwrite to replace them (this may affect other maps)" -Color "Yellow"
        Write-ColorOutput "" -Color "White"
    }

    Write-ColorOutput "Summary:" -Color "Cyan"
    Write-ColorOutput "  Copied: $copied" -Color "Green"
    if ($replaced -gt 0) {
        Write-ColorOutput "  Replaced: $replaced" -Color "Yellow"
    }
    Write-ColorOutput "  Already installed: $identical" -Color "White"
    if ($conflicts -gt 0) {
        Write-ColorOutput "  Kept existing: $conflicts" -Color "Yellow"
    }
    if ($failed -gt 0) {
        Write-ColorOutput "  Failed: $failed" -Color "Red"
    }
    Write-ColorOutput "" -Color "White"

    if ($failed -gt 0) {
        exit 1
    }
}
catch {
    Write-ColorOutput "" -Color "White"
    Write-ColorOutput "EXEC ERROR: $($_.Exception.Message)" -Color "Red"
    Write-ColorOutput "" -Color "White"
    exit 1
}
