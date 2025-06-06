# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Type

This is a Flutter package project (`http_sandbox_viewer`) containing a Dart library. The main library file is at `lib/http_sandbox_viewer.dart`.

## Common Development Commands

### Dependencies and Setup
- `flutter pub get` - Install dependencies
- `flutter pub deps` - Show dependency tree

### Testing
- `flutter test` - Run all tests
- `flutter test test/http_sandbox_viewer_test.dart` - Run a specific test file

### Code Quality
- `flutter analyze` - Run static analysis (uses flutter_lints ruleset)
- `dart format .` - Format all Dart code

### Building and Publishing
- `flutter pub publish --dry-run` - Test package publishing
- `flutter pub publish` - Publish package to pub.dev

## Architecture

The package currently contains a minimal `Calculator` class as a placeholder. The project structure follows standard Flutter package conventions:

- `lib/` - Main library code, with the primary export at `lib/http_sandbox_viewer.dart`
- `test/` - Unit tests using the `flutter_test` framework
- `pubspec.yaml` - Package configuration with Flutter SDK ^3.7.2 requirement

The project uses `flutter_lints` for code analysis and follows standard Flutter package development practices.