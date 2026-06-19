SHELL := /bin/bash

# Automatically detect Flutter implementations in subfolders.
IMPLEMENTATIONS := $(shell find . -mindepth 2 -maxdepth 4 -type f -name pubspec.yaml -not -path "*/.git/*" | sed 's|^\./||; s|/pubspec.yaml$$||' | sort)
IMPL ?= $(firstword $(IMPLEMENTATIONS))

.PHONY: help list doctor bootstrap bootstrap-all run test analyze smoke test-all clean clean-all

help:
	@echo "Flutter implementation runner (macOS desktop)"
	@echo
	@echo "Detected implementations:"
	@if [ -n "$(IMPLEMENTATIONS)" ]; then \
		printf '%s\n' $(IMPLEMENTATIONS) | sed '/^$$/d; s/^/  - /'; \
	else \
		echo "  (none found)"; \
	fi
	@echo
	@echo "Usage:"
	@echo "  make list"
	@echo "  make doctor"
	@echo "  make bootstrap IMPL=<folder>"
	@echo "  make run IMPL=<folder>"
	@echo "  make test IMPL=<folder>"
	@echo "  make analyze IMPL=<folder>"
	@echo "  make smoke IMPL=<folder>"
	@echo "  make test-all"
	@echo "  make clean-all"
	@echo
	@echo "Default IMPL: $(IMPL)"

list:
	@echo "Detected implementations:"
	@if [ -n "$(IMPLEMENTATIONS)" ]; then \
		printf '%s\n' $(IMPLEMENTATIONS) | sed '/^$$/d' | nl -w2 -s'. '; \
	else \
		echo "none"; \
	fi

doctor:
	@command -v flutter >/dev/null || (echo "flutter is not installed or not in PATH" && exit 1)
	@flutter --version
	@echo
	@echo "Checking macOS desktop support..."
	@devices_output="$$(flutter devices)"; \
		echo "$$devices_output" | grep -qi "macos" || (echo "No macOS desktop device found. Run: flutter config --enable-macos-desktop" && exit 1)
	@echo "macOS desktop device detected"

bootstrap:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> flutter pub get in $(IMPL)"
	@cd "$(IMPL)" && flutter pub get

bootstrap-all:
	@if [ -z "$(IMPLEMENTATIONS)" ]; then \
		echo "No Flutter implementations found."; \
		exit 1; \
	fi
	@set -e; \
	for app in $(IMPLEMENTATIONS); do \
		echo "==> flutter pub get in $$app"; \
		(cd "$$app" && flutter pub get); \
	done

run:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> Starting $(IMPL) on macOS desktop"
	@cd "$(IMPL)" && flutter run -d macos

test:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> Running tests in $(IMPL)"
	@cd "$(IMPL)" && flutter test

analyze:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> Running analyzer in $(IMPL)"
	@cd "$(IMPL)" && flutter analyze

smoke:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> Smoke checks for $(IMPL)"
	@cd "$(IMPL)" && flutter pub get && flutter analyze && flutter test

test-all:
	@if [ -z "$(IMPLEMENTATIONS)" ]; then \
		echo "No Flutter implementations found."; \
		exit 1; \
	fi
	@set -e; \
	for app in $(IMPLEMENTATIONS); do \
		echo "==> flutter test in $$app"; \
		(cd "$$app" && flutter test); \
	done

clean:
	@if [ -z "$(IMPL)" ] || [ ! -f "$(IMPL)/pubspec.yaml" ]; then \
		echo "Invalid IMPL: '$(IMPL)'"; \
		echo "Run 'make list' to see valid options."; \
		exit 1; \
	fi
	@echo "==> flutter clean in $(IMPL)"
	@cd "$(IMPL)" && flutter clean

clean-all:
	@if [ -z "$(IMPLEMENTATIONS)" ]; then \
		echo "No Flutter implementations found."; \
		exit 1; \
	fi
	@set -e; \
	for app in $(IMPLEMENTATIONS); do \
		echo "==> flutter clean in $$app"; \
		(cd "$$app" && flutter clean); \
	done
