import requests, sys, time
from prometheus_client import Counter, Histogram, start_http_server

DEFAULT_URL = "https://www.google.com"

# ── Prometheus metrics ────────────────────────────────────────────────────────
REQUEST_COUNT = Counter(
    "pem_probes_total",
    "Number of probe attempts",
    ["target", "result"],
)
LATENCY = Histogram(
    "pem_probe_latency_seconds",
    "Latency of HTTP probe",
    ["target"],
    buckets=(0.05, 0.2, 0.5, 1, 2, 5),
)


# ── Probe logic ───────────────────────────────────────────────────────────────
def probe(
    url: str = DEFAULT_URL,
    timeout: float = 5.0,
    record_metrics: bool = True,
) -> tuple[bool, float]:
    """Return (success flag, latency seconds); record Prometheus metrics by default."""
    start = time.perf_counter()
    try:
        response = requests.get(url, timeout=timeout)
        response.raise_for_status()
        success = True
    except requests.RequestException:
        success = False
    latency = time.perf_counter() - start

    if record_metrics:
        result_label = "success" if success else "failure"
        REQUEST_COUNT.labels(url, result_label).inc()
        LATENCY.labels(url).observe(latency)

    return success, latency


# ── CLI entrypoint ────────────────────────────────────────────────────────────
def main() -> None:
    start_http_server(9000)  # /metrics
    url = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_URL
    success, latency = probe(url)  # metrics are recorded inside
    print(f"target={url} success={success} latency={latency:.3f}s")


if __name__ == "__main__":
    main()
