# Public Endpoint monitor

Availability & latency monitoring for third‑party services  
*(built as a DevOps portfolio project)*

[![CI](https://github.com/stokesy56/public-endpoint-monitor/actions/workflows/ci.yml/badge.svg)](https://github.com/stokesy56/public-endpoint-monitor/actions/workflows/ci.yml)

## Quick start (local)

```bash
git clone https://github.com/stokesy56/public-endpoint-monitor.git
cd public-endpoint-monitor
poetry install          # set up virtual env
poetry run pytest -q    # run unit tests
```

### Docker

```bash
make docker-build
make docker-run     # exposes metrics at http://localhost:9000/metrics

## Probe in Action

```bash
	poetry run python -m public_endpoint_monitor.probe https://www.google.com
```
Outputs:
```ini
target=https://www.google.com success=True latency=0.141s
```
**Note:** `	poetry run python -m public_endpoint_monitor.probe` would run using https://www.google.com by default

## Local Kubernetes quick‑start (kind)

> Requires Docker/Podman and Go 1.20+ (for the kind binary).

```bash
# 1  Install kind v0.29.0
GO111MODULE=on go install sigs.k8s.io/kind@v0.29.0
export PATH="$PATH:$(go env GOPATH)/bin"

# 2  Create a Kubernetes v1.33 cluster
kind create cluster --name pem-dev \
  --image kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f

# 3  Build the image & load it into the cluster
make docker-build
kind load docker-image public-endpoint-monitor:dev --name pem-dev

# 4  Deploy manifests
kubectl create ns pem
kubectl apply -f k8s/

# 5  Port‑forward /metrics
kubectl port-forward svc/pem-metrics -n pem 9000:9000
curl http://localhost:9000/metrics | grep ^pem_

# 6  Tear down when finished
kind delete cluster --name pem-dev
```

You should see logs every 30s:
```
2025-07-18T13:24:05Z INFO Serving /metrics on :9000; probing https://www.google.com every 30s
2025-07-18T13:24:05Z INFO target=https://www.google.com success=True latency=0.12s

```

### make workflow
```ini
make kind-up          # one‑shot cluster + image load
make k8s-apply        # apply manifests
make k8s-port         # background port-forward
curl localhost:9000/metrics | grep ^pem_ # separate terminal - displays metrics
make kind-down        # cleanup when done
```