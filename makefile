# Flutter Makefile
# Common commands for Flutter development

.PHONY: help run test clean deps upgrade  doctor install-deps format analyze

# Default target
help:
	@echo "Available commands:"
	@echo "  run          - Run the app on connected device"
	@echo "  run-macos    - Run the app on macOS"
	@echo "  run-ios      - Run the app on iOS simulator"
	@echo "  run-android  - Run the app on Android emulator"
	@echo "  run-web      - Run the app on web browser"
	@echo "  test         - Run all tests"
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
	cd example && flutter run -d macos

run-ios:
	cd example && flutter run -d ios

run-android:
	cd example && flutter run -d android

run-web:
	cd example && flutter run -d chrome --no-web-experimental-hot-reload

# Build commands



# Test commands
test:
	flutter test

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
	dart format lib/ test/
	dart fix --apply


doctor:
	flutter doctor

install-deps: deps
	flutter precache




# Lint and fix
lint:
	dart analyze --fatal-infos

fix:
	dart fix --apply



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
