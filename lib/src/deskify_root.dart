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

  const DeskifyProvider({
    super.key,
    required this.state,
    required super.child,
  });

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
    )] = toggleDevHub;
    _dynamicShortcuts[LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyD,
    )] = toggleDevHub;
    _updateMergedShortcuts();
  }

  /// Rebuilds shortcut mappings.
  void _updateMergedShortcuts() {
    _mergedShortcuts = Map.from(_dynamicShortcuts);
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
  Map<ShortcutActivator, VoidCallback> get registeredShortcuts => _mergedShortcuts;

  // --- Dynamic Context Menu API ---

  /// Triggers a custom, glassmorphic context menu at the specified [position].
  void showContextMenu(BuildContext context, Offset position, List<DeskContextMenuItem> items) {
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
  TargetPlatform get activePlatform => _platformOverride ?? defaultTargetPlatform;

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
                  if (_isContextMenuVisible && _contextMenuItems != null && _contextMenuPosition != null)
                    _buildPremiumContextMenuOverlay(),
                  // Keep Developer Hub Drawer in the stack so it animates nicely
                  if (widget.enableDevHub)
                    _buildDeveloperHubDrawer(),
                  if (widget.enableDevHub && widget.showDevHubButton && !_isDevHubOpen)
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
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 16),
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
        child: Stack(
          children: [
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutQuad,
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * val),
                      alignment: Alignment.topLeft,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white.withValues(alpha: .85)
                        : const Color(0xFF1E293B).withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.withValues(alpha: .2)
                          : Colors.white.withValues(alpha: .1),
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
                        children: items.map((item) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                hideContextMenu();
                                item.onTap();
                              },
                              hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      Icon(
                                        item.icon,
                                        size: 16,
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? Colors.black87
                                              : Colors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          color: const Color(0xFF0F172A).withValues(alpha: .85), // Premium glassmorphic background
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
                            color: const Color(0xFF6366F1).withValues(alpha: .3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

                    // Section 3: Keyboard Shortcuts
                    _buildSectionHeader('ACTIVE KEYBOARD ACCELERATORS'),
                    const SizedBox(height: 12),
                    _buildShortcutList(),
                    const SizedBox(height: 24),

                    // Section 4: Live Viewport Stats
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
      {'name': 'Windows', 'platform': TargetPlatform.windows, 'icon': Icons.window},
      {'name': 'Mobile', 'platform': TargetPlatform.iOS, 'icon': Icons.phone_iphone},
      {'name': 'Linux', 'platform': TargetPlatform.linux, 'icon': Icons.terminal},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: options.map((opt) {
        final isSelected = current == opt['platform'] ||
            (opt['platform'] == TargetPlatform.iOS &&
                (current == TargetPlatform.iOS || current == TargetPlatform.android));
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
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: .3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : [],
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
                      color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: .2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ] : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      device.icon,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        device.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
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
                        color: isSelected ? Colors.white.withValues(alpha: .7) : const Color(0xFF64748B),
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
          final activatorStr = entry.key.toString();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatShortcutText(activatorStr),
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  String _formatShortcutText(String raw) {
    // Make ShortcutActivator string beautiful and developer friendly
    return raw
        .replaceAll('LogicalKeySet#', '')
        .replaceAll('LogicalKeyboardKey#', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' + ', ' + ')
        .replaceAll('Key N', 'N')
        .replaceAll('Key D', 'D')
        .replaceAll('Control Left', 'Ctrl')
        .replaceAll('Meta Left', 'Cmd ⌘')
        .replaceAll('Shift Left', 'Shift ⇧')
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
          _buildStatRow('Device Pixel Ratio', media.devicePixelRatio.toStringAsFixed(2)),
          const Divider(color: Color(0xFF334155)),
          _buildStatRow('Adaptive Layout', DeskPlatform.isDesktop ? 'Desktop Side Rail' : 'Mobile Bottom Bar'),
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

/// A custom focus traversal policy that prevents crashes when focus is requested
/// before the first layout pass has completed (e.g. during asynchronous font loading).
class SafeReadingOrderTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
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
