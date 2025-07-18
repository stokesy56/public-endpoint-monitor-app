from public_endpoint_monitor.probe import main


def test_cli_runs(capsys, monkeypatch):
    monkeypatch.setattr("sys.argv", ["probe", "https://api.github.com/zen"])
    main()
    out, _ = capsys.readouterr()
    assert "success=True" in out
