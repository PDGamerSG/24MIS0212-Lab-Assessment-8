param([Parameter(Mandatory=$true)][string]$Url,[Parameter(Mandatory=$true)][string]$AppDirectory)
$ErrorActionPreference = 'Stop'
$config = Get-Content (Join-Path $AppDirectory 'test-config.json') -Raw | ConvertFrom-Json
$html = (& curl.exe --ipv4 --noproxy '*' --fail --silent --show-error --max-time 20 $Url) -join "`n"
if ($LASTEXITCODE -ne 0) { throw "HTTP request failed: $Url" }
foreach ($token in $config.tokens) { if (!$html.Contains($token)) { throw "Missing required content: $token" } }
$expected = [IO.File]::ReadAllText((Join-Path $AppDirectory 'index.html')).Replace("`r`n","`n").Trim()
if ($html.Replace("`r`n","`n").Trim() -cne $expected) { throw 'Served page differs from the checked-out index.html' }
Write-Host "PASS: HTTP 200, required fields/content, and exact source match at $Url"
