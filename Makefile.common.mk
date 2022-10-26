#
# This file provides common Make targets for Docker images.
#
# Unless you're doing something special, `include`ing this file will allow you
# to write a minimal image-specific Makefile; here's an example (note that the
# path to the include Makefile will vary, depending on where you are in the
# `images` tree):
#
# ```
# include ../Makefile.common.mk
#
# IMAGE_NAME := my-image-name
# IMAGE_VERSION := v1.0.0
# ```
#
# This would publish a Docker image to `segment/my-image-name:v1.0.0`.
#

# suffix image tag versions with branch name for non-master branch
BRANCH = $(shell git rev-parse --abbrev-ref HEAD | tr '/' '-')
ifdef BUILDKITE_BRANCH
BRANCH := $(shell echo "$(BUILDKITE_BRANCH)" | tr '/' '-')
endif

ifeq ($(BRANCH),master)
TAG = $(IMAGE_VERSION)
else
TAG = $(IMAGE_VERSION)-$(BRANCH)
endif

define assert-variable
@if [ -z "$($1)" ]; then \
	echo 'ERROR: Variable `$1` is unset; set it in your Makefile.'; \
	exit 1; \
fi
endef

# flags used by imager to use buildx to build images for multiple architectures
MULTI_ARCH_FLAGS := --multi-arch --platform linux/amd64,linux/arm64

Q=@

buildpush-nocache:
	$Q$(MAKE) buildpush FLAGS='--no-cache'
.PHONY: buildpush-nocache

buildpush: update-multi-arch-flags
	$Q$(call assert-variable,IMAGE_NAME)
	$Q$(call assert-variable,IMAGE_VERSION)
	$Qimager buildpush . $(FLAGS) -d all -r $(IMAGE_NAME) --extra-tag $(TAG) --build-arg version=$(IMAGE_VERSION)

.PHONY: buildpush

repository:
	$Qaws-okta exec ops-write -- aws ecr create-repository --repository-name=$(IMAGE_NAME)

repository-policy:
	$Qaws-okta exec ops-write -- aws ecr set-repository-policy \
	--registry-id="528451384384" \
	--repository-name=$(IMAGE_NAME) \
	--policy-text='{"Version": "2008-10-17", "Statement": [{"Action": ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability", "ecr:DescribeImages"], "Principal": "*", "Effect": "Allow", "Condition": {"ForAnyValue:StringLike": {"aws:PrincipalOrgPaths": "o-wb8ewg4hzk/*"}}, "Sid": "AllowOrganization"}]}'

update-multi-arch-flags:
	$(info MULTI_ARCH="$(MULTI_ARCH)")
	$(eval FLAGS := $(shell if [ "$(MULTI_ARCH)" = "true" ]; then echo "$(FLAGS) $(MULTI_ARCH_FLAGS)"; else echo "$(FLAGS)"; fi) )

all: buildpush
.PHONY: all repository repository-policy update-multi-arch-flags
.DEFAULT_GOAL = all
