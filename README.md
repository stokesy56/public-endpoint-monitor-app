# Public Endpoint Manager

Synthetic availability & latency monitoring for third‑party services  
*(built as a DevOps portfolio project)*

[![CI](https://github.com/stokesy56/public-endpoint-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/stokesy56/public-endpoint-manager/actions/workflows/ci.yml)

## Quick start (local)

```bash
git clone https://github.com/stokesy56/public-endpoint-manager.git
cd public-endpoint-manager
poetry install          # set up virtual env
poetry run pytest -q    # run unit tests
```

## Probe in Action

```bash
poetry run python -m synexmon.probe https://www.google.com
```
Outputs:
```ini
success=True latency=0.135 s
```
