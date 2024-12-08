CURRENT_DIR := $(shell pwd)
WORK_DIR_BACKEND := $(CURRENT_DIR)/backend
WORK_DIR_FRONTEND := $(CURRENT_DIR)/front

VERSION ?= local
COMMIT_ID ?= local

BINARY_NAME := moments
FRONT_PUBLIC_NAME = $(BINARY_NAME)-front-public-$(VERSION)
LINUX_AMD64_BINARY_NAME = $(BINARY_NAME)-linux-amd64-$(VERSION)
LINUX_ARM64_BINARY_NAME = $(BINARY_NAME)-linux-arm64-$(VERSION)
DARWIN_AMD64_BINARY_NAME = $(BINARY_NAME)-darwin-amd64-$(VERSION)
DARWIN_ARM64_BINARY_NAME = $(BINARY_NAME)-darwin-arm64-$(VERSION)
WINDOWS_AMD64_BINARY_NAME = $(BINARY_NAME)-windows-amd64.exe-$(VERSION)
WINDOWS_ARM64_BINARY_NAME = $(BINARY_NAME)-windows-arm64.exe-$(VERSION)

frontend-install:
	cd $(WORK_DIR_FRONTEND) && pnpm i

frontend-dev:
	cd $(WORK_DIR_FRONTEND) && pnpm run dev

backend-dev:
	cd $(WORK_DIR_BACKEND) && go build -ldflags="-X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(LINUX_AMD64_BINARY_NAME)
	$(WORK_DIR_BACKEND)/dist/$(LINUX_AMD64_BINARY_NAME)

.PHONY: clean build frontend backend zip checksums

clean:
	cd $(WORK_DIR_BACKEND) && go clean
	cd $(WORK_DIR_BACKEND) && rm -rf ./public ./dist
	cd $(WORK_DIR_FRONTEND) && rm -rf ./.output ./dist

build: clean frontend backend

frontend:
	cd $(WORK_DIR_FRONTEND) && pnpm i && pnpm generate
	cp -r $(WORK_DIR_FRONTEND)/.output/public  $(WORK_DIR_BACKEND)

backend:
	cd $(WORK_DIR_BACKEND) && GOOS=linux GOARCH=amd64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(LINUX_AMD64_BINARY_NAME)
	cd $(WORK_DIR_BACKEND) && GOOS=linux GOARCH=arm64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(LINUX_ARM64_BINARY_NAME)
	cd $(WORK_DIR_BACKEND) && GOOS=darwin GOARCH=amd64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(DARWIN_AMD64_BINARY_NAME)
	cd $(WORK_DIR_BACKEND) && GOOS=darwin GOARCH=arm64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(DARWIN_ARM64_BINARY_NAME)
	cd $(WORK_DIR_BACKEND) && GOOS=windows GOARCH=amd64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(WINDOWS_AMD64_BINARY_NAME)
	cd $(WORK_DIR_BACKEND) && GOOS=windows GOARCH=arm64 go build -tags prod -ldflags="-s -w -X 'main.gitCommitID=$(COMMIT_ID)'" -o $(WORK_DIR_BACKEND)/dist/$(WINDOWS_ARM64_BINARY_NAME)

zip:
	cd $(WORK_DIR_FRONTEND)/.output && zip -r $(FRONT_PUBLIC_NAME).zip ./public
	cd $(WORK_DIR_BACKEND)/dist && find . -type f -name "$(BINARY_NAME)-*" | xargs -I {} zip {}.zip {}

checksums:
	cd $(WORK_DIR_FRONTEND)/.output && md5sum $(FRONT_PUBLIC_NAME).zip > $(FRONT_PUBLIC_NAME).zip-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(LINUX_AMD64_BINARY_NAME) >  $(LINUX_AMD64_BINARY_NAME)-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(LINUX_ARM64_BINARY_NAME) >  $(LINUX_ARM64_BINARY_NAME)-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(DARWIN_AMD64_BINARY_NAME) >  $(DARWIN_AMD64_BINARY_NAME)-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(DARWIN_ARM64_BINARY_NAME) >  $(DARWIN_ARM64_BINARY_NAME)-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(WINDOWS_AMD64_BINARY_NAME) >  $(WINDOWS_AMD64_BINARY_NAME)-checksum.txt
	cd $(WORK_DIR_BACKEND)/dist && md5sum $(WINDOWS_ARM64_BINARY_NAME) >  $(WINDOWS_ARM64_BINARY_NAME)-checksum.txt
