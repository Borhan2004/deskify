import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/platform_utils.dart';
import 'interaction/right_click_menu.dart';
import 'interaction/hover_decorator.dart';
import 'shell/desk_shell.dart';

/// Predefined device configurations for Deskify's simulator mode.
class DeskifyDeviceConfig {
  final String name;
  final Size? size; // null means full screen
  final IconData icon;

  const DeskifyDeviceConfig({
    required this.name,
    this.size,
    required this.icon,
  });

  static const List<DeskifyDeviceConfig> presets = [
    DeskifyDeviceConfig(
      name: 'Full Screen',
      size: null,
      icon: Icons.fullscreen_rounded,
    ),
    DeskifyDeviceConfig(
      name: 'MacBook Pro 16"',
      size: Size(1440, 900),
      icon: Icons.laptop_mac_rounded,
    ),
    DeskifyDeviceConfig(
      name: 'iPad Pro 12.9"',
      size: Size(834, 1194),
      icon: Icons.tablet_mac_rounded,
    ),
    DeskifyDeviceConfig(
      name: 'iPhone 15 Pro',
      size: Size(393, 852),
      icon: Icons.phone_iphone_rounded,
    ),
    DeskifyDeviceConfig(
      name: 'Google Pixel 8',
      size: Size(412, 892),
      icon: Icons.phone_android_rounded,
    ),
  ];
}

/// An InheritedWidget to expose [DeskifyState] to the widget tree.
class DeskifyProvider extends InheritedWidget {
  final DeskifyState state;

  const DeskifyProvider({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(DeskifyProvider oldWidget) => true;
}

/// The global coordinator widget of the Deskify Suite.
/// Wrap your root [MaterialApp] or [main.dart] content with this widget.
class Deskify extends StatelessWidget {
  /// The app content below this widget.
  final Widget child;

  /// Initial global keyboard shortcuts.
  final Map<ShortcutActivator, VoidCallback>? globalShortcuts;

  /// Initial global right click menu items.
  final List<DeskContextMenuItem>? globalRightClickItems;

  /// Whether to enable the visual developer dashboard overlay.
  /// Defaults to `true` in debug/profile modes, `false` in production.
  final bool enableDevHub;

  /// Whether to show the floating action button to toggle the Developer Hub.
  final bool showDevHubButton;

  /// Default layout constraint maximum width.
  final double defaultMaxWidth;

  /// Creates a [Deskify] coordinator.
  const Deskify({
    super.key,
    required this.child,
    this.globalShortcuts,
    this.globalRightClickItems,
    this.enableDevHub = kDebugMode,
    this.showDevHubButton = kDebugMode,
    this.defaultMaxWidth = 1200,
  });

  /// Access the global [DeskifyState] from any descendant widget.
  static DeskifyState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DeskifyProvider>()?.state;
  }

  @override
  Widget build(BuildContext context) {
    return _DeskifyCoordinator(
      globalShortcuts: globalShortcuts,
      globalRightClickItems: globalRightClickItems,
      enableDevHub: enableDevHub,
      showDevHubButton: showDevHubButton,
      defaultMaxWidth: defaultMaxWidth,
      child: child,
    );
  }
}

class _DeskifyCoordinator extends StatefulWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback>? globalShortcuts;
  final List<DeskContextMenuItem>? globalRightClickItems;
  final bool enableDevHub;
  final bool showDevHubButton;
  final double defaultMaxWidth;

  const _DeskifyCoordinator({
    required this.child,
    this.globalShortcuts,
    this.globalRightClickItems,
    this.enableDevHub = kDebugMode,
    this.showDevHubButton = kDebugMode,
    this.defaultMaxWidth = 1200,
  });

  @override
  State<_DeskifyCoordinator> createState() => DeskifyState();
}

class DeskifyState extends State<_DeskifyCoordinator> {
  // Shortcut states
  final Map<ShortcutActivator, VoidCallback> _dynamicShortcuts = {};
  late Map<ShortcutActivator, VoidCallback> _mergedShortcuts;

