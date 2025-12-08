# DevTools Companion App - Agent Guide

This document provides guidance for AI agents interacting with the DevTools Companion App codebase.

## Project Overview

The DevTools Companion App is a Flutter application designed to assist contributors to Dart & Flutter DevTools. It provides a set of screens that correspond to the various panels in DevTools, allowing for isolated development and testing of UI components and features.

## Getting Started

### Running the Application

To run the application, use the standard Flutter command:

```sh
flutter run
```

### Running Tests

The project contains widget and integration tests.

- **Widget tests:** `flutter test`
- **Integration tests:** `flutter test integration_test`

## Project Structure

The project follows a standard Flutter project structure.

- `lib/main.dart`: The entry point of the application. It sets up the `ThemeNotifier` and the `ShadApp`.
- `lib/src/scaffold/`: Contains the core application shell, routing, and theme management.
  - `app_shell.dart`: Defines the main application layout, including the `AppBar` and `AppDrawer`.
  - `router.dart`: Manages navigation for the app. All routes are defined in the `AppRoute` enum.
  - `theme_notifier.dart`: Manages the application's theme (light/dark mode).
- `lib/src/screens/`: Contains the individual screens for each DevTools panel. Each screen is a separate feature module.
- `lib/src/shared/`: Contains shared widgets, utilities, and other code used across multiple screens.
- `assets/`: Contains static assets like icons and fonts.
- `test/`: Contains widget tests.
- `integration_test/`: Contains integration tests.

## Architecture

### State Management

The application uses the `provider` package for state management, primarily with `ChangeNotifier`. A key example is `ThemeNotifier`, which manages the application's theme.

### UI Framework

The application's UI is built using the `shadcn_ui` package, which provides a set of pre-built, customizable UI components.

### Routing

Routing is handled by the `onGenerateRoute` function in `lib/src/scaffold/router.dart`. The available routes are defined in the `AppRoute` enum. To add a new route, you must:

1.  Add a new value to the `AppRoute` enum.
2.  Add a new case in the `onGenerateRoute` function to return the new screen.
3.  Add the new route to the `AppDrawer` in `lib/src/scaffold/app_drawer.dart`.

## Dependencies

- `provider`: For state management.
- `shadcn_ui`: For UI components.
- `flutter_markdown`: For rendering Markdown content.
- `dio` & `http`: For making HTTP requests.
- `flutter_animate`: For animations.
- `flutter_driver`, `integration_test`: For testing.

## Assets

- **Icons**: Located in `assets/icons/`. These are used in the `AppDrawer` and other parts of the UI.
- **Fonts**: The app uses the Roboto and RobotoMono fonts, located in `assets/fonts/`.

## How to add a new screen

1.  Create a new directory in `lib/src/screens/` for your new feature.
2.  Create a new screen widget in that directory.
3.  Add a new route to the `AppRoute` enum in `lib/src/scaffold/router.dart`.
4.  Add a case for the new route in the `onGenerateRoute` function to return your new screen wrapped in an `AppShell`.
5.  (Optional) Add a new entry to the `AppDrawer` in `lib/src/scaffold/app_drawer.dart` to make your new screen accessible from the navigation drawer.
