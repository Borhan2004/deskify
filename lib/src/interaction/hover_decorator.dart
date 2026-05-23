import 'package:flutter/material.dart';

/// A widget that adds hover effects to its child.
///
/// Developers can easily add hover states like opacity changes, scaling,
/// or color tints with a single property.
class HoverDecorator extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The scale factor to apply when the mouse is hovering over the widget.
  final double onHoverScale;

  /// The opacity to apply when the mouse is hovering over the widget.
  final double onHoverOpacity;

  /// The color tint to apply when the mouse is hovering over the widget.
  final Color? onHoverColor;

  /// The duration of the hover transition.
  final Duration duration;

  /// Creates a [HoverDecorator].
  const HoverDecorator({
    super.key,
    required this.child,
    this.onHoverScale = 1.0,
    this.onHoverOpacity = 1.0,
    this.onHoverColor,
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
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
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
            decoration: BoxDecoration(
              color: _isHovered ? widget.onHoverColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
