# tests/test_service.py
import logging, pytest, sys
import public_endpoint_monitor.service as service


def test_service_runs_one_iteration(monkeypatch, caplog):
    """
    • Verifies service.main() starts /metrics, calls probe() once,
      and emits the banner log line.
    • time.sleep is monkey‑patched to raise KeyboardInterrupt so the
      infinite loop exits immediately.
    """
    called = {"probe": 0, "port": None}

    # --- stubs -----------------------------------------------------------------
    def fake_probe(url: str):
        called["probe"] += 1
        assert url == "https://example.com"
        return True, 0.123  # success, latency

    def fake_start_http_server(port: int):
        called["port"] = port

    # --- monkey‑patches --------------------------------------------------------
    monkeypatch.setattr(service, "probe", fake_probe)
    monkeypatch.setattr(service, "start_http_server", fake_start_http_server)
    monkeypatch.setattr(
        service.time,
        "sleep",
        lambda _: (_ for _ in ()).throw(KeyboardInterrupt),
    )
    monkeypatch.setattr(
        sys,
        "argv",
        ["pem-service", "--url", "https://example.com", "--interval", "1"],
        raising=False,
    )

    # --- capture logs ----------------------------------------------------------
    caplog.set_level(logging.INFO)

    with pytest.raises(KeyboardInterrupt):
        service.main()

    # --- assertions ------------------------------------------------------------
    assert called["probe"] == 1
    assert called["port"] == 9000
    assert any("probing https://example.com every 1s" in msg for msg in caplog.messages)
