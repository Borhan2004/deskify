# Deskify 🚀

[![Pub Version](https://img.shields.io/pub/v/deskify)](https://pub.dev/packages/deskify)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

**Deskify** is a premium Flutter suite designed to solve the common UX gaps when moving mobile applications to Desktop (macOS, Windows, Linux) and Web. It provides a "Top-Notch" design foundation that feels native, interactive, and visually stunning.

## ✨ Key Features

### 🏢 Adaptive "Desk-Shell"
Stop building separate UIs for mobile and desktop. Deskify's Shell intelligently switches between:
- **Desktop**: A persistent, glassmorphic sidebar with platform-aware aesthetics (translucent for macOS, Fluent for Windows).
- **Mobile**: A standard Material 3 Navigation Bar.

### 🖱️ Desktop Interaction Kit
- **Hover Decorator**: Add interactive scale, opacity, and color effects with a single property.
- **Accelerator API**: Define global keyboard shortcuts (e.g., `Ctrl+N`) that work across all OSs.
- **Right-Click Engine**: Context menu builder for desktop-specific secondary actions.
- **Desk-Constraint Box**: Automatically prevents "stretched" mobile layouts on wide screens.

### 🎨 Designer-Grade Aesthetics
Built-in support for:
- Glassmorphism (Backdrop Blurs)
- Modern Typography (Plus Jakarta Sans support)
- Elegant Gradients & Subtle Micro-animations

## 🚀 Getting Started

Add `deskify` to your `pubspec.yaml`:

```yaml
dependencies:
  deskify: ^0.1.0
```

## 🛠️ Usage Example

```dart
DeskShell(
  title: Text('My Pro App'),
  destinations: [
    DeskDestination(icon: Icons.dashboard, label: 'Dashboard'),
    DeskDestination(icon: Icons.settings, label: 'Settings'),
  ],
  child: MainDashboardContent(),
)
```

## 📱 Platforms
- ✅ **macOS** (Premium Glassmorphism)
- ✅ **Windows** (Fluent Design)
- ✅ **Linux** (Clean Adaptive)
- ✅ **Web** (Full responsiveness)
- ✅ **iOS & Android** (Native Mobile Feel)

## 📄 License
MIT License - feel free to use this in your commercial projects!
