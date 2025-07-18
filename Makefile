SHELL := /usr/bin/env bash

install:
	poetry install

lint:
	poetry run black .
	poetry run flake8 .

test:
	poetry run pytest -q

format:  ## Format code with black
	poetry run black .

IMAGE    = public-endpoint-manager:dev
URL      = https://www.google.com
INTERVAL = 5
NAME     = pem-loop

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker run --rm -p 9000:9000 $(IMAGE) --url=$(URL) --interval=$(INTERVAL)

.PHONY: install lint test format docker-build docker-run
