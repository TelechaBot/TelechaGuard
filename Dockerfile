# Build stage
FROM python:3.9-buster as builder

RUN apt update && \
    apt install -y build-essential && \
    pip install -U pip setuptools wheel && \
    pip install pdm

COPY pyproject.toml pdm.lock README.md /project/
WORKDIR /project
RUN pdm sync -G bot --prod --no-editable

# Runtime stage
FROM python:3.9-slim-buster as runtime

RUN apt update && \
    apt install -y npm && \
    npm install pm2 -g && \
    apt install -y ffmpeg && \
    pip install pdm

VOLUME ["/rabbitmq", "/run.log", "/conf_dir"]

WORKDIR /app
COPY --from=builder /project/.venv /app/.venv

COPY pm2.json ./
COPY config_dir ./config_dir
COPY . /app

CMD [ "pm2-runtime", "pm2.json" ]
