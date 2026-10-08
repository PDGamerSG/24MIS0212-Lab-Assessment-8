# College Placement Portal

Required source: index.html, Dockerfile, deployment.yaml, Jenkinsfile.
GitHub: https://github.com/PDGamerSG/24MIS0212-Lab-Assessment-8/tree/main/q3-placement-portal

Jenkins job: Assessment 8 Q3 Placement Portal
Pipeline from SCM path: q3-placement-portal/Jenkinsfile
Docker Hub image: pdgamersg/placement-portal
Deployment: placement-deployment; replicas: 3
NodePort: http://localhost:30003

From the repository root, test manually in PowerShell:
```powershell
docker build -t pdgamersg/placement-portal:manual q3-placement-portal
powershell -NoProfile -ExecutionPolicy Bypass -File ci/Test-Container.ps1 -Image pdgamersg/placement-portal:manual -AppDirectory q3-placement-portal -Port 8103 -ContainerName assessment-q3-manual
```
This starts a real nginx container, checks HTTP content, and removes the test container.
To leave a container running for inspection:
```powershell
docker run -d --name assessment-q3-local --restart no -p 127.0.0.1:8103:80 pdgamersg/placement-portal:latest
```
The Jenkins pipeline builds, tests, logs into Docker Hub through credential dockerhub, pushes an immutable build tag, applies a rendered manifest using secret file kuberconfig, waits for rollout, verifies 3 Running/Ready Pods, and checks the live NodePort against index.html.

Verify Pods:
```powershell
kubectl --context docker-desktop get pods -l app=placement-portal
kubectl --context docker-desktop get deployment placement-deployment
```

See ../evidence/RESULTS.md for actual builds and update demonstrations.

index-v1.html preserves the initial two-company version. index-updated.html adds Google. The Jenkins job polls GitHub and deploys changed code automatically.
