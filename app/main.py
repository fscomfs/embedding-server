from typing import Union

import uvicorn
from fastapi import FastAPI, Response
from pydantic import BaseModel
from load_transformers import load_transformers

transformers = load_transformers()

app = FastAPI()


class EmbeddingRequest(BaseModel):
    input: Union[str, list]
    model: str


@app.get("/models")
async def models():
    models = []

    for model in transformers.keys():
        models.append({
            "id": model,
            "object": "model"
        })

    return {
        "data": models,
        "object": "list"
    }


@app.post("/embeddings")
async def embedding(req: EmbeddingRequest, res: Response):
    if not req.model in transformers:
        res.status_code = 400

        return {
            "message": "unknown model: " + req.model
        }

    embeddings = transformers[req.model].encode(req.input)

    data = []

    for embedding in embeddings.tolist():
        data.append({
            "object": "embedding",
            "embedding": embedding,
            "index": len(data)
        })

    return {
        "data": data,
        "model": req.model,
        "object": "list"
    }


@app.get("/health")
async def health(res: Response):
    return ""


if __name__ == '__main__':
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)
