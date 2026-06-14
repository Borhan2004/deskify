import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import '../interaction/hover_decorator.dart';

/// A platform-adaptive title bar that simulates native OS window controls
/// (macOS traffic lights on the left, Windows window buttons on the right)
/// with visual glassmorphic styling.
class DeskTitleBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title widget shown in the center or left.
  final Widget? title;

  /// Optional actions displayed on the right (macOS) or left (Windows).
  final List<Widget>? actions;

  /// Height of the title bar. Defaults to 48.0.
  final double height;

  /// Callback when the simulated close button is pressed.
  final VoidCallback? onClose;

  /// Callback when the simulated minimize button is pressed.
  final VoidCallback? onMinimize;

  /// Callback when the simulated maximize/zoom button is pressed.
  final VoidCallback? onMaximize;

  /// Whether the title bar should be translucent with backdrop blur.
  final bool translucent;

  /// Creates a [DeskTitleBar].
  const DeskTitleBar({
    super.key,
    this.title,
    this.actions,
    this.height = 48.0,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.translucent = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final bool isMac = DeskPlatform.isMacOS;
    final theme = Theme.of(context);

    // Platform-specific styling
    Color bgColor;
    if (translucent) {
      bgColor = theme.brightness == Brightness.light
          ? Colors.white.withValues(alpha: .7)
          : const Color(0xFF0F172A).withValues(alpha: .7);
    } else {
      bgColor = theme.scaffoldBackgroundColor;
    }

    Widget titleBarContent = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 1. Left Side Control Buttons (macOS Style)
          if (isMac) ...[
            _buildMacButtons(),
            const SizedBox(width: 20),
          ],

          // 2. Title Section
          if (!isMac && title != null) ...[
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Align(
              alignment: isMac ? Alignment.center : Alignment.centerLeft,
              child: DefaultTextStyle(
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ) ?? const TextStyle(),
                child: title ?? const SizedBox.shrink(),
              ),
            ),
          ),

          // 3. Actions / Windows Buttons
          if (actions != null) ...actions!,

          if (!isMac) ...[
            const SizedBox(width: 12),
            _buildWindowsButtons(theme),
          ],
        ],
      ),
    );

    if (translucent) {
      titleBarContent = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: titleBarContent,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: titleBarContent,
    );
  }

  Widget _buildMacButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMacDot(const Color(0xFFFF5F56), onClose), // Red
        const SizedBox(width: 8),
        _buildMacDot(const Color(0xFFFFBD2E), onMinimize), // Yellow
        const SizedBox(width: 8),
        _buildMacDot(const Color(0xFF27C93F), onMaximize), // Green
      ],
    );
  }

  Widget _buildMacDot(Color color, VoidCallback? onTap) {
    return HoverDecorator(
      onHoverScale: 1.15,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowsButtons(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWinButton(Icons.minimize_rounded, iconColor, onMinimize),
        const SizedBox(width: 4),
        _buildWinButton(Icons.crop_square_rounded, iconColor, onMaximize),
        const SizedBox(width: 4),
        _buildWinButton(Icons.close_rounded, const Color(0xFFEF4444), onClose, isClose: true),
      ],
    );
  }

  Widget _buildWinButton(IconData icon, Color color, VoidCallback? onTap, {bool isClose = false}) {
    return HoverDecorator(
      onHoverScale: 1.05,
      onHoverColor: isClose ? const Color(0x33EF4444) : const Color(0x1AFFFFFF),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
