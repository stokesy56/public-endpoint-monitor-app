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


# ── Docker build and run ────────────────────────────────────────────────────────


IMAGE    = public-endpoint-manager:dev
URL      = https://www.google.com
INTERVAL = 5
NAME     = pem-loop

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker run --rm -p 9000:9000 $(IMAGE) --url=$(URL) --interval=$(INTERVAL)


# ── KIND / K8s targets ────────────────────────────────────────────────────────
CLUSTER ?= pem-dev
KIND_NODE_IMAGE ?= kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f
IMAGE ?= public-endpoint-manager:dev
NS ?= pem

kind-up: docker-build
	kind create cluster --name $(CLUSTER) --image $(KIND_NODE_IMAGE)
	kind load docker-image $(IMAGE) --name $(CLUSTER)
	@echo "✅ Cluster $(CLUSTER) is ready"

k8s-apply:
	kubectl create ns $(NS) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f k8s/

k8s-port:
	kubectl port-forward svc/pem-metrics -n $(NS) 9000:9000

kind-down:
	kind delete cluster --name $(CLUSTER)



.PHONY: install lint test format docker-build docker-run kind-up k8s-apply k8s-port kind-down
