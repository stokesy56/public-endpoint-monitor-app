# Public Endpoint Manager

Availability & latency monitoring for third‑party services  
*(built as a DevOps portfolio project)*

[![CI](https://github.com/stokesy56/public-endpoint-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/stokesy56/public-endpoint-manager/actions/workflows/ci.yml)

## Quick start (local)

```bash
git clone https://github.com/stokesy56/public-endpoint-manager.git
cd public-endpoint-manager
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