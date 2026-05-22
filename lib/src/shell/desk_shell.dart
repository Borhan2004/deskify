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
/// and a [NavigationRail] (sidebar) on desktop/wide screens.
class DeskShell extends StatelessWidget {
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

  /// The title of the app, shown in the sidebar header.
  final Widget? title;

  /// The trailing widget for the sidebar.
  final Widget? trailing;

  /// Creates a [DeskShell].
  const DeskShell({
    super.key,
    required this.child,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.breakpoint = 600,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final deskify = Deskify.of(context);
    if (deskify != null) {
      deskify.updateShellState(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      );
    }

    final isWide = MediaQuery.of(context).size.width >= breakpoint;


    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((d) {
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
    // Platform-specific styling logic
    final bool isMac = DeskPlatform.isMacOS;
    final bool isWin = DeskPlatform.isWindows;

    Color? backgroundColor;
    if (isMac) {
      // macOS style: slightly translucent or greyish
      backgroundColor = Theme.of(context).brightness == Brightness.light
          ? Colors.grey[100]?.withValues(alpha: .9)
          : Colors.grey[900]?.withValues(alpha: .9);
    } else if (isWin) {
      // Windows style: Solid acrylic-like
      backgroundColor = Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .5);
    }

    return Container(
      width: 280,
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
          child: NavigationRail(
            extended: true,
            backgroundColor: Colors.transparent,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            minExtendedWidth: 280,
            labelType: NavigationRailLabelType.none,
            leading: title != null
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    child: title,
                  )
                : null,
            trailing: trailing != null
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                          left: 16,
                          right: 16,
                        ),
                        child: trailing,
                      ),
                    ),
                  )
                : null,
            destinations: destinations.map((d) {
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
          ),
        ),
      ),
    );
  }
}
