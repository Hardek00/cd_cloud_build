FastAPI on Cloud Run via GitHub → Cloud Build (GUI guide)

Prereqs
- GCP project (Owner or Project Editor)
- Billing enabled
- GitHub repo connected to your account

1) Enable APIs (Console UI)
- Go to: Console → Navigation menu → APIs & Services → Library
- Enable: Cloud Build API, Cloud Run Admin API, Artifact Registry API, Service Usage API, IAM API

2) Create Artifact Registry repository (for images)
- Console → Navigation menu → Artifact Registry → Repositories → Create
  - Name: cloud-run (or your choice)
  - Format: Docker
  - Location type: Region
  - Region: us-central1 (or your choice; keep consistent)
  - Click Create

3) Grant Cloud Build permissions (one-time)
- Console → IAM & Admin → IAM
- Find principal: PROJECT_NUMBER@cloudbuild.gserviceaccount.com
- Grant roles:
  - Cloud Run Admin
  - Service Account User
  - Artifact Registry Writer

4) Connect GitHub repo and create trigger
- Console → Cloud Build → Triggers → Connect repository
  - Choose GitHub (Cloud Build GitHub App), authorize, select this repo
- Click Create trigger
  - Name: cloud-run-deploy
  - Event: Push to a branch
  - Branch: ^main$ (or your branch)
  - Configuration: cloudbuild.yaml
  - Create

5) First-time run (optional from UI)
- In Triggers, click cloud-run-deploy → Run → choose latest commit
- Watch Logs → ensure all steps succeed

6) Verify deployment
- Console → Cloud Run → Service fastapi-demo in europe-north2
- Click the URL → you should see JSON response
- Health endpoint: append /healthz → {"status":"ok"}

7) Subsequent deployments
- Push commits to the configured branch
- Cloud Build will build, push, and deploy automatically

Local development (optional)
- Python 3.11+
- In repo root:
  - pip install -r requirements.txt
  - python app.py
  - Visit http://localhost:8080/

Notes
- Dockerfile name is `dockerfile` (lowercase); build step points to it via -f
- cloudbuild.yaml is hardcoded to region `europe-north2`, repository `de-pipeline`, service `fastapi-demo`
