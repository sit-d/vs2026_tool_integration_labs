[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$examplesRoot = Join-Path $repoRoot "examples"
$tests = @(
    Get-ChildItem -Path $examplesRoot -Directory |
        Sort-Object -Property Name |
        ForEach-Object {
            $testPath = Join-Path $_.FullName "tests/validate.ps1"
            if (Test-Path -LiteralPath $testPath) {
                [System.IO.Path]::GetRelativePath($repoRoot, $testPath)
            }
            else {
                Write-Warning "Skipping $($_.Name): tests/validate.ps1 was not found."
            }
        }
)

if ($tests.Count -eq 0) {
    throw "No example validation scripts were found under $examplesRoot."
}

$failures = @()

foreach ($relativePath in $tests) {
    $testPath = Join-Path $repoRoot $relativePath
    Write-Host ""
    Write-Host "==> Running $relativePath" -ForegroundColor Cyan

    try {
        & $testPath
        Write-Host "PASS $relativePath" -ForegroundColor Green
    }
    catch {
        Write-Host "FAIL $relativePath" -ForegroundColor Red
        Write-Host $_
        $failures += $relativePath
    }
}

if ($failures.Count -gt 0) {
    throw ("Validation failed for: " + ($failures -join ", "))
}

Write-Host ""
Write-Host "All validations passed." -ForegroundColor Green
