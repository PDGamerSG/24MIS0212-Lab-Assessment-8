# Assessment 8 — Docker, Jenkins and Kubernetes

Repository: https://github.com/PDGamerSG/24MIS0212-Lab-Assessment-8

| Question           | Code                | Replicas | Local container test  | Kubernetes NodePort    |
| ------------------ | ------------------- | -------: | --------------------- | ---------------------- |
| 1 Notice board     | q1-notice-board     |        2 | http://localhost:8101 | http://localhost:30001 |
| 2 Student feedback | q2-student-feedback |        3 | http://localhost:8102 | http://localhost:30002 |
| 3 Placement portal | q3-placement-portal |        3 | http://localhost:8103 | http://localhost:30003 |

The three folders are projects inside this Git repository. Each contains index.html, Dockerfile, deployment.yaml, Jenkinsfile, test-config.json and README.md. Unused root demo files have been removed.

## Jenkins setup

Jenkins: http://localhost:8085
The configured jobs use Pipeline scripts from the project's Jenkinsfile, with an explicit GitHub clone stage.
For another Jenkins installation, either copy the project's Jenkinsfile into a Pipeline job or use Pipeline from SCM with this repository, branch main, and the project's Jenkinsfile path.
The existing "k8s test" job runs all three question jobs using the root Jenkinsfile.
Existing credential IDs:

- dockerhub: Docker Hub username/password; username pdgamersg, password a read/write access token.
- kuberconfig: secret file, Docker Desktop kubeconfig. Never commit this file.

These pipelines run on this Windows Jenkins machine. Docker Desktop must be running with Kubernetes enabled. They build versioned images using the build number, start a temporary container, check nginx and HTTP content against the Git source, push both the version and latest tag, deploy, wait for rollout, check every Pod, and verify the NodePort webpage. Docker login uses password-stdin. Credentials are isolated per build and removed afterward.

Docker Desktop uses a kind cluster on this machine. Small TCP-forwarding containers expose its real NodePorts on Windows localhost. They do not serve the HTML themselves. Their restart policy is no, as requested. Kubernetes system containers are managed by Docker Desktop.

## Tests

Run: python ci/test_source.py
Each Jenkins job runs ci/Test-Container.ps1 and ci/Test-Page.ps1, then ci/Deploy.ps1 checks replica counts and Running/Ready Pods. Browser checks and actual build/deployment results are saved in evidence/RESULTS.md.

Browser tests: python ci/Test-Browser.py --question 1 --version final (repeat with questions 2 and 3).
They check both desktop and mobile layouts; Q2 also checks validation, saving, rating calculation and persistence.
These tests use Playwright: pip install playwright, then python -m playwright install chromium.
Generated logs and screenshots remain in this folder and are excluded from Git; the two initial HTML pages in evidence/before are tracked for the update demonstration.

## Updates

Q2: the deployed index.html adds a computed course rating summary and a thank-you message. Feedback stays in browser localStorage.
Q3: the deployed index.html adds Google. Q3 polls GitHub every two minutes to detect pushed changes.
Initial versions are retained only in evidence/before/ to demonstrate the required updates.

All notices, companies and contact details are academic sample data. These static apps do not send feedback to a backend or submit real job applications.
