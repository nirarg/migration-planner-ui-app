DOCKER_CONF ?= $(CURDIR)/docker-config
DOCKER_AUTH_FILE ?= ${DOCKER_CONF}/auth.json
PODMAN ?= podman
IMAGE ?= quay.io/nargaman/migration-planner-ui
IMAGE_TAG ?= $(shell git rev-parse HEAD)
REPLICAS ?= 1

oc: # Verify oc installed, in linux install it if not already installed
ifeq ($(OC_BIN),)
	@if [ "$(OS)" = "darwin" ]; then \
		echo "Error: macOS detected. Please install oc manually from https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$(OC_VERSION)/"; \
		exit 1; \
	fi
	@echo "oc not found. Installing for Linux..."
	@curl -sL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$(OC_VERSION)/openshift-client-linux.tar.gz" | tar -xz
	@chmod +x oc kubectl
	@sudo mv oc kubectl /usr/local/bin/
	@echo "oc installed successfully."
else
	@echo "oc is already installed at $(OC_BIN)"
endif

build:
	rm -rf dist
	npm install
	npm run build

podman-build:
	$(PODMAN) build . -t $(IMAGE):$(IMAGE_TAG) -f deploy/dev/Containerfile --arch amd64 --memory=4g

quay-login:
	@if [ ! -f $(DOCKER_AUTH_FILE) ] && [ $(QUAY_USER) ] && [ $(QUAY_TOKEN) ]; then \
		$(info Create Auth File: $(DOCKER_AUTH_FILE)) \
		mkdir -p "$(DOCKER_CONF)"; \
		$(PODMAN) login --authfile $(DOCKER_AUTH_FILE) -u=$(QUAY_USER) -p=$(QUAY_TOKEN) quay.io; \
	fi;

podman-push:
	if [ -f $(DOCKER_AUTH_FILE) ]; then \
		$(PODMAN) push --authfile=$(DOCKER_AUTH_FILE) $(IMAGE):$(IMAGE_TAG); \
	else \
		$(PODMAN) push $(IMAGE):$(IMAGE_TAG); \
	fi;

deploy-on-openshift:
	oc process -f deploy/ui-template.yaml \
		   -p MIGRATION_PLANNER_UI_IMAGE=$(IMAGE) \
		   -p MIGRATION_PLANNER_REPLICAS=$(REPLICAS) \
		   -p IMAGE_TAG=$(IMAGE_TAG) \
		 | oc apply -f -; \
	oc expose service migration-planner-ui --name planner-ui; \
	echo "*** Migration Planner UI has been deployed successfully on Openshift ***"

delete-from-openshift:
	oc process -f https://raw.githubusercontent.com/kubev2v/migration-planner-ui/refs/heads/main/deploy/templates/ui-template.yml \
		   -p MIGRATION_PLANNER_UI_IMAGE=$(IMAGE) \
		   -p MIGRATION_PLANNER_REPLICAS=$(REPLICAS) \
		   -p IMAGE_TAG=$(IMAGE_TAG) \
		 | oc delete -f -; \
	oc delete route planner-ui; \
	echo "*** Migration Planner UI has been deleted successfully from Openshift ***"

