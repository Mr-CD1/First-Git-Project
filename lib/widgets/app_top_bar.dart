import 'package:flutter/material.dart';

import 'desktop_window_caption.dart';

/// 非首页顶栏；Windows 无边框模式下支持拖拽与窗口按钮。
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: DesktopDragHeader(
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: '打开导航菜单',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
