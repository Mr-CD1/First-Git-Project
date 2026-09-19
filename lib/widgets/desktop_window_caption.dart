import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../services/desktop_window_service.dart';

class DesktopWindowCaption extends StatefulWidget {
  const DesktopWindowCaption({
    super.key,
    this.iconColor,
    this.hoverColor,
  });

  final Color? iconColor;
  final Color? hoverColor;

  @override
  State<DesktopWindowCaption> createState() => _DesktopWindowCaptionState();
}

class _DesktopWindowCaptionState extends State<DesktopWindowCaption>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (DesktopWindowService.isFrameless) {
      windowManager.addListener(this);
      _syncMaximized();
    }
  }

  @override
  void dispose() {
    if (DesktopWindowService.isFrameless) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  void onWindowMaximize() => _syncMaximized();

  @override
  void onWindowUnmaximize() => _syncMaximized();

  @override
  Widget build(BuildContext context) {
    if (!DesktopWindowService.isFrameless) {
      return const SizedBox.shrink();
    }

    final iconColor = widget.iconColor ?? Theme.of(context).colorScheme.onSurface;
    final hover = widget.hoverColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CaptionIconButton(
          tooltip: '最小化',
          icon: Icons.remove,
          iconColor: iconColor,
          hoverColor: hover,
          onPressed: () => windowManager.minimize(),
        ),
        _CaptionIconButton(
          tooltip: _isMaximized ? '还原' : '最大化',
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          iconColor: iconColor,
          hoverColor: hover,
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
            await _syncMaximized();
          },
        ),
        _CaptionIconButton(
          tooltip: '关闭',
          icon: Icons.close,
          iconColor: iconColor,
          hoverColor: Colors.red.withValues(alpha: 0.85),
          iconOnHover: Colors.white,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class DesktopDragHeader extends StatelessWidget {
  const DesktopDragHeader({
    super.key,
    required this.child,
    this.caption,
    this.captionIconColor,
    this.captionHoverColor,
  });

  final Widget child;
  final Widget? caption;
  final Color? captionIconColor;
  final Color? captionHoverColor;

  @override
  Widget build(BuildContext context) {
    final captionWidget = caption ??
        DesktopWindowCaption(
          iconColor: captionIconColor,
          hoverColor: captionHoverColor,
        );

    if (!DesktopWindowService.isFrameless) {
      return Row(
        children: [
          Expanded(child: child),
          captionWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DragToMoveArea(
            child: child,
          ),
        ),
        captionWidget,
      ],
    );
  }
}

class _CaptionIconButton extends StatefulWidget {
  const _CaptionIconButton({
    required this.tooltip,
    required this.icon,
    required this.iconColor,
    required this.hoverColor,
    required this.onPressed,
    this.iconOnHover,
  });

  final String tooltip;
  final IconData icon;
  final Color iconColor;
  final Color hoverColor;
  final Color? iconOnHover;
  final VoidCallback onPressed;

  @override
  State<_CaptionIconButton> createState() => _CaptionIconButtonState();
}

class _CaptionIconButtonState extends State<_CaptionIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = _hovering && widget.iconOnHover != null
        ? widget.iconOnHover!
        : widget.iconColor;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Material(
          color: _hovering ? widget.hoverColor : Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            child: SizedBox(
              width: 46,
              height: 40,
              child: Icon(widget.icon, size: 16, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
