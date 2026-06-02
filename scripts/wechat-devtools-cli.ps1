param(
  [ValidateSet("open", "preview", "upload", "build-npm", "islogin", "login", "auto", "auto-preview", "close", "quit", "help")]
  [string]$Command = "open",
  [ValidateSet("", "open", "preview", "upload", "build-npm", "islogin", "login", "auto", "auto-preview", "close", "quit", "help")]
  [string]$Action = "",
  [string]$Project = "miniapp",
  [int]$Port = 0,
  [int]$TimeoutSeconds = 45,
  [switch]$Detached,
  [switch]$PrintCommand,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedCommand = if ([string]::IsNullOrWhiteSpace($Action)) { $Command } else { $Action }

function Resolve-WeChatDevToolsCli {
  $candidates = @(
    $env:WECHAT_DEVTOOLS_CLI,
    [Environment]::GetEnvironmentVariable("WECHAT_DEVTOOLS_CLI", "User"),
    [Environment]::GetEnvironmentVariable("WECHAT_DEVTOOLS_CLI", "Machine"),
    "C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat",
    "C:\Program Files\Tencent\微信web开发者工具\cli.bat",
    (Join-Path $env:LOCALAPPDATA "微信开发者工具\cli.bat"),
    (Join-Path $env:LOCALAPPDATA "Tencent\微信开发者工具\cli.bat"),
    (Join-Path $env:APPDATA "Tencent\微信开发者工具\cli.bat")
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  throw @"
WeChat DevTools CLI was not found.
Set WECHAT_DEVTOOLS_CLI to the full cli.bat path, for example:
  [Environment]::SetEnvironmentVariable('WECHAT_DEVTOOLS_CLI', 'C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat', 'User')
"@
}

$cli = Resolve-WeChatDevToolsCli
$cliDir = Split-Path -Parent $cli
$node = Join-Path $cliDir "node.exe"
$cliJs = Join-Path $cliDir "cli.js"

$argsList = @()
if ($resolvedCommand -eq "help") {
  $argsList += "--help"
} else {
  $argsList += $resolvedCommand
}
$projectCommands = @("open", "preview", "upload", "build-npm", "auto", "auto-preview", "close")

if ($projectCommands -contains $resolvedCommand) {
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

function Quote-CommandArgument([string]$Value) {
  if ($null -eq $Value) {
    return '""'
  }

  return '"' + ($Value -replace '"', '\"') + '"'
}

$processInfo = New-Object System.Diagnostics.ProcessStartInfo

if ((Test-Path -LiteralPath $node) -and (Test-Path -LiteralPath $cliJs)) {
  $quotedArgs = @($argsList | ForEach-Object { Quote-CommandArgument $_ })
  $processInfo.FileName = $node
  $processInfo.Arguments = "$(Quote-CommandArgument $cliJs) $($quotedArgs -join ' ')"
} else {
  $quotedArgs = @($argsList | ForEach-Object { Quote-CommandArgument $_ })
  $commandLine = "call $(Quote-CommandArgument $cli) $($quotedArgs -join ' ')"
  $processInfo.FileName = "cmd.exe"
  $processInfo.Arguments = "/c $commandLine"
}

if ($PrintCommand) {
  Write-Output "CLI: $cli"
  Write-Output "Command: $resolvedCommand"
  Write-Output "FileName: $($processInfo.FileName)"
  Write-Output "Arguments: $($processInfo.Arguments)"
  exit 0
}
$processInfo.UseShellExecute = $false
$processInfo.RedirectStandardOutput = $true
$processInfo.RedirectStandardError = $true
$processInfo.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processInfo
[void]$process.Start()

if (-not $process.WaitForExit([Math]::Max(1, $TimeoutSeconds) * 1000)) {
  try {
    $process.Kill()
  } catch {
    # The CLI may already have handed off to the IDE process.
  }

  throw @"
WeChat DevTools CLI timed out after $TimeoutSeconds seconds.
CLI path: $cli
Command: $($argsList -join ' ')
If commands other than help hang, open 微信开发者工具 and enable Settings > Security > Service Port, then retry with -Port 9420.
"@
}

$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()

if (-not [string]::IsNullOrWhiteSpace($stdout)) {
  Write-Output $stdout.TrimEnd()
}

if (-not [string]::IsNullOrWhiteSpace($stderr)) {
  Write-Error $stderr.TrimEnd()
}

exit $process.ExitCode
