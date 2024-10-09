FROM python:3.10 AS base

#
# builder
#
FROM base AS builder

ENV \
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  PATH="$PATH:/runtime/bin" \
  PYTHONPATH="$PYTHONPATH:/runtime/lib/python3.10/site-packages" \
  POETRY_VERSION=1.3.2

RUN pip install "poetry~=$POETRY_VERSION"

WORKDIR /src
ARG https_proxy
ENV https_proxy=${https_proxy}
COPY pyproject.toml poetry.lock /src/
RUN poetry export --dev --without-hashes --no-interaction --no-ansi -f requirements.txt -o requirements.txt
RUN pip install --prefix=/runtime --force-reinstall -r requirements.txt

COPY . /src

#
# output
#

FROM base as model
ENV \
  MODELS="thenlper/gte-large"

COPY --from=builder /runtime /usr/local

COPY /app/install.py /app/install.py
COPY /app/load_transformers.py /app/load_transformers.py

WORKDIR /app
ENV https_proxy=''
ENV HF_ENDPOINT='https://hf-mirror.com'
RUN python install.py && \
  find /root/.cache/torch/sentence_transformers/ -name onnx -exec rm -rf {} +




FROM base

ENV \
  MODELS="thenlper/gte-large"

COPY --from=builder /runtime /usr/local

COPY --from=model  /root/.cache/torch  /root/.cache/torch

COPY /app /app
WORKDIR /app
ENV https_proxy=''
ENV HF_ENDPOINT='https://hf-mirror.com'

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
