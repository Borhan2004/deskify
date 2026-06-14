import 'package:flutter/material.dart';
import '../deskify_root.dart';

/// A wrapper to prevent mobile layouts from looking "stretched" on large screens.
///
/// It applies a maximum width and layout alignment, animating transitions smoothly.
class DeskConstraintBox extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The maximum width allowed for the content.
  final double maxWidth;

  /// How to align the child content within the available space.
  final AlignmentGeometry alignment;

  /// The duration of the constraint transition animation.
  final Duration duration;

  /// The curve of the constraint transition animation.
  final Curve curve;

  /// Creates a [DeskConstraintBox].
  const DeskConstraintBox({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final deskify = Deskify.of(context);
    final maxW = deskify?.widget.defaultMaxWidth ?? maxWidth;

    return Align(
      alignment: alignment,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}
