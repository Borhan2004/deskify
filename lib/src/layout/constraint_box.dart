import 'package:flutter/material.dart';
import '../deskify_root.dart';

/// A wrapper to prevent mobile layouts from looking "stretched" on large screens.
///
/// It applies a maximum width and centers the content automatically.
class DeskConstraintBox extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The maximum width allowed for the content.
  final double maxWidth;

  /// Whether to center the content when it's smaller than the screen width.
  final bool centered;

  /// Creates a [DeskConstraintBox].
  const DeskConstraintBox({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final deskify = Deskify.of(context);
    final maxW = deskify?.widget.defaultMaxWidth ?? maxWidth;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}
