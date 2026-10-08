# College Notice Board

Required source: index.html, Dockerfile, deployment.yaml, Jenkinsfile.
GitHub: https://github.com/PDGamerSG/24MIS0212-Lab-Assessment-8/tree/main/q1-notice-board

Jenkins job: Assessment 8 Q1 Notice Board
Pipeline from SCM path: q1-notice-board/Jenkinsfile
Docker Hub image: pdgamersg/noticeboard-app
Deployment: noticeboard-deployment; replicas: 2
NodePort: http://localhost:30001

From the repository root, test manually in PowerShell:
```powershell
docker build -t pdgamersg/noticeboard-app:manual q1-notice-board
powershell -NoProfile -ExecutionPolicy Bypass -File ci/Test-Container.ps1 -Image pdgamersg/noticeboard-app:manual -AppDirectory q1-notice-board -Port 8101 -ContainerName assessment-q1-manual
```
This starts a real nginx container, checks HTTP content, and removes the test container.
To leave a container running for inspection:
```powershell
docker run -d --name assessment-q1-local --restart no -p 127.0.0.1:8101:80 pdgamersg/noticeboard-app:latest
```
The Jenkins pipeline builds, tests, logs into Docker Hub through credential dockerhub, pushes an immutable build tag, applies a rendered manifest using secret file kuberconfig, waits for rollout, verifies 2 Running/Ready Pods, and checks the live NodePort against index.html.

Verify Pods:
```powershell
kubectl --context docker-desktop get pods -l app=noticeboard
kubectl --context docker-desktop get deployment noticeboard-deployment
```

See ../evidence/RESULTS.md for actual builds and update demonstrations.
