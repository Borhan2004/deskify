import 'package:flutter/material.dart';
import '../deskify_root.dart';

/// A simple context menu builder for desktop-specific right-click actions.
class DeskRightClickMenu extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The menu items to show when the user right-clicks.
  final List<DeskContextMenuItem> items;

  /// Creates a [DeskRightClickMenu].
  const DeskRightClickMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showMenu(context, details.globalPosition),
      child: child,
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final deskify = Deskify.of(context);
    if (deskify != null) {
      deskify.showContextMenu(context, position, items);
      return;
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items.map((item) {
        return PopupMenuItem(
          onTap: item.onTap,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18),
                const SizedBox(width: 12),
              ],
              Text(item.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// A menu item for the context menu.
class DeskContextMenuItem {
  /// The label of the menu item.
  final String label;

  /// The icon of the menu item.
  final IconData? icon;

  /// The callback to invoke when the menu item is selected.
  final VoidCallback onTap;

  /// Creates a [DeskContextMenuItem].
  const DeskContextMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
  });
}
