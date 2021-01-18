#!/usr/bin/make -f

# COMMIT := $(shell git log -1 --format='%H')
NETWORK_TYPE := brcnet

export GO111MODULE = on
export GOPROXY = https://goproxy.io
# windows, linux, darwin
export GOOS = linux
export GOARCH = amd64

# include ledger support
include Makefile.ledger

ldflags = -X 'go-brc/version.NetworkType=$(NETWORK_TYPE)' \
          -X 'go-brc/version.BuildTags=netgo'

BUILD_FLAGS := -tags "$(build_tags)" -ldflags "$(ldflags)"

all: build

build: go.sum
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/brcd.exe ./cmd/brcd
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/brccli.exe ./cmd/brccli
else
    UNAME_S := $(shell uname -s)
    goos_flag := linux
    ifeq ($(UNAME_S), Darwin)
        goos_flag = darwin
    endif
    ifeq ($(UNAME_S), OpenBSD)
        goos_flag = openbsd
    endif
    ifeq ($(UNAME_S), FreeBSD)
        goos_flag = freebsd
    endif
    ifeq ($(UNAME_S), NetBSD)
        goos_flag = netbsd
    endif
	GOOS=$(goos_flag) GOARCH=amd64 go build -mod=readonly $(BUILD_FLAGS) -o build/$(goos_flag)/brcd ./cmd/brcd
	GOOS=$(goos_flag) GOARCH=amd64 go build -mod=readonly $(BUILD_FLAGS) -o build/$(goos_flag)/brccli ./cmd/brccli
endif

build-windows: go.sum
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/brcd.exe ./cmd/brcd
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/brccli.exe ./cmd/brccli

build-linux: go.sum
# LEDGER_ENABLED=false GOOS=linux GOARCH=amd64 $(MAKE) build
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/linux/brcd ./cmd/brcd
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/linux/brccli ./cmd/brccli

build-mac: go.sum
# LEDGER_ENABLED=false GOOS=darwin GOARCH=amd64 $(MAKE) build
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/mac/brcd ./cmd/brcd
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/mac/brccli ./cmd/brccli

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download

go.sum: go.mod
	@echo "--> Ensure dependecies have not been modified"
	@go mod verify
	@go mod tidy

clean:
	rm -rf build/

