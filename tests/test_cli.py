# tests/test_cli.py
from public_endpoint_monitor.probe import main
import sys


def test_cli_runs(capsys, monkeypatch):
    # ⬇ turn start_http_server into a no‑op so we don't bind :9000
    monkeypatch.setattr(
        "public_endpoint_monitor.probe.start_http_server",
        lambda *_, **__: None,
    )

    monkeypatch.setattr(sys, "argv", ["pem-probe", "https://api.github.com/zen"])
    main()

    out, _ = capsys.readouterr()
    assert "success=True" in out
