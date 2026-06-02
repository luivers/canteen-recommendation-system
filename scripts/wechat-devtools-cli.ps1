param(
  [ValidateSet("open", "preview", "upload", "build-npm", "islogin", "login", "auto", "close", "quit")]
  [string]$Command = "open",
  [string]$Project = "miniapp",
  [int]$Port = 0,
  [switch]$Detached,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$defaultCli = "C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat"
$cli = $env:WECHAT_DEVTOOLS_CLI

if ([string]::IsNullOrWhiteSpace($cli)) {
  $cli = [Environment]::GetEnvironmentVariable("WECHAT_DEVTOOLS_CLI", "User")
}

if ([string]::IsNullOrWhiteSpace($cli)) {
  $cli = $defaultCli
}

if (-not (Test-Path -LiteralPath $cli)) {
  throw "WeChat DevTools CLI was not found. Set WECHAT_DEVTOOLS_CLI to cli.bat path."
}

$argsList = @($Command)
$projectCommands = @("open", "preview", "upload", "build-npm", "auto", "close")

if ($projectCommands -contains $Command) {
  $projectPath = Resolve-Path -LiteralPath (Join-Path $repoRoot $Project)
  $argsList += @("--project", $projectPath.Path)
}

if ($Port -gt 0) {
  $argsList += @("--port", $Port)
}

if ($ExtraArgs) {
  $argsList += $ExtraArgs
}

if ($Detached) {
  Start-Process -FilePath $cli -ArgumentList $argsList -WindowStyle Hidden
  exit 0
}

& $cli @argsList
exit $LASTEXITCODE
