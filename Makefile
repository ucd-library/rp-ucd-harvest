#! /bin/make
SHELL:=/bin/bash

prefix:=$(shell echo ~/.local)

scripts:=ucdid harvest cdl
pods:=$(patsubst %,%.pod,${scripts})

$(warning ${pods})

pre-commit: ${pods}
	@podchecker ${pods}

${pods}:%.pod:%
	@podselect $< > $@

install:
	@type podchecker;
	@type http;
	@type pod2text;
	@if [[ -d ${prefix}/bin ]]; then\
    echo "install to ${prefix}/bin"; \
    install ucdid ${prefix}/bin; \
    install cdl ${prefix}/bin; \
    install harvest ${prefix}/bin; \
	else \
		echo "installation directory ${prefix}/bin not found"; \
		echo "Try setting prefix as in make prefix=/usr/local install"; \
		exit 1; \
	fi;
