import os
import sentence_transformers

def load_transformers(models = os.getenv("MODELS", "TencentBAC/Conan-embedding-v1")):
    transformers = {}

    for model in models.split(','):
        transformers['text-embedding-3-large'] = sentence_transformers.SentenceTransformer(model)
    return transformers