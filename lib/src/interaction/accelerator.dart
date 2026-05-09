import 'package:flutter/material.dart';

/// A clean way to define global keyboard shortcuts that works across all OSs.
class DeskAccelerator extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// A map of keyboard shortcuts to actions.
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  /// Creates a [DeskAccelerator].
  const DeskAccelerator({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts.map(
        (key, value) => MapEntry(key, VoidCallbackIntent(value)),
      ),
      child: Actions(
        actions: {
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) => intent.callback(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

/// An intent that carries a [VoidCallback].
class VoidCallbackIntent extends Intent {
  /// The callback to invoke.
  final VoidCallback callback;

  /// Creates a [VoidCallbackIntent].
  const VoidCallbackIntent(this.callback);
}
