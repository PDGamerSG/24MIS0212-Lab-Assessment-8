param([string]$Image,[string]$AppDirectory,[int]$Port,[string]$ContainerName)
$ErrorActionPreference = 'Stop'
try {
 & docker run -d --name $ContainerName --restart no -p "127.0.0.1:${Port}:80" $Image
 if ($LASTEXITCODE -ne 0) { throw 'Container could not start' }
 & docker exec $ContainerName nginx -t
 if ($LASTEXITCODE -ne 0) { throw 'nginx configuration failed' }
 $passed = $false
 for ($attempt=0; $attempt -lt 10; $attempt++) {
  try { & "$PSScriptRoot\Test-Page.ps1" -Url "http://localhost:$Port" -AppDirectory $AppDirectory; $passed=$true; break }
  catch { Start-Sleep -Seconds 2 }
 }
 if (!$passed) { throw 'Local container HTTP/source test failed' }
} finally { & docker rm -f $ContainerName | Out-Null }