  // Context Menu State
  final List<DeskContextMenuItem> _globalRightClickItems = [];
  Offset? _contextMenuPosition;
  List<DeskContextMenuItem>? _contextMenuItems;
  bool _isContextMenuVisible = false;

  // Developer Hub States
  bool _isDevHubOpen = false;
  TargetPlatform? _platformOverride;
  DeskifyDeviceConfig _currentDevice = DeskifyDeviceConfig.presets.first;

  // Simulated metrics
  ThemeMode _simulatedThemeMode = ThemeMode.dark;
  double _simulatedLagMs = 0.0;

  // Adaptive shell settings
  int _shellSelectedIndex = 0;
  List<DeskDestination> _shellDestinations = [];
  ValueChanged<int>? _onShellDestinationSelected;

  @override
  void initState() {
    super.initState();
    if (widget.globalShortcuts != null) {
      _dynamicShortcuts.addAll(widget.globalShortcuts!);
    }
    if (widget.globalRightClickItems != null) {
      _globalRightClickItems.addAll(widget.globalRightClickItems!);
    }
    _updateMergedShortcuts();

    // Register toggle key for Developer Hub: Cmd/Ctrl + Shift + D
    _dynamicShortcuts[LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyD,
        )] =
        toggleDevHub;
    _dynamicShortcuts[LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyD,
        )] =
        toggleDevHub;
    _updateMergedShortcuts();
  }

  /// Rebuilds shortcut mappings.
  void _updateMergedShortcuts() {
    _mergedShortcuts = Map.from(_dynamicShortcuts);
  }

  // --- Simulated Diagnostic Settings API ---

  /// The simulated theme mode (light/dark) toggled from the Dev Hub.
  ThemeMode get simulatedThemeMode => _simulatedThemeMode;

  /// The simulated performance latency added during interactive events.
  double get simulatedLagMs => _simulatedLagMs;

  /// Set the simulated theme mode.
  void setSimulatedThemeMode(ThemeMode mode) {
    setState(() {
      _simulatedThemeMode = mode;
    });
  }

  /// Set the simulated lag in milliseconds.
  void setSimulatedLagMs(double ms) {
    setState(() {
      _simulatedLagMs = ms;
    });
  }

  // --- Dynamic Keyboard Shortcuts API ---

  /// Register a keyboard shortcut dynamically.
  void registerShortcut(ShortcutActivator activator, VoidCallback action) {
    if (_dynamicShortcuts[activator] == action) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _dynamicShortcuts[activator] = action;
        _updateMergedShortcuts();
      });
    });
  }

  /// Unregister a keyboard shortcut.
  void unregisterShortcut(ShortcutActivator activator) {
    if (!_dynamicShortcuts.containsKey(activator)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _dynamicShortcuts.remove(activator);
        _updateMergedShortcuts();
      });
    });
  }

  /// Get currently registered shortcuts for dashboard presentation.
  Map<ShortcutActivator, VoidCallback> get registeredShortcuts =>
      _mergedShortcuts;

  // --- Dynamic Context Menu API ---

  /// Triggers a custom, glassmorphic context menu at the specified [position].
  void showContextMenu(
    BuildContext context,
    Offset position,
    List<DeskContextMenuItem> items,
  ) {
    setState(() {
      _contextMenuPosition = position;
      _contextMenuItems = items;
      _isContextMenuVisible = true;
    });
  }

  /// Dismisses the custom context menu overlay.
  void hideContextMenu() {
    if (_isContextMenuVisible) {
      setState(() {
        _isContextMenuVisible = false;
      });
    }
  }

  // --- Platform Override & Sizing API ---

  /// Gets the currently active target platform, respecting developer overrides.
  TargetPlatform get activePlatform =>
      _platformOverride ?? defaultTargetPlatform;

  /// Sets the runtime target platform override.
  void setPlatformOverride(TargetPlatform? platform) {
    setState(() {
      _platformOverride = platform;
      DeskPlatform.overridePlatform = platform;
    });
  }

  /// Gets the current simulated device preset.
  DeskifyDeviceConfig get currentDevice => _currentDevice;

  /// Set simulated device configuration.
  void setDevicePreset(DeskifyDeviceConfig config) {
    setState(() {
      _currentDevice = config;
    });
  }

  /// Toggles the visual slide-out Developer Hub.
  void toggleDevHub() {
    if (!widget.enableDevHub) return;
    setState(() {
      _isDevHubOpen = !_isDevHubOpen;
    });
  }

  // --- Shell Coordination API ---

  /// Update the global shell destinations and index.
  void updateShellState({
    required List<DeskDestination> destinations,
    required int selectedIndex,
    required ValueChanged<int>? onDestinationSelected,
  }) {
    // Avoid layout thrashing: only update if changed
    if (_shellSelectedIndex != selectedIndex ||
        _shellDestinations != destinations ||
        _onShellDestinationSelected != onDestinationSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _shellSelectedIndex = selectedIndex;
          _shellDestinations = destinations;
          _onShellDestinationSelected = onDestinationSelected;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget appWidget = DeskifyProvider(
      state: this,
      child: Shortcuts(
        shortcuts: _mergedShortcuts.map(
          (key, value) => MapEntry(key, VoidCallbackIntent(value)),
        ),
        child: Actions(
          actions: {
            VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
              onInvoke: (intent) => intent.callback(),
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: hideContextMenu,
            onSecondaryTapDown: (details) {
              if (_globalRightClickItems.isNotEmpty) {
                showContextMenu(
                  context,
                  details.globalPosition,
                  _globalRightClickItems,
                );
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );

    // Apply Simulated Device frame wrapper if inside simulator mode
    if (_currentDevice.size != null) {
      appWidget = _buildSimulatedDeviceFrame(appWidget);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: FocusTraversalGroup(
        policy: SafeReadingOrderTraversalPolicy(),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: appWidget),
                  if (_isContextMenuVisible &&
                      _contextMenuItems != null &&
                      _contextMenuPosition != null)
                    _buildPremiumContextMenuOverlay(),
                  // Keep Developer Hub Drawer in the stack so it animates nicely
                  if (widget.enableDevHub) _buildDeveloperHubDrawer(),
                  if (widget.enableDevHub &&
                      widget.showDevHubButton &&
                      !_isDevHubOpen)
                    _buildFloatingDevButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedDeviceFrame(Widget childWidget) {
    final size = _currentDevice.size!;
    return Container(
      color: const Color(0xFF0F172A), // Dark Canvas background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulated Device Bar
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFEF4444), size: 12),
                  const SizedBox(width: 6),
                  const Icon(Icons.circle, color: Color(0xFFF59E0B), size: 12),
                  const SizedBox(width: 6),
                  const Icon(Icons.circle, color: Color(0xFF10B981), size: 12),
                  const Expanded(child: SizedBox()),
                  Text(
                    '${_currentDevice.name} - ${size.width.toInt()} x ${size.height.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _currentDevice = DeskifyDeviceConfig.presets.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            // The actual App
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .5),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: childWidget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContextMenuOverlay() {
    final pos = _contextMenuPosition!;
    final items = _contextMenuItems!;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: hideContextMenu,
        child: DeskContextMenuOverlayContent(
          position: pos,
          items: items,
          onDismiss: hideContextMenu,
          simulatedLagMs: _simulatedLagMs,
        ),
      ),
    );
  }

  Widget _buildFloatingDevButton() {
    return Positioned(
      right: 24,
      bottom: 24,
      child: GestureDetector(
        onTap: toggleDevHub,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: HoverDecorator(
              onHoverScale: 1.1,
              child: Tooltip(
                message: 'Open Deskify Developer Hub (Cmd+Shift+D)',
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF818CF8).withValues(alpha: .4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: .4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperHubDrawer() {
    final media = MediaQuery.of(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      top: 0,
      right: _isDevHubOpen ? 0 : -360,
      bottom: 0,
      width: 360,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFF0F172A,
          ).withValues(alpha: .85), // Premium glassmorphic background
          border: const Border(
            left: BorderSide(color: Color(0xFF334155), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .5),
              blurRadius: 40,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: .3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskify Developer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Coordination Suite',
                            style: TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: toggleDevHub,
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  children: [
                    // Section 1: Platform Simulation
                    _buildSectionHeader('SIMULATED PLATFORM OVERRIDE'),
                    const SizedBox(height: 12),
                    _buildPlatformSelector(),
                    const SizedBox(height: 24),

                    // Section 2: Layout Simulator
                    _buildSectionHeader('DEVICE FRAME SIMULATOR'),
                    const SizedBox(height: 12),
                    _buildDeviceSimulatorList(),
                    const SizedBox(height: 24),

                    // Section 3: Simulated Latency & Theme Controls
                    _buildSectionHeader('DIAGNOSTIC SIMULATIONS'),
                    const SizedBox(height: 12),
                    _buildDiagnosticSimulators(),
                    const SizedBox(height: 24),

                    // Section 4: Keyboard Shortcuts
                    _buildSectionHeader('ACTIVE KEYBOARD ACCELERATORS'),
                    const SizedBox(height: 12),
                    _buildShortcutList(),
                    const SizedBox(height: 24),

                    // Section 5: Live Viewport Stats
                    _buildSectionHeader('LIVE SYSTEM DIAGNOSTICS'),
                    const SizedBox(height: 12),
                    _buildSystemStatsCard(media),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildPlatformSelector() {
    final current = activePlatform;
    final List<Map<String, dynamic>> options = [
      {'name': 'macOS', 'platform': TargetPlatform.macOS, 'icon': Icons.apple},
      {
        'name': 'Windows',
        'platform': TargetPlatform.windows,
        'icon': Icons.window,
      },
      {
        'name': 'Mobile',
        'platform': TargetPlatform.iOS,
        'icon': Icons.phone_iphone,
      },
      {
        'name': 'Linux',
        'platform': TargetPlatform.linux,
        'icon': Icons.terminal,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: options.map((opt) {
        final isSelected =
            current == opt['platform'] ||
            (opt['platform'] == TargetPlatform.iOS &&
                (current == TargetPlatform.iOS ||
                    current == TargetPlatform.android));
        return HoverDecorator(
          onHoverScale: 1.03,
          child: GestureDetector(
            onTap: () {
              if (isSelected) {
                setPlatformOverride(null);
              } else {
                setPlatformOverride(opt['platform'] as TargetPlatform);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4F46E5).withValues(alpha: .9)
                    : const Color(0xFF1E293B).withValues(alpha: .6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF334155).withValues(alpha: .5),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: .3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    opt['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFE2E8F0),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeviceSimulatorList() {
    return Column(
      children: DeskifyDeviceConfig.presets.map((device) {
        final isSelected = _currentDevice.name == device.name;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: HoverDecorator(
            onHoverScale: 1.02,
            child: GestureDetector(
              onTap: () => setDevicePreset(device),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4F46E5).withValues(alpha: .9)
                      : const Color(0xFF1E293B).withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF818CF8)
                        : const Color(0xFF334155).withValues(alpha: .5),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF4F46E5,
                            ).withValues(alpha: .2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      device.icon,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        device.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Text(
                      device.size == null
                          ? 'Fluid'
                          : '${device.size!.width.toInt()} x ${device.size!.height.toInt()}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: .7)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiagnosticSimulators() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: .5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Simulated Theme',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _simulatedThemeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _simulatedThemeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: const Color(0xFF818CF8),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setSimulatedThemeMode(
                        _simulatedThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simulated Network/UI Lag',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    '${_simulatedLagMs.toInt()} ms',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: _simulatedLagMs,
                  min: 0.0,
                  max: 1000.0,
                  divisions: 20,
                  activeColor: const Color(0xFF6366F1),
                  inactiveColor: const Color(0xFF334155),
                  onChanged: (val) {
                    setSimulatedLagMs(val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutList() {
    if (_mergedShortcuts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'No shortcuts registered',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: .5),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: _mergedShortcuts.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatShortcutText(entry.key),
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active Callback',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatShortcutText(ShortcutActivator activator) {
    if (activator is SingleActivator) {
      final List<String> modifiers = [];
      if (activator.control) modifiers.add('Ctrl');
      if (activator.meta) modifiers.add('Cmd ⌘');
      if (activator.shift) modifiers.add('Shift ⇧');
      if (activator.alt) modifiers.add('Alt ⌥');
      modifiers.add(activator.trigger.keyLabel.toUpperCase());
      return modifiers.join(' + ');
    } else if (activator is LogicalKeySet) {
      final keysStr = activator.keys.map((k) {
        final label = k.keyLabel;
        if (label == 'Control Left' || label == 'Control Right') return 'Ctrl';
        if (label == 'Meta Left' || label == 'Meta Right') return 'Cmd ⌘';
        if (label == 'Shift Left' || label == 'Shift Right') return 'Shift ⇧';
        if (label == 'Alt Left' || label == 'Alt Right') return 'Alt ⌥';
        return label.toUpperCase();
      }).join(' + ');
      return keysStr;
    }

    return activator.toString()
        .replaceAll('LogicalKeySet#', '')
        .replaceAll('LogicalKeyboardKey#', '')
        .replaceAll('SingleActivator#', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('Key ', '')
        .replaceAll('Control Left', 'Ctrl')
        .replaceAll('Meta Left', 'Cmd ⌘')
        .replaceAll('Shift Left', 'Shift ⇧')
        .replaceAll('Alt Left', 'Alt ⌥')
        .toUpperCase();
  }

  Widget _buildSystemStatsCard(MediaQueryData media) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: .5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildStatRow('Screen Width', '${media.size.width.toInt()} px'),
          const Divider(color: Color(0xFF334155)),
          _buildStatRow('Screen Height', '${media.size.height.toInt()} px'),
          const Divider(color: Color(0xFF334155)),
          _buildStatRow(
            'Device Pixel Ratio',
            media.devicePixelRatio.toStringAsFixed(2),
          ),
          const Divider(color: Color(0xFF334155)),
          _buildStatRow(
            'Adaptive Layout',
            DeskPlatform.isDesktop ? 'Desktop Side Rail' : 'Mobile Bottom Bar',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// A stateful menu overlay that supports submenus, checkboxes, dividers, disabled items,
/// and includes viewport boundary collision safety calculations.
class DeskContextMenuOverlayContent extends StatefulWidget {
  final Offset position;
  final List<DeskContextMenuItem> items;
  final VoidCallback onDismiss;
  final double simulatedLagMs;

  const DeskContextMenuOverlayContent({
    super.key,
    required this.position,
    required this.items,
    required this.onDismiss,
    required this.simulatedLagMs,
  });

  @override
  State<DeskContextMenuOverlayContent> createState() => _DeskContextMenuOverlayContentState();
}

class _DeskContextMenuOverlayContentState extends State<DeskContextMenuOverlayContent> {
  DeskContextMenuItem? _hoveredSubmenuItem;
  Offset? _submenuPosition;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double menuWidth = 220.0;

    // Calculate height of the menu
    double menuHeight = 12.0; // padding
    for (final item in widget.items) {
      if (item.type == DeskContextMenuType.divider) {
        menuHeight += 8.0;
      } else {
        menuHeight += 38.0;
      }
    }

    double left = widget.position.dx;
    double top = widget.position.dy;
    bool alignLeft = false;

    // Boundary check for bottom & right edges
    if (left + menuWidth > screenSize.width) {
      left = left - menuWidth;
      alignLeft = true;
      if (left < 8) left = 8;
    }
    if (top + menuHeight > screenSize.height) {
      top = screenSize.height - menuHeight - 16;
      if (top < 8) top = 8;
    }

    return Stack(
      children: [
        // Main Context Menu Panel
        Positioned(
          left: left,
          top: top,
          child: _buildMenuPanel(
            items: widget.items,
            width: menuWidth,
            onHoverItem: (item, itemIndex, itemRect) {
              if (item.type == DeskContextMenuType.submenu && item.enabled) {
                setState(() {
                  _hoveredSubmenuItem = item;
                  double subX = alignLeft ? left - menuWidth + 4 : left + menuWidth - 4;
                  double subY = top + (itemIndex * 38.0) + 6.0;
                  _submenuPosition = Offset(subX, subY);
                });
              } else {
                setState(() {
                  _hoveredSubmenuItem = null;
                  _submenuPosition = null;
                });
              }
            },
          ),
        ),

        // Cascading Submenu Panel
        if (_hoveredSubmenuItem != null && _submenuPosition != null)
          _buildSubmenuPanel(screenSize, alignLeft),
      ],
    );
  }

  Widget _buildSubmenuPanel(Size screenSize, bool alignLeft) {
    final submenuItems = _hoveredSubmenuItem!.submenuItems ?? [];
    const double menuWidth = 220.0;

    double subHeight = 12.0;
    for (final item in submenuItems) {
      if (item.type == DeskContextMenuType.divider) {
        subHeight += 8.0;
      } else {
        subHeight += 38.0;
      }
    }

    double subX = _submenuPosition!.dx;
    double subY = _submenuPosition!.dy;

    // Boundary safety for submenu bottom edge
    if (subY + subHeight > screenSize.height) {
      subY = screenSize.height - subHeight - 16;
      if (subY < 8) subY = 8;
    }
    // Boundary safety for submenu horizontal edge
    if (alignLeft) {
      if (subX < 8) subX = 8;
    } else {
      if (subX + menuWidth > screenSize.width) {
        subX = _submenuPosition!.dx - (menuWidth * 2) + 8;
        if (subX < 8) subX = 8;
      }
    }

    return Positioned(
      left: subX,
      top: subY,
      child: _buildMenuPanel(
        items: submenuItems,
        width: menuWidth,
        onHoverItem: (_, __, ___) {},
      ),
    );
  }

  Widget _buildMenuPanel({
    required List<DeskContextMenuItem> items,
    required double width,
    required void Function(DeskContextMenuItem item, int index, Rect rect) onHoverItem,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: .85)
            : Colors.white.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .1)
              : Colors.grey.withValues(alpha: .2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final item = items[index];

              if (item.type == DeskContextMenuType.divider) {
                return Divider(
                  height: 8,
                  thickness: 1,
                  color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                );
              }

              return MouseRegion(
                onEnter: (_) {
                  onHoverItem(item, index, Rect.fromLTWH(0, index * 38.0, width, 38.0));
                },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.enabled
                        ? () async {
                            if (widget.simulatedLagMs > 0.0) {
                              await Future.delayed(Duration(milliseconds: widget.simulatedLagMs.toInt()));
                            }
                            widget.onDismiss();
                            if (item.onTap != null) {
                              item.onTap!();
                            }
                          }
                        : null,
                    hoverColor: theme.colorScheme.primary.withValues(alpha: .1),
                    child: Opacity(
                      opacity: item.enabled ? 1.0 : 0.4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            if (item.type == DeskContextMenuType.checkbox) ...[
                              Icon(
                                item.isChecked == true
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                            ] else if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: 16,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                              const SizedBox(width: 12),
                            ] else ...[
                              const SizedBox(width: 0),
                            ],
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            if (item.type == DeskContextMenuType.submenu)
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// A custom focus traversal policy that prevents crashes when focus is requested
/// before the first layout pass has completed (e.g. during asynchronous font loading).
class SafeReadingOrderTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    for (final node in descendants) {
      final context = node.context;
      if (context != null) {
        final renderObject = context.findRenderObject();
        if (renderObject is RenderBox && !renderObject.hasSize) {
          // Return unsorted descendants to safely bypass sorting when rendering is pending.
          return descendants;
        }
      }
    }
    try {
      return super.sortDescendants(descendants, currentNode);
    } catch (_) {
      return descendants;
    }
  }
}
