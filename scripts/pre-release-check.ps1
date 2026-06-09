param(
    [switch]$FullSmoke
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Invoke-CheckedCommand {
    param(
        [string]$WorkingDirectory,
        [string]$Command,
        [string[]]$Arguments
    )

    Push-Location $WorkingDirectory
    try {
        & $Command @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "$Command $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}

function Test-RequiredPath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required path not found: $Path"
    }
}

function New-StringFromCodePoints {
    param([int[]]$CodePoints)

    return -join ($CodePoints | ForEach-Object { [char]$_ })
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$vueDir = Join-Path $repoRoot "vue"
$javaDir = Join-Path $repoRoot "java"
$miniappDir = Join-Path $repoRoot "miniapp"
$docsDir = Join-Path $repoRoot "docs"
$developmentDocName = (New-StringFromCodePoints @(0x5F00, 0x53D1, 0x6587, 0x6863)) + ".md"
$deliveryListName = (New-StringFromCodePoints @(0x53D1, 0x5E03, 0x524D, 0x4EA4, 0x4ED8, 0x6E05, 0x5355)) + ".md"

Write-Step "Checking release inputs"
$requiredPaths = @(
    (Join-Path $vueDir "package-lock.json"),
    (Join-Path $vueDir "src"),
    (Join-Path $javaDir "pom.xml"),
    (Join-Path $javaDir "src\main"),
    (Join-Path $miniappDir "project.config.json"),
    (Join-Path $miniappDir "app.json"),
    (Join-Path $docsDir $developmentDocName),
    (Join-Path $docsDir $deliveryListName),
    (Join-Path $repoRoot "canteen_recommendation.sql")
)

foreach ($path in $requiredPaths) {
    Test-RequiredPath $path
}

Write-Step "Building Web package"
Invoke-CheckedCommand -WorkingDirectory $vueDir -Command "npm" -Arguments @("run", "build")
Test-RequiredPath (Join-Path $vueDir "dist\index.html")

Write-Step "Building backend package"
Invoke-CheckedCommand -WorkingDirectory $javaDir -Command "mvn" -Arguments @("-q", "-DskipTests", "package")
$backendJar = Get-ChildItem -LiteralPath (Join-Path $javaDir "target") -Filter "*.jar" |
    Where-Object { $_.Name -notlike "*.original" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $backendJar) {
    throw "Backend jar was not generated under java\target"
}

Write-Step "Checking Mini Program package inputs"
$miniappRequired = @(
    "pages\index\index.js",
    "pages\dishes\dishes.js",
    "pages\cart\cart.js",
    "pages\orders\orders.js",
    "pages\profile\profile.js",
    "utils\request.js"
)

foreach ($relativePath in $miniappRequired) {
    Test-RequiredPath (Join-Path $miniappDir $relativePath)
}

if ($FullSmoke) {
    Write-Step "Running Web smoke"
    Invoke-CheckedCommand -WorkingDirectory $vueDir -Command "npm" -Arguments @("run", "smoke:web")

    Write-Step "Running backend core smoke"
    Invoke-CheckedCommand -WorkingDirectory $javaDir -Command "mvn" -Arguments @("-q", "-Dtest=BackendCoreSmokeTest", "test")
}
else {
    Write-Step "Skipping smoke checks"
    Write-Host "Run scripts\pre-release-check.ps1 -FullSmoke to include Web and backend smoke checks."
}

Write-Step "Release package summary"
Write-Host "Web package:     vue\dist\index.html"
Write-Host "Backend package: $($backendJar.FullName.Replace($repoRoot + '\', ''))"
Write-Host "Miniapp project: miniapp\project.config.json"
Write-Host "Delivery list:   docs\$deliveryListName"
Write-Host ""
Write-Host "Pre-release check passed." -ForegroundColor Green
