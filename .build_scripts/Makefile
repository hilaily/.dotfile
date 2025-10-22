.PHONY: image tag version

# 默认架构
GOOS ?= linux
GOARCH ?= $(shell go env GOARCH)

# 常用架构组合
PLATFORMS ?= linux/amd64,linux/arm64

# Docker 构建
docker-local:
	$(MAKE) check-image-name
	GOOS=$(GOOS) GOARCH=$(GOARCH) .build_scripts/build_go.sh
	GOOS=$(GOOS) GOARCH=$(GOARCH) .build_scripts/build_image.sh $(IMAGE_NAME) Dockerfile.local

docker-local-amd64:
	$(MAKE) check-image-name
	GOOS=linux GOARCH=amd64 .build_scripts/build_go.sh
	GOOS=linux GOARCH=amd64 .build_scripts/build_image.sh $(IMAGE_NAME) Dockerfile.local

docker-local-arm64:
	$(MAKE) check-image-name
	GOOS=linux GOARCH=arm64 .build_scripts/build_go.sh
	GOOS=linux GOARCH=arm64 .build_scripts/build_image.sh $(IMAGE_NAME) Dockerfile.local

docker-local-multiarch:
	$(MAKE) check-image-name
	make build-all-multiarch
	PLATFORM=$(PLATFORMS) .build_scripts/build_image.sh $(IMAGE_NAME) Dockerfile.local

check-image-name:
	@if [ -z "$(IMAGE_NAME)" ]; then \
		echo "IMAGE_NAME is not set"; \
		exit 1; \
	fi; \


tag:
	@VERSION=$$(cat VERSION); \
	echo "Creating tag: $$VERSION"; \
	git tag $$VERSION; \
	git push origin $$VERSION; \
	echo "Tag $$VERSION created and pushed successfully"

version: .build_scripts/version.sh
	@.build_scripts/version.sh "$(filter-out version,$(MAKECMDGOALS))" "$(VERSION)"