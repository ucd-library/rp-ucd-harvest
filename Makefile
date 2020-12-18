#! /bin/make
SHELL:=/bin/bash

#version:=1.1.1
version:=dev
tag:=ucdlib/rp-ucd-harvest:${version}

.PHONY: build
build:
	export DOCKER_BUILDKIT=1
	docker build --build-arg BUILDKIT_INLINE_CACHE=1 -t ${tag} .
