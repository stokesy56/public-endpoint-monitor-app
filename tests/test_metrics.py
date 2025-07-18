from public_endpoint_monitor.probe import probe, REQUEST_COUNT

TARGET = "https://www.google.com"


def test_counter_increments():
    before = REQUEST_COUNT.labels(TARGET, "success")._value.get()
    probe(TARGET)
    after = REQUEST_COUNT.labels(TARGET, "success")._value.get()
    assert after == before + 1
