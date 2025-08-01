SHELL := /usr/bin/env bash


# ── Poetry config ────────────────────────────────────────────────────────
install:
	poetry install

lint:
	poetry run black .
	poetry run flake8 .

test:
	poetry run pytest -q

format:  ## Format code with black
	poetry run black .

# ── pre-commit config ────────────────────────────────────────────────────────

pre-commit-install:
	poetry run pre-commit clean
	poetry run pre-commit install
	poetry run pre-commit run --all-files

pre-commit-run:
	poetry run pre-commit run --all-files
# ── Docker build and run ────────────────────────────────────────────────────────


IMAGE    = public-endpoint-monitor:dev
URL      = https://www.google.com
INTERVAL = 5
NAME     = pem-loop

docker-build:
	docker build -t $(IMAGE) /home/rory/projects/public-endpoint-monitor-app/Dockerfile

docker-run:
	docker run --rm -p 9000:9000 $(IMAGE) --url=$(URL) --interval=$(INTERVAL)


# ── KIND / K8s targets ────────────────────────────────────────────────────────
CLUSTER ?= pem-dev
KIND_NODE_IMAGE ?= kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f
IMAGE ?= public-endpoint-monitor:dev
NS ?= pem

kind-up: docker-build
	kind create cluster --name $(CLUSTER) --image $(KIND_NODE_IMAGE)
	kind load docker-image $(IMAGE) --name $(CLUSTER)
	@echo "✅ Cluster $(CLUSTER) is ready"

k8s-apply:
	kubectl create ns $(NS) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f /home/rory/projects/public-endpoint-monitor-app/k8s/

k8s-port:
	kubectl port-forward svc/pem-metrics -n $(NS) 9000:9000

kind-down:
	kind delete cluster --name $(CLUSTER)

CHART_DIR ?= /home/rory/projects/public-endpoint-monitor-app/charts/public-endpoint-monitor
RELEASE   ?= pem-dev

# ── Helm ────────────────────────────────────────────────────────

helm-clean:
	helm uninstall $(RELEASE) -n $(NS) || true
	kubectl delete deploy,svc -l app=pem --namespace $(NS) --ignore-not-found

helm-install: helm-clean
	helm upgrade --install $(RELEASE) $(CHART_DIR) --namespace $(NS) --create-namespace

helm-port:
	kubectl port-forward svc/$(RELEASE)-pem-metrics -n $(NS) 9000:9000

chart-package:
	helm package charts/public-endpoint-monitor --destination dist

monitor-up:
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
	  --version 59.0.0 --namespace monitoring --create-namespace \
	  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
	  --set grafana.service.type=ClusterIP \
	  --set grafana.enabled=true --set alertmanager.enabled=false

monitor-port-prometheus:
	kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

monitor-port-grafana:
	kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

PROJECT_ID ?= $(shell gcloud config get-value project)
REGION ?= europe-west2
REGISTRY_HOST ?= $(REGION)-docker.pkg.dev
CHART_PATH ?= oci://$(REGISTRY_HOST)/$(PROJECT_ID)/public-endpoint-monitor/helm/public-endpoint-monitor

helm-login:
	gcloud auth print-access-token | \
	  helm registry login $(REGISTRY_HOST) -u oauth2accesstoken --password-stdin

helm-install-remote: helm-login
	helm pull $(CHART_PATH) --version $(VERSION)
	helm upgrade --install $(RELEASE) $(CHART_PATH) \
	  --version $(VERSION) \
	  --namespace $(NS) --create-namespace

.PHONY: install lint test format docker-build docker-run kind-up k8s-apply k8s-port kind-down helm-clean helm-install helm-port monitor-up monitor-port-prometheus monitor-port-grafana helm-login helm-install-remote
