DOCKER := docker
GO := go

PKGNAME := 3cx-exporter
PROJECT := 3cx-exporter
VERSION := 0.1.0
IMAGE_REPO ?= ghcr.io/dark-vex
IMAGE_TAG ?= dev
GO_VERSION ?= 1.19.3

LICENSE := MIT

default: test

build: build-images
	$(DOCKER) run --rm -v ${PWD}/output:/3cx-exporter/bin/ --name $(PROJECT)-binary $(IMAGE_REPO)/$(PROJECT)-bin:$(IMAGE_TAG)

test:
	@echo "RUNNING: Unit tests" \
		&& $(GO) test -cover ./...
	@echo "RUNNING: Integration tests" \
		&& if [ "z${GITHUB_API_USER}" != "z" ] && which $(DOCKER) > /dev/null; then \
			cd test; \
			export GITHUB_API_USER=$(GITHUB_API_USER); \
			export GITHUB_API_KEY=$(GITHUB_API_KEY); \
			$(DOCKER) compose run --rm tester; \
		else \
			echo "Skipped"; \
		fi

build-images:
	$(DOCKER) build -t $(IMAGE_REPO)/$(PROJECT)-bin:$(IMAGE_TAG) -f build/docker/Dockerfile.binary .
	$(DOCKER) build -t $(IMAGE_REPO)/$(PROJECT):$(IMAGE_TAG) -f build/docker/Dockerfile .
	$(DOCKER) build -t $(IMAGE_REPO)/$(PROJECT)-rpm:$(IMAGE_TAG) -f build/docker/Dockerfile.rpm .
	$(DOCKER) build -t $(IMAGE_REPO)/$(PROJECT)-deb:$(IMAGE_TAG) -f build/docker/Dockerfile.deb .

push-images:
	$(DOCKER) push $(IMAGE_REPO)/$(PROJECT):$(IMAGE_TAG)
	$(DOCKER) push $(IMAGE_REPO)/$(PROJECT)-rpm:$(IMAGE_TAG)
	$(DOCKER) push $(IMAGE_REPO)/$(PROJECT)-deb:$(IMAGE_TAG)

delete-images:
	$(DOCKER) rmi $(IMAGE_REPO)/$(PROJECT):$(IMAGE_TAG)
	$(DOCKER) rmi $(IMAGE_REPO)/$(PROJECT)-rpm:$(IMAGE_TAG)
	$(DOCKER) rmi $(IMAGE_REPO)/$(PROJECT)-deb:$(IMAGE_TAG)

build-rpm: build-images
	$(DOCKER) run --rm -v ${PWD}/output:/home/builder/rpm/x86_64 --name $(PROJECT)-rpm $(IMAGE_REPO)/$(PROJECT)-rpm:$(IMAGE_TAG)

build-deb: build-images
	$(DOCKER) run --rm -v ${PWD}/output:/home/builder/deb/x86_64 --name $(PROJECT)-deb $(IMAGE_REPO)/$(PROJECT)-deb:$(IMAGE_TAG)

.PHONY: default build test build-images build-rpm build-deb push-images
