Cloud Build: what it is and how this repo uses it

What Cloud Build is
- Fully managed CI/CD service in Google Cloud that runs containerized build steps.
- You define a build as a sequence of steps in `cloudbuild.yaml`.
- Common use cases: building container images, running tests, deploying to Cloud Run/GKE, etc.

Core concepts
- Trigger: connects a repo event (e.g., GitHub push) to a build config (`cloudbuild.yaml`).
- Build: an execution of the steps with a specific source (commit) and options.
- Step: a container image plus arguments; steps run sequentially by default.
- Substitutions: variables available at build time. Built‑ins: `$PROJECT_ID`, `$SHORT_SHA`, `$BUILD_ID`. Custom ones start with `_`.
- Service account: identity the build uses to access GCP (IAM roles determine permissions).
- Logs: stored in Cloud Logging by default; can be redirected to a bucket.

Image naming refresher (from your notes)
- Full form: `HOST/PROJECT/REPOSITORY/IMAGE:TAG`.
- Example: `europe-north2-docker.pkg.dev/my-project/de-pipeline/fastapi-demo:abc1234`.
- `fastapi-demo`: image name; can be any valid name.
- `:TAG`: if omitted, defaults to `latest`; we use `$SHORT_SHA` to make tags unique per commit.

What `$SHORT_SHA` is (from your notes)
- Short Git commit SHA (first 7 chars) of the triggering commit.
- Why use it: traceability, deterministic rollback to any prior commit.

How this repo's `cloudbuild.yaml` is constructed
- Step 1 (docker build): uses `gcr.io/cloud-builders/docker` to build an image from `dockerfile` and tags it as
  `europe-north2-docker.pkg.dev/$PROJECT_ID/de-pipeline/fastapi-demo:${SHORT_SHA}`.
- Step 2 (docker push): pushes the image to Artifact Registry (`de-pipeline` in region `europe-north2`).
- Step 3 (deploy): uses the Cloud SDK image to run `gcloud run deploy fastapi-demo` with the pushed image in region `europe-north2`, allowing unauthenticated access.
- Images section: declares the produced image so Cloud Build tracks it in the build results.
- Options: `logging: CLOUD_LOGGING_ONLY` ensures builds run with a custom service account without requiring a GCS logs bucket.

Why regional names matter
- Artifact Registry host encodes region or multi‑region (e.g., `europe-north2-docker.pkg.dev`).
- Cloud Run services are deployed to a single region; we use `europe-north2`.
- Your AR repository must exist in the same region you reference in tags.

IAM permissions required for the build’s service account
- Cloud Run Admin (`roles/run.admin`) – deploy services.
- Artifact Registry Writer (`roles/artifactregistry.writer`) – push images.
- Service Account User (`roles/iam.serviceAccountUser`) – to act as the Cloud Run runtime SA (often the compute default).
- (Optional) Cloud Build Service Account (`roles/cloudbuild.builds.builder`) if you use a dedicated SA for triggers.

Typical execution flow for this repo
1. Push to `main` on GitHub.
2. Cloud Build Trigger fires with source at that commit.
3. Step 1 builds the Docker image from `dockerfile`.
4. Step 2 pushes image to `de-pipeline` in `europe-north2` with tag `${SHORT_SHA}`.
5. Step 3 deploys `fastapi-demo` to Cloud Run in `europe-north2` using that image.
6. Cloud Run serves `/` and `/healthz`. FastAPI docs at `/docs`.

Troubleshooting quick hits
- 404 on routes: confirm latest revision and image tag in Cloud Run matches last build; redeploy if needed.
- Permission denied pushing image: ensure AR Writer role on the build SA and repo exists in `europe-north2`.
- Trigger fails with logs bucket error: either set `options.logging: CLOUD_LOGGING_ONLY` (as we did) or configure a logs bucket.

Variations you can try later
- Use substitutions to make region/repo/service configurable.
- Add a test step (e.g., `pytest`) before deploy.
- Promote images to `:prod` by adding an extra tag after successful deploy.