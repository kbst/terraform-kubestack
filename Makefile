_all: dist build

GITHUB_REF := $(shell echo "refs/heads/"`git rev-parse --abbrev-ref HEAD`)
GITHUB_SHA := $(shell echo `git rev-parse --verify HEAD^{commit}`)

dist:
	docker build -t actions_build_artifacts:$(GITHUB_SHA) .github/actions/build_artifacts/
	docker run --rm -e GITHUB_REF=$(GITHUB_REF) -e GITHUB_SHA=$(GITHUB_SHA) -v `pwd`/quickstart:/opt/quickstart:z actions_build_artifacts:$(GITHUB_SHA)

build: dist
	docker build --file oci/Dockerfile --progress plain -t kubestack/framework:local-$(GITHUB_SHA) . 

test:
	cloud-build-local --substitutions=_KBST_AUTH_AWS=${KBST_AUTH_AWS},_KBST_AUTH_GCLOUD=${KBST_AUTH_GCLOUD},_KBST_AUTH_AZ=${KBST_AUTH_AZ},_GITHUB_REF=$(GITHUB_REF),_GITHUB_SHA=$(GITHUB_SHA) --dryrun=false --config cloudbuild-test.yaml .

test-cleanup:
	cloud-build-local --substitutions=_KBST_AUTH_AWS=${KBST_AUTH_AWS},_KBST_AUTH_GCLOUD=${KBST_AUTH_GCLOUD},_KBST_AUTH_AZ=${KBST_AUTH_AZ},_GITHUB_REF=$(GITHUB_REF),_GITHUB_SHA=$(GITHUB_SHA) --dryrun=false --config cloudbuild-cleanup.yaml .

providers:
	cloud-build-local --substitutions=_KBST_AUTH_AWS=${KBST_AUTH_AWS},_KBST_AUTH_GCLOUD=${KBST_AUTH_GCLOUD},_KBST_AUTH_AZ=${KBST_AUTH_AZ},_GITHUB_REF=$(GITHUB_REF),_GITHUB_SHA=$(GITHUB_SHA) --dryrun=false --config cloudbuild-providers.yaml .

shell: build
	docker run -ti --rm -e KBST_AUTH_AWS -e KBST_AUTH_AZ -e KBST_AUTH_GCLOUD -e HOME=/infra/tests/.user -v `pwd`:/infra:z --workdir /infra/tests kubestack/framework:local-$(GITHUB_SHA) bash