"""
public_endpoint_monitor.service
--------------------------------
Long‑running process that:

1. Starts Prometheus /metrics on port 9000
2. Repeatedly probes a target URL at a configurable interval
3. Records Prometheus metrics (handled inside probe()) and logs each result
"""

import argparse, logging, time
from datetime import datetime, timezone
from prometheus_client import start_http_server
from .probe import probe, DEFAULT_URL


def _utc_now_iso() -> str:
    """Return current UTC time in ISO‑8601 format with Z suffix."""
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def main() -> None:
    # ── CLI args ──────────────────────────────────────────────────────────────
    parser = argparse.ArgumentParser(description="Continuous synthetic probe service")
    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help=f"Target URL to probe (default: {DEFAULT_URL})",
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=30,
        metavar="SECONDS",
        help="Seconds between probes (default: 30)",
    )
    args = parser.parse_args()

    # ── Logging setup ─────────────────────────────────────────────────────────
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y‑%m‑%dT%H:%M:%SZ",
    )

    # ── Start Prometheus exporter ─────────────────────────────────────────────
    start_http_server(9000)
    logging.info(
        "Serving /metrics on :9000; probing %s every %ss", args.url, args.interval
    )

    # ── Main loop ─────────────────────────────────────────────────────────────
    while True:
        success, latency = probe(args.url)
        logging.info("target=%s success=%s latency=%.3fs", args.url, success, latency)
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
