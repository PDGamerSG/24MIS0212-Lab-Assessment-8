$ErrorActionPreference = 'Stop'
if (Test-Path -LiteralPath $env:DOCKER_CONFIG) {
 $target = [IO.Path]::GetFullPath($env:DOCKER_CONFIG)
 $allowed = [IO.Path]::GetFullPath($env:WORKSPACE).TrimEnd('\') + '\'
 if (!$target.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Docker credential cleanup path is outside workspace' }
 Remove-Item -LiteralPath $target -Recurse -Force
}
