import os
import sentence_transformers


def load_transformers(models=os.getenv("MODELS", "TencentBAC/Conan-embedding-v1")):
    transformers = {}
    cuda_device = os.getenv("NVIDIA_VISIBLE_DEVICES", '')
    device = 'cpu'
    if cuda_device != '':
        device = 'cuda'
    for model in models.split(','):
        transformers['text-embedding-3-large'] = sentence_transformers.SentenceTransformer(model_name_or_path=model,
                                                                                           device=device)
    return transformers
