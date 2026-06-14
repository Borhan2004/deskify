import 'package:flutter/material.dart';
import '../deskify_root.dart';

/// The type of context menu item.
enum DeskContextMenuType {
  /// A standard clickable item.
  normal,

  /// A horizontal separator line.
  divider,

  /// An item that opens a secondary cascading submenu.
  submenu,

  /// An item with a checkbox toggle.
  checkbox,
}

/// A menu item for the context menu.
class DeskContextMenuItem {
  /// The label of the menu item.
  final String label;

  /// The icon of the menu item.
  final IconData? icon;

  /// The callback to invoke when the menu item is selected.
  final VoidCallback? onTap;

  /// The type of context menu item.
  final DeskContextMenuType type;

  /// Sub-items to display when this is a [DeskContextMenuType.submenu].
  final List<DeskContextMenuItem>? submenuItems;

  /// Whether the checkbox is checked (only for [DeskContextMenuType.checkbox]).
  final bool? isChecked;

  /// Whether the menu item is interactive. Disabled items are greyed out.
  final bool enabled;

  /// Creates a [DeskContextMenuItem].
  const DeskContextMenuItem({
    required this.label,
    this.onTap,
    this.icon,
    this.type = DeskContextMenuType.normal,
    this.submenuItems,
    this.isChecked,
    this.enabled = true,
  });

  /// Creates a horizontal line divider.
  factory DeskContextMenuItem.divider() {
    return const DeskContextMenuItem(
      label: '',
      type: DeskContextMenuType.divider,
    );
  }

  /// Creates a cascading submenu.
  factory DeskContextMenuItem.submenu({
    required String label,
    required List<DeskContextMenuItem> items,
    IconData? icon,
    bool enabled = true,
  }) {
    return DeskContextMenuItem(
      label: label,
      type: DeskContextMenuType.submenu,
      submenuItems: items,
      icon: icon,
      enabled: enabled,
    );
  }

  /// Creates an item with a checkbox.
  factory DeskContextMenuItem.checkbox({
    required String label,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
    IconData? icon,
    bool enabled = true,
  }) {
    return DeskContextMenuItem(
      label: label,
      type: DeskContextMenuType.checkbox,
      isChecked: isChecked,
      onTap: () => onChanged(!isChecked),
      icon: icon,
      enabled: enabled,
    );
  }
}

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

    // Fallback to standard Flutter showMenu
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items.map((item) {
        if (item.type == DeskContextMenuType.divider) {
          return const PopupMenuDivider() as PopupMenuEntry;
        }

        return PopupMenuItem(
          enabled: item.enabled,
          onTap: item.onTap,
          child: Row(
            children: [
              if (item.type == DeskContextMenuType.checkbox) ...[
                Icon(
                  item.isChecked == true ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 18,
                ),
                const SizedBox(width: 12),
              ] else if (item.icon != null) ...[
                Icon(item.icon, size: 18),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(item.label)),
              if (item.type == DeskContextMenuType.submenu)
                const Icon(Icons.chevron_right_rounded, size: 16),
            ],
          ),
        );
      }).toList(),
    );
  }
}
