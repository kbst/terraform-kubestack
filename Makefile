_all: dist build

GIT_REF := $(shell echo "refs/heads/"`git rev-parse --abbrev-ref HEAD`)
GIT_SHA := $(shell echo `git rev-parse --verify HEAD^{commit}`)

dist:
	rm -rf quickstart/_dist

	docker build \
		--build-arg GIT_REF=${GIT_REF} \
		--build-arg GIT_SHA=${GIT_SHA} \
		--file oci/Dockerfile \
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
	docker build \
		--build-arg GIT_REF=${GIT_REF} \
		--build-arg GIT_SHA=${GIT_SHA} \
		--file oci/Dockerfile \
		--progress plain \
		-t kubestack/framework:local-$(GIT_SHA) \
		. 

validate: .init
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform validate

test: validate
	docker exec \
		test-container-$(GIT_SHA) \
		entrypoint terraform apply --input=false --auto-approve

cleanup: .init
	docker exec \
		-ti \
		test-container-$(GIT_SHA) \
		entrypoint terraform destroy --input=false --auto-approve
	$(MAKE) .stop-container

shell: .init
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
		kubestack/framework:local-$(GIT_SHA) \
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
