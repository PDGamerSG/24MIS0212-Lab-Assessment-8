# Student Feedback

Required source: index.html, Dockerfile, deployment.yaml, Jenkinsfile.
GitHub: https://github.com/PDGamerSG/24MIS0212-Lab-Assessment-8/tree/main/q2-student-feedback

Jenkins job: Assessment 8 Q2 Student Feedback
Pipeline from SCM path: q2-student-feedback/Jenkinsfile
Docker Hub image: pdgamersg/student-feedback
Deployment: feedback-deployment; replicas: 3
NodePort: http://localhost:30002

From the repository root, test manually in PowerShell:
```powershell
docker build -t pdgamersg/student-feedback:manual q2-student-feedback
powershell -NoProfile -ExecutionPolicy Bypass -File ci/Test-Container.ps1 -Image pdgamersg/student-feedback:manual -AppDirectory q2-student-feedback -Port 8102 -ContainerName assessment-q2-manual
```
This starts a real nginx container, checks HTTP content, and removes the test container.
To leave a container running for inspection:
```powershell
docker run -d --name assessment-q2-local --restart no -p 127.0.0.1:8102:80 pdgamersg/student-feedback:latest
```
The Jenkins pipeline builds, tests, logs into Docker Hub through credential dockerhub, pushes an immutable build tag, applies a rendered manifest using secret file kuberconfig, waits for rollout, verifies 3 Running/Ready Pods, and checks the live NodePort against index.html.

Verify Pods:
```powershell
kubectl --context docker-desktop get pods -l app=feedback-app
kubectl --context docker-desktop get deployment feedback-deployment
```

See ../evidence/RESULTS.md for actual builds and update demonstrations.

Feedback is stored only in this browser. index-v1.html is the initial version; index-v2.html demonstrates the rating summary and thank-you update.
