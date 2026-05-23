# Deskify 🚀

[![Pub Version](https://img.shields.io/pub/v/deskify)](https://pub.dev/packages/deskify)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform Support](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-blue.svg)](https://pub.dev/packages/deskify)
[![Designed with Tahoea Liquid Glass](https://img.shields.io/badge/designed%20with-tahoea__liquid__glass%20%5E0.0.8-pink.svg)](https://pub.dev/packages/tahoea_liquid_glass)

**Deskify** is a premium, designer-grade Mobile-to-Desktop Master Suite that solves the common UX and layout gaps when porting mobile Flutter applications to Desktop (macOS, Windows, Linux) and Web. 

It provides an adaptive design foundation, keyboard accelerators, robust context menus, hover styling, and platform emulation tools that feel native, interactive, and visually breath-taking.

---

## 🎨 Designed with Tahoea Liquid Glass

We are proud to highlight that the stunning glassmorphism, dynamic backdrop blurs, and organic wave shaders featured throughout the Deskify design system and example application are built on top of:

```yaml
tahoea_liquid_glass: ^0.0.8
```

This designer-grade package powers our visual assets, ensuring high-fidelity rendering, smooth specular gloss sweeps, and real-time GPU-accelerated blur effects across all operating systems.

---

## 📺 Screenshots & Live Experience

### 🎛️ 1. Control Center Widget Dashboard
A complete, gorgeous dashboard demonstrating Glassmorphism in action. Features responsive grid layouts, custom weather widgets, live iOS 18-inspired sliders (brightness and volume), connectivity controls, and dynamic wallpaper theme selectors.
![Deskify Control Center](https://raw.githubusercontent.com/Borhan2004/deskify/main/doc/screenshots/control_center.png)

### 🧪 2. Wave Laboratory (Optics & Physics Lab)
An interactive laboratory to design custom variations of glass materials dynamically. Tweak physics parameters like wave speed, wave amplitude, wave frequency, along with optical properties such as Gaussian blur strength, gloss highlight opacity, and prismatic border width in real-time.
![Deskify Wave Laboratory](https://raw.githubusercontent.com/Borhan2004/deskify/main/doc/screenshots/wave_laboratory.png)

### 📊 3. Engine Telemetry Hub
A hardware and shader pipeline diagnostic screen providing live cost reports, render rate trackers (up to 120 FPS), engine memory load indicators, and detailed runtime platform override metrics.
![Deskify Engine Telemetry](https://raw.githubusercontent.com/Borhan2004/deskify/main/doc/screenshots/telemetry_hub.png)

### 🛠️ 4. Platform Emulation & Developer Sidebar
Includes a floating live developer coordination suite that lets you hot-override the simulated platform (macOS, Windows, Mobile, Linux), emulate different viewports (Full Screen Fluid, MacBook Pro 16", iPad Pro 12.9", iPhone 15 Pro, Google Pixel 8), and monitor active keyboard accelerators and system diagnostics.
![Deskify Developer Suite](https://raw.githubusercontent.com/Borhan2004/deskify/main/doc/screenshots/dev_panel.png)

---

## ✨ Key Features

### 🏢 1. Adaptive "Desk-Shell" (`DeskShell`)
Stop building separate UIs for mobile and desktop screens. The `DeskShell` layout engine automatically switches between:
- **Desktop**: A persistent sidebar with custom platform-aware aesthetics, glassmorphic blurred panels, and a customizable header/footer.
- **Mobile**: A standard, finger-friendly Material 3 Bottom Navigation Bar.

### 🖱️ 2. Desktop Interaction Kit
- **`HoverDecorator`**: Inject custom scale transitions, custom border highlights, and opacity shifts on mouse hover with a single wrapper widget.
- **`DeskAccelerator` API**: Map global keyboard hotkeys (e.g., `Ctrl + N` or `Cmd + Shift + D`) that work seamlessly across macOS, Windows, Linux, and Web.
- **`DeskContextMenu` (Right-Click Engine)**: A native-feeling context menu constructor supporting custom icons, dividers, sub-labels, and hover interactions.
- **`DeskConstraintBox`**: Intuitively constrains mobile layouts on widescreen monitors, ensuring your content is beautifully centered instead of awkwardly stretched.

---

## 🚀 Getting Started

Add `deskify` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  deskify: ^0.1.0
  tahoea_liquid_glass: ^0.0.8 # Recommended for premium glassmorphic UI
```

Run the following command to fetch the packages:

```bash
flutter pub get
```

---

## 🛠️ Usage Example

Here is a quick example demonstrating how easy it is to wrap your application with the **Deskify** ecosystem:

```dart
import 'package:flutter/material.dart';
import 'package:deskify/deskify.dart';
import 'package:tahoea_liquid_glass/tahoea_liquid_glass.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the Deskify root to enable global dev hubs and platform overrides
    return Deskify(
      enableDevHub: true,
      showDevHubButton: true,
      globalRightClickItems: [
        DeskContextMenuItem(
          label: 'Refresh Workspace',
          icon: Icons.refresh,
          onTap: () => print('Workspace Refreshed!'),
        ),
      ],
      child: MaterialApp(
        title: 'Deskify Premium Demo',
        theme: ThemeData.dark(useMaterial3: true),
        home: const AppRootScreen(),
      ),
    );
  }
}

class AppRootScreen extends StatefulWidget {
  const AppRootScreen({super.key});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

class _AppRootScreenState extends State<AppRootScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 2. Set up global shortcut triggers in your view
    return DeskAccelerator(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): () {
          print('Cmd/Ctrl + N shortcut triggered!');
        },
      },
      // 3. Assemble the adaptive shell
      child: DeskShell(
        title: const Text('Admin Suite Pro'),
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          DeskDestination(
            icon: Icons.grid_view_rounded,
            label: 'Control Room',
          ),
          DeskDestination(
            icon: Icons.settings_rounded,
            label: 'System Parameters',
          ),
        ],
        child: DeskConstraintBox(
          maxWidth: 1200,
          child: Center(
            child: HoverDecorator(
              onHoverScale: 1.08,
              onHoverOpacity: 0.9,
              child: TahoeaLiquidGlass(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(24),
                child: const Text(
                  'Hover over this beautiful Glassmorphic Container!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 📱 Detailed Component Overview

### 1. `Deskify` (Global Foundation)
A required top-level inherited widget that coordinates the simulated platform overrides, diagnostic systems, global desktop configurations, and context-menu overrides.

### 2. `DeskShell` (Layout & Shell)
Handles responsive resizing transitions, platform adaptive drawers, sidebar layouts, and seamless tab transitions. Supports standard `AppBar` elements and platform-aware translucent details.

### 3. `HoverDecorator` (Smooth Interactions)
Provides professional desktop styling feedbacks (e.g. mouse pointers, scale animations, color shifts, and shadow changes) when a user hovers over interactive cards, buttons, or list tiles.

### 4. `DeskAccelerator` (Keyboard Mapping)
A widget that listens for platform-level keyboard events and maps them to custom callback actions. It provides automatic fallback keys when running on macOS vs Windows/Linux.

### 5. `DeskConstraintBox` (Max-Width Bounds)
A container widget that caps the width of wide pages and pads the margins, preserving readability and layout elegance on large high-resolution desktop monitors.

---

## 💻 Platforms

Deskify is thoroughly optimized and verified for:
*   ✅ **macOS** (Premium platform-native glassmorphism and key bindings)
*   ✅ **Windows** (Fluent acrylic aesthetics and desktop interaction patterns)
*   ✅ **Linux** (Clean adaptive styling and high performance rendering)
*   ✅ **Web** (Full responsive flexibility and browser click-handler integration)
*   ✅ **iOS & Android** (Standard Material 3 adaptive fallbacks)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
