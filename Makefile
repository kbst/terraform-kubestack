_all: dist build

GIT_REF ?= $(shell echo "refs/heads/"`git rev-parse --abbrev-ref HEAD`)
GIT_SHA ?= $(shell echo `git rev-parse --verify HEAD^{commit}`)

DOCKER_PUSH ?= false
DOCKER_TARGET ?= multi-cloud

ifeq ("${DOCKER_PUSH}", "true")
BUILD_PLATFORM := --platform linux/arm64,linux/amd64
BUILD_CACHE_DIST := --cache-to type=registry,mode=max,ref=ghcr.io/kbst/terraform-kubestack/dev:buildcache-dist-helper,push=${DOCKER_PUSH}
BUILD_OUTPUT := --output type=registry,push=${DOCKER_PUSH}
BUILD_CACHE := --cache-to type=registry,mode=max,ref=ghcr.io/kbst/terraform-kubestack/dev:buildcache-${DOCKER_TARGET},push=${DOCKER_PUSH}
else
BUILD_PLATFORM := 
BUILD_OUTPUT := --output type=docker
endif

dist:
	rm -rf quickstart/_dist

	docker buildx build \
		--build-arg GIT_REF=${GIT_REF} \
		--build-arg GIT_SHA=${GIT_SHA} \
		--file oci/Dockerfile \
		--output type=docker \
		--cache-from type=registry,ref=ghcr.io/kbst/terraform-kubestack/dev:buildcache-dist-helper \
		${BUILD_CACHE_DIST} \
		--progress plain \
		-t dist-helper:latest \
		--target dist-helper \
		.

	docker run \
		--detach \
		--name dist-helper \
		--rm dist-helper:latest \
		sleep 600

	docker cp dist-helper:/quickstart/_dist quickstart/_dist
	docker stop dist-helper

build:
	docker buildx build \
		${BUILD_PLATFORM} \
		--build-arg GIT_REF=${GIT_REF} \
		--build-arg GIT_SHA=${GIT_SHA} \
		--file oci/Dockerfile \
		${BUILD_OUTPUT} \
		--cache-from type=registry,ref=ghcr.io/kbst/terraform-kubestack/dev:buildcache-${DOCKER_TARGET} \
		${BUILD_CACHE} \
		--progress plain \
		--target ${DOCKER_TARGET} \
		-t ghcr.io/kbst/terraform-kubestack/dev:test-$(GIT_SHA)-${DOCKER_TARGET} \
		.

validate: .init
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform validate

test: validate
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform apply --target module.aks_zero --target module.eks_zero --target module.gke_zero --input=false --auto-approve
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform apply --target module.eks_zero_nginx --input=false --auto-approve
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform apply --input=false --auto-approve

cleanup: .init
	docker exec \
		-ti \
		test-container-$(GIT_SHA) \
		entrypoint terraform destroy --input=false --auto-approve
	$(MAKE) .stop-container

shell: .check-container
	docker exec \
		-ti \
		test-container-$(GIT_SHA) \
		entrypoint bash

.check-container:
	docker inspect test-container-${GIT_SHA} > /dev/null || $(MAKE) .run-container

.run-container: build
	docker run \
		--detach \
		--name test-container-${GIT_SHA} \
		--rm \
		-v `pwd`:/infra:z \
		-e KBST_AUTH_AWS \
		-e KBST_AUTH_AZ \
		-e KBST_AUTH_GCLOUD \
		-e HOME=/infra/tests/.user \
		--workdir /infra/tests \
		ghcr.io/kbst/terraform-kubestack/dev:test-$(GIT_SHA)-${DOCKER_TARGET} \
		sleep infinity

.stop-container:
	docker stop test-container-${GIT_SHA} || true

.init: .check-container
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform init
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform workspace select ops
