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

.PHONY: install lint test format
