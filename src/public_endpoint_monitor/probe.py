import time
import requests

DEFAULT_URL = "https://www.google.com"


def probe(url: str = DEFAULT_URL, timeout: float = 5.0) -> tuple[bool, float]:
    """Return (success, latency_seconds)."""
    start = time.perf_counter()
    try:
        r = requests.get(url, timeout=timeout)
        r.raise_for_status()
        success = True
    except requests.RequestException:
        success = False
    finally:
        latency = time.perf_counter() - start

    return success, latency
