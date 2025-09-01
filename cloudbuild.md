Image name and tag
fastapi-demo: the image name (can be any valid name). Full image format is HOST/PROJECT/REPOSITORY/IMAGE:TAG.
:TAG: everything after : is the tag. If omitted, defaults to latest.
What $SHORT_SHA is
$SHORT_SHA: Cloud Build built‑in variable that resolves to the short Git commit SHA (first 7 characters) of the commit that triggered the build.
Why use it: gives each build a unique, traceable tag per commit (easy rollbacks/audits).
Example resolved name: europe-north2-docker.pkg.dev/my-project/de-pipeline/fastapi-demo:abc1234.
If you prefer, you can replace $SHORT_SHA with a fixed tag (e.g., v1.0.0) or another built‑in like $BUILD_ID.