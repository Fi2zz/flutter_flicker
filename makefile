# Flutter Makefile
# Common commands for Flutter development

.PHONY: help run build test clean deps upgrade analyze format doctor install-deps

# Default target
help:
	@echo "Available commands:"
	@echo "  run          - Run the app on connected device"
	@echo "  run-macos    - Run the app on macOS"
	@echo "  run-ios      - Run the app on iOS simulator"
	@echo "  run-android  - Run the app on Android emulator"
	@echo "  run-web      - Run the app on web browser"
	@echo "  build        - Build the app for all platforms"
	@echo "  build-macos  - Build the app for macOS"
	@echo "  build-ios    - Build the app for iOS"
	@echo "  build-android- Build the app for Android"
	@echo "  build-web    - Build the app for web"
	@echo "  test         - Run all tests"
	@echo "  test-unit    - Run unit tests only"
	@echo "  test-widget  - Run widget tests only"
	@echo "  clean        - Clean build files"
	@echo "  deps         - Get dependencies"
	@echo "  upgrade      - Upgrade dependencies"
	@echo "  analyze      - Analyze code"
	@echo "  format       - Format code"
	@echo "  doctor       - Check Flutter installation"
	@echo "  install-deps - Install all dependencies"

# Run commands
run:
	@if [ "$(filter-out $@,$(MAKECMDGOALS))" = "web" ]; then \
		make run-web; \
	elif [ "$(filter-out $@,$(MAKECMDGOALS))" = "macos" ]; then \
		make run-macos; \
	elif [ "$(filter-out $@,$(MAKECMDGOALS))" = "ios" ]; then \
		make run-ios; \
	elif [ "$(filter-out $@,$(MAKECMDGOALS))" = "android" ]; then \
		make run-android; \
	else \
		flutter run; \
	fi

# Handle arguments as targets to avoid "No rule to make target" errors
web macos ios android:
	@:

run-macos:
	flutter run -d macos

run-ios:
	flutter run -d ios

run-android:
	flutter run -d android

run-web:
	flutter run -d chrome --no-web-experimental-hot-reload

# Build commands
build: build-macos build-ios build-android build-web

build-macos:
	flutter build macos

build-ios:
	flutter build ios

build-android:
	flutter build apk
	build-android-bundle

build-android-bundle:
	flutter build appbundle

build-web:
	flutter build web

# Test commands
test:
	flutter test

test-unit:
	flutter test test/unit/

test-widget:
	flutter test test/widget/

test-integration:
	flutter test integration_test/

# Development commands
clean:
	flutter clean
	deps

deps:
	flutter pub get

upgrade:
	flutter pub upgrade

analyze:
	flutter analyze

format:
	dart format .

doctor:
	flutter doctor

install-deps: deps
	flutter precache

# Hot reload (for development)
hot-reload:
	@echo "Hot reload is available when running 'make run'"
	@echo "Press 'r' in the terminal to hot reload"
	@echo "Press 'R' in the terminal to hot restart"

# Generate code (if using code generation)
generate:
	flutter packages pub run build_runner build

generate-watch:
	flutter packages pub run build_runner watch

# Lint and fix
lint:
	dart analyze --fatal-infos

fix:
	dart fix --apply

# Release builds
release-android:
	flutter build apk --release
	flutter build appbundle --release

release-ios:
	flutter build ios --release

release-macos:
	flutter build macos --release

release-web:
	flutter build web --release

# Development setup
setup: install-deps doctor
	@echo "Flutter project setup complete!"

# Clean and reset
reset: clean
	flutter pub cache repair
	deps

# Show Flutter version
version:
	flutter --version

# Show device list
devices:
	flutter devices

# Show emulators
emulators:
	flutter emulators

# Launch emulator (Android)
launch-emulator:
	flutter emulators --launch Pixel_4_API_30

# Performance profiling
profile:
	flutter run --profile

# Debug with DevTools
debug:
	flutter run --debug

# Create new Flutter project (for reference)
# create-project:
# 	flutter create project_name

# Pub commands
pub-get:
	flutter pub get

pub-upgrade:
	flutter pub upgrade

pub-outdated:
	flutter pub outdated

pub-deps:
	flutter pub deps

# Git hooks (optional)
install-hooks:
	@echo "Installing git hooks..."
	@echo "#!/bin/sh" > .git/hooks/pre-commit
	@echo "make analyze" >> .git/hooks/pre-commit
	@echo "make format" >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git hooks installed!"