import requests, threading
from wsgiref.simple_server import make_server
from prometheus_client import exposition, REGISTRY
from public_endpoint_monitor.service import probe


def test_metrics_endpoint_serves_custom_series():
    # ── spin up an in‑process /metrics server on a random port ──────────────
    httpd = make_server("", 0, exposition.make_wsgi_app(REGISTRY))
    port = httpd.server_port
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()

    # update metrics
    probe("https://www.google.com")

    # fetch and assert
    resp = requests.get(f"http://localhost:{port}/metrics", timeout=5)
    resp.raise_for_status()
    assert "pem_probes_total" in resp.text

    httpd.shutdown()
