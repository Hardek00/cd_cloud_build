from fastapi import FastAPI
import os

app = FastAPI()

###LOL###
@app.get("/")
def read_root():
    return {
        "method": "Cloud Build",
        "message": "Hello from Cloud Run via Cloud Build!",
        "framework": "FastAPI",
    }


@app.get("/healthz")
def read_healthz():
    return {"status": "ok"}


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    import uvicorn


    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=True)
