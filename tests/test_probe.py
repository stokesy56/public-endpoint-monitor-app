# tests/test_probe.py
from public_endpoint_monitor.probe import probe


def test_google():
    success, latency = probe()
    assert success
    assert latency < 3
