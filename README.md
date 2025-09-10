# ZenTimer - iOS Timer App

A minimalist, elegant timer application for iOS built with SwiftUI, inspired by zen principles and modern design.

## Features

- **Circular Timer Interface**: Intuitive circular progress indicator with draggable handle
- **Gesture Control**: Drag around the circle to set timer duration (1-60 minutes)
- **Beautiful Design**: Orange-to-red gradient background with glass morphism effects
- **Smooth Animations**: 60fps animations with haptic feedback
- **Timer Controls**: Play/pause, reset, and fine-tune adjustments
- **Accessibility**: VoiceOver support and Dynamic Type compatibility

## Technical Implementation

### Architecture
- **SwiftUI + MVVM**: Clean separation of concerns with ObservableObject view model
- **iOS 15.0+**: Modern iOS features including `.ultraThinMaterial` backdrop blur
- **Gesture Handling**: Custom drag gesture with coordinate-to-angle conversion
- **Timer Management**: Precise countdown with automatic completion handling

### Key Components

- **TimerViewModel**: Central state management for timer logic and user interactions
- **CircularProgressView**: Custom SwiftUI shapes for progress visualization
- **DragGestureHandler**: Coordinate calculations for circular drag interactions
- **ControlButtons**: Glass morphism UI controls with haptic feedback

### Design Specifications

- **Colors**: Orange (#FB923C) to Red (#DC2626) gradient background
- **Typography**: Ultra-light system font with monospaced digits
- **Layout**: 320x320pt timer circle with 6pt stroke width
- **Effects**: Backdrop blur, rounded corners, and subtle shadows

## Getting Started

1. Open `ZenTimer/ZenTimer.xcodeproj` in Xcode 15.0+
2. Select your target device or simulator
3. Build and run the project (⌘R)

## File Structure

```
ZenTimer/
├── ZenTimer.xcodeproj/        # Xcode project file
└── ZenTimer/                  # Source code directory
    ├── ZenTimerApp.swift          # App entry point
    ├── ContentView.swift          # Main content wrapper
    ├── TimerView.swift           # Primary timer interface
    ├── TimerViewModel.swift      # Business logic and state management
    ├── CircularProgressView.swift # Custom progress shapes and handle
    ├── ControlButtons.swift      # UI controls and adjustments
    └── DragGestureHandler.swift  # Gesture coordinate calculations
```

## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Design Inspiration

This iOS implementation faithfully recreates the design and functionality from the original React/TypeScript prototype while adapting patterns to SwiftUI conventions and iOS interaction paradigms.