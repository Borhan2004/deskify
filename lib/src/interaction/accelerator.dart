import 'package:flutter/material.dart';
import '../deskify_root.dart';

/// A clean way to define global keyboard shortcuts that works across all OSs.
class DeskAccelerator extends StatefulWidget {
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
  State<DeskAccelerator> createState() => _DeskAcceleratorState();
}

class _DeskAcceleratorState extends State<DeskAccelerator> {
  DeskifyState? _deskify;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unregisterAll();

    _deskify = Deskify.of(context);
    if (_deskify != null) {
      for (final entry in widget.shortcuts.entries) {
        _deskify!.registerShortcut(entry.key, entry.value);
      }
    }
  }

  void _unregisterAll() {
    if (_deskify != null) {
      for (final activator in widget.shortcuts.keys) {
        _deskify!.unregisterShortcut(activator);
      }
    }
  }

  @override
  void dispose() {
    _unregisterAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_deskify != null) {
      return widget.child;
    }

    return Shortcuts(
      shortcuts: widget.shortcuts.map(
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
          child: widget.child,
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
