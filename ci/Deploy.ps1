param([string]$Image,[string]$AppDirectory,[string]$Deployment,[string]$Label,[int]$Replicas,[int]$NodePort)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force evidence | Out-Null
$manifest = Get-Content -Raw (Join-Path $AppDirectory 'deployment.yaml')
$manifest = $manifest -replace 'image:\s*\S+', ('image: ' + $Image)
$output = Join-Path $pwd 'evidence/deployed.yaml'
[IO.File]::WriteAllText($output,$manifest,[Text.UTF8Encoding]::new($false))
& kubectl --context docker-desktop apply -f $output
if ($LASTEXITCODE -ne 0) { throw 'kubectl apply failed' }
& kubectl --context docker-desktop rollout status "deployment/$Deployment" --timeout=300s
if ($LASTEXITCODE -ne 0) { throw 'Rollout failed' }
$pods = (& kubectl --context docker-desktop get pods -l "app=$Label" -o json) -join "`n" | ConvertFrom-Json
$active = @($pods.items | Where-Object { !$_.metadata.deletionTimestamp })
if ($active.Count -ne $Replicas) { throw "Expected $Replicas active pods; got $($active.Count)" }
foreach ($pod in $active) {
 if ($pod.status.phase -ne 'Running' -or @($pod.status.containerStatuses | Where-Object { !$_.ready }).Count) { throw "Pod not Running/Ready: $($pod.metadata.name)" }
}
& kubectl --context docker-desktop get pods -l "app=$Label" -o wide | Tee-Object evidence/pods.txt
& kubectl --context docker-desktop get deployment $Deployment -o wide | Tee-Object evidence/deployment.txt
$proxyName = "$Deployment-nodeport"
$existing = & docker ps -a --filter "name=^/$proxyName$" --format '{{.Names}}'
if ($existing -eq $proxyName) { & docker start $proxyName }
else {
 $proxyCode = "const net=require('net');const port=Number(process.env.NODE_PORT);net.createServer(c=>{const u=net.connect(port,'desktop-control-plane');c.pipe(u).pipe(c);c.on('error',()=>u.destroy());u.on('error',()=>c.destroy());c.on('close',()=>u.destroy());}).listen(port,'0.0.0.0');"
 & docker run -d --name $proxyName --restart no --network kind -p "127.0.0.1:${NodePort}:${NodePort}" -e "NODE_PORT=$NodePort" node:22-alpine node -e $proxyCode
}
if ($LASTEXITCODE -ne 0) { throw 'NodePort localhost forwarder failed' }
for ($attempt=0; $attempt -lt 10; $attempt++) {
 try { & "$PSScriptRoot\Test-Page.ps1" -Url "http://localhost:$NodePort" -AppDirectory $AppDirectory; break }
 catch { if ($attempt -eq 9) { throw }; Start-Sleep -Seconds 2 }
}
& git rev-parse HEAD | Set-Content evidence/commit.txt
$Image | Set-Content evidence/image.txt
"http://localhost:$NodePort" | Set-Content evidence/url.txt
