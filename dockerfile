FROM python:3.11-slim

# .pyc (bytecode) cache off: Python compiles .py to .pyc in __pycache__/ to speed later runs.
# Disabling keeps containers clean and avoids extra file writes.
ENV PYTHONDONTWRITEBYTECODE=1
# Unbuffered logs: stdout (normal output) and stderr (errors) are written immediately (flush),
# so logs appear in Cloud Run/Build in real time.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
