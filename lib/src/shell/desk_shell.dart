import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import '../deskify_root.dart';

/// A destination for the [DeskShell] navigation.
class DeskDestination {
  /// The label of the destination.
  final String label;

  /// The icon of the destination.
  final IconData icon;

  /// The icon of the destination when selected.
  final IconData? selectedIcon;

  /// Creates a [DeskDestination].
  const DeskDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}

/// The main adaptive wrapper for deskify apps.
///
/// It automatically switches between a [NavigationBar] on mobile/narrow screens
/// and an animated [NavigationRail] (sidebar) on desktop/wide screens.
class DeskShell extends StatefulWidget {
  /// The widget to display as the main content.
  final Widget child;

  /// The destinations for the navigation.
  final List<DeskDestination> destinations;

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// The breakpoint for switching between sidebar and bottom bar.
  final double breakpoint;

  /// The title of the app, shown in the sidebar header when expanded.
  final Widget? title;

  /// The title shown in the sidebar header when collapsed (icon/logo).
  final Widget? collapsedTitle;

  /// The trailing widget for the sidebar.
  final Widget? trailing;

  /// An optional platform-adaptive title bar (such as [DeskTitleBar]).
  final PreferredSizeWidget? titleBar;

  /// Whether the sidebar navigation rail can be collapsed.
  final bool collapsible;

  /// Creates a [DeskShell].
  const DeskShell({
    super.key,
    required this.child,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.breakpoint = 600,
    this.title,
    this.collapsedTitle,
    this.trailing,
    this.titleBar,
    this.collapsible = true,
  });

  @override
  State<DeskShell> createState() => _DeskShellState();
}

class _DeskShellState extends State<DeskShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final deskify = Deskify.of(context);
    if (deskify != null) {
      deskify.updateShellState(
        destinations: widget.destinations,
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
      );
    }

    final isWide = MediaQuery.of(context).size.width >= widget.breakpoint;

    if (isWide) {
      return Scaffold(
        appBar: widget.titleBar,
        body: Row(
          children: [
            _buildSidebar(context),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.015, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(widget.selectedIndex),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: widget.titleBar,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: widget.destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: d.selectedIcon != null ? Icon(d.selectedIcon) : null,
            label: d.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final bool isMac = DeskPlatform.isMacOS;
    final bool isWin = DeskPlatform.isWindows;

    Color? backgroundColor;
    if (isMac) {
      backgroundColor = Theme.of(context).brightness == Brightness.light
          ? Colors.grey[100]?.withValues(alpha: .9)
          : Colors.grey[900]?.withValues(alpha: .9);
    } else if (isWin) {
      backgroundColor = Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .5);
    }

    final double sidebarWidth = _isCollapsed ? 80.0 : 280.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .1),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return NavigationRail(
                extended: !_isCollapsed,
                backgroundColor: Colors.transparent,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                minExtendedWidth: 280,
                labelType: NavigationRailLabelType.none,
                leading: widget.title != null || widget.collapsedTitle != null
                    ? Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 8,
                        ),
                        child: _isCollapsed
                            ? (widget.collapsedTitle ?? const Icon(Icons.apps_rounded, size: 24))
                            : widget.title,
                      )
                    : null,
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                        left: 8,
                        right: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.trailing != null) ...[
                            _isCollapsed
                                ? const SizedBox.shrink() // hide custom trailing on collapse
                                : widget.trailing!,
                            const SizedBox(height: 16),
                          ],
                          if (widget.collapsible)
                            IconButton(
                              icon: Icon(
                                _isCollapsed
                                    ? Icons.chevron_right_rounded
                                    : Icons.chevron_left_rounded,
                              ),
                              tooltip: _isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                              onPressed: () {
                                setState(() {
                                  _isCollapsed = !_isCollapsed;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                destinations: widget.destinations.map((d) {
                  return NavigationRailDestination(
                    icon: Icon(d.icon, size: 22),
                    selectedIcon: Icon(d.selectedIcon ?? d.icon, size: 22),
                    label: Text(
                      d.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
