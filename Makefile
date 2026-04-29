SHELL := /bin/bash

CLUSTER ?= nebulosa
APP     ?=

CONTEXT := admin@$(CLUSTER)
DIR     := $(CLUSTER)/$(APP)

.PHONY: apply diff build apply-all coredns-add coredns-remove coredns-list help

help:
	@echo "Targets:"
	@echo "  apply         CLUSTER=<cluster> APP=<app>   apply a single app"
	@echo "  diff          CLUSTER=<cluster> APP=<app>   diff a single app"
	@echo "  build         CLUSTER=<cluster> APP=<app>   render YAML only"
	@echo "  apply-all     CLUSTER=<cluster>             apply all apps in cluster"
	@echo "  coredns-add   CLUSTER=<cluster>             add a CoreDNS rewrite rule"
	@echo "  coredns-remove CLUSTER=<cluster>            remove a CoreDNS rewrite rule"
	@echo "  coredns-list  CLUSTER=<cluster>             list managed CoreDNS rewrites"
	@echo ""
	@echo "Clusters: nebulosa, humboldt"
	@echo "Examples:"
	@echo "  make apply        CLUSTER=nebulosa APP=langfuse"
	@echo "  make diff         CLUSTER=humboldt APP=tailscale-operator"
	@echo "  make apply-all    CLUSTER=nebulosa"
	@echo "  make coredns-add  CLUSTER=nebulosa"

apply:
	@[[ -n "$(APP)" ]] || (echo "APP is required"; exit 1)
	kustomize build --enable-helm $(DIR) | kubectl apply --server-side -f - --context=$(CONTEXT)

diff:
	@[[ -n "$(APP)" ]] || (echo "APP is required"; exit 1)
	kustomize build --enable-helm $(DIR) | kubectl diff -f - --context=$(CONTEXT)

build:
	@[[ -n "$(APP)" ]] || (echo "APP is required"; exit 1)
	kustomize build --enable-helm $(DIR)

coredns-add:
	../scripts/k8s/coredns-syncer.sh $(CLUSTER) add

coredns-remove:
	../scripts/k8s/coredns-syncer.sh $(CLUSTER) remove

coredns-list:
	../scripts/k8s/coredns-syncer.sh $(CLUSTER) list

apply-all:
	@for dir in $(CLUSTER)/*/; do \
		app=$$(basename $$dir); \
		if [[ ! -f "$$dir/kustomization.yaml" ]]; then continue; fi; \
		echo "==> $$app"; \
		kustomize build --enable-helm $$dir | kubectl apply --server-side -f - --context=$(CONTEXT); \
	done
