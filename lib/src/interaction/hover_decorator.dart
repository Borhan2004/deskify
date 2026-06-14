import 'package:flutter/material.dart';

/// A widget that adds premium hover effects to its child.
///
/// Developers can easily configure hover states like scale, opacity, color tints,
/// translation offsets, rotations, glowing shadows, custom cursors, and callbacks.
class HoverDecorator extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The scale factor to apply when the mouse is hovering over the widget.
  final double onHoverScale;

  /// The opacity to apply when the mouse is hovering over the widget.
  final double onHoverOpacity;

  /// The color tint to apply when the mouse is hovering over the widget.
  final Color? onHoverColor;

  /// An optional glow color to apply as a shadow during hover.
  final Color? onHoverGlowColor;

  /// Blur radius of the hover glow effect. Defaults to 16.0.
  final double glowRadius;

  /// A custom list of box shadows to override the hover glow shadow.
  final List<BoxShadow>? onHoverShadow;

  /// Pixel offset translation to apply on hover (e.g. Offset(0, -4) to lift).
  final Offset onHoverTranslate;

  /// Angle in radians to rotate the child on hover.
  final double onHoverRotate;

  /// The cursor to display when hovering. Defaults to [SystemMouseCursors.click].
  final MouseCursor cursor;

  /// Callback triggered when hover state changes.
  final ValueChanged<bool>? onHoverChanged;

  /// The duration of the hover transition.
  final Duration duration;

  /// Creates a [HoverDecorator].
  const HoverDecorator({
    super.key,
    required this.child,
    this.onHoverScale = 1.0,
    this.onHoverOpacity = 1.0,
    this.onHoverColor,
    this.onHoverGlowColor,
    this.glowRadius = 16.0,
    this.onHoverShadow,
    this.onHoverTranslate = Offset.zero,
    this.onHoverRotate = 0.0,
    this.cursor = SystemMouseCursors.click,
    this.onHoverChanged,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverDecorator> createState() => _HoverDecoratorState();
}

class _HoverDecoratorState extends State<HoverDecorator> {
  bool _isHovered = false;

  void _handleHover(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });
    if (widget.onHoverChanged != null) {
      widget.onHoverChanged!(hovering);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = _isHovered ? widget.onHoverTranslate : Offset.zero;
    final rotation = _isHovered ? widget.onHoverRotate : 0.0;

    List<BoxShadow> shadows = [];
    if (_isHovered) {
      if (widget.onHoverShadow != null) {
        shadows = widget.onHoverShadow!;
      } else if (widget.onHoverGlowColor != null) {
        shadows = [
          BoxShadow(
            color: widget.onHoverGlowColor!,
            blurRadius: widget.glowRadius,
            spreadRadius: 1.0,
          ),
        ];
      }
    }

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: widget.cursor,
      child: AnimatedScale(
        scale: _isHovered ? widget.onHoverScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isHovered ? widget.onHoverOpacity : 1.0,
          duration: widget.duration,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeInOut,
            transformAlignment: Alignment.center,
            transform: Matrix4.translationValues(translation.dx, translation.dy, 0.0)
              ..rotateZ(rotation),
            decoration: BoxDecoration(
              color: _isHovered ? (widget.onHoverColor ?? Colors.transparent) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: shadows,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
