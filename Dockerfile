#### build stage ##############################################################
FROM python:3.11-slim AS builder
WORKDIR /app

# leverage Poetry's export to lock deps without installing dev packages
COPY pyproject.toml poetry.lock* ./
RUN pip install --upgrade pip \
 && pip install --no-cache-dir poetry==1.8.2 \
 && poetry export -f requirements.txt --without-hashes --output requirements.txt

#### final stage ##############################################################
FROM python:3.11-slim
WORKDIR /app

# install runtime deps only
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

 # copy whole project & install it
 COPY . .
 RUN pip install --no-cache-dir -e .

# runtime user (non‑root)
RUN useradd -m -u 10001 pemuser
USER pemuser

EXPOSE 9000
ENTRYPOINT ["python", "-m", "public_endpoint_monitor.service"]
