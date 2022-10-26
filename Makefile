ECR_REPO := "528451384384.dkr.ecr.us-west-2.amazonaws.com/smsk-kafka-load"
VERSION := "v2.5.1"

.PHONY: docker-build
docker-build:
	docker build --build-arg VERSION=$(VERSION) \
		-t $(ECR_REPO):$(VERSION) \
		-t $(ECR_REPO):$(BUILDKITE_COMMIT_REVISION) \
		.

.PHONY: docker-publish
docker-publish: docker-build
	docker push $(ECR_REPO):$(VERSION)
	docker push $(ECR_REPO):$(BUILDKITE_COMMIT_REVISION)
