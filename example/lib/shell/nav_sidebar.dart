import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The fixed left navigation sidebar shown on wide screens.
///
/// Renders three navigation items stacked vertically. The active item is
/// highlighted with the accent color. Inactive items respond to hover with
/// a subtle background shift. The sidebar is always 220 logical pixels wide.
class NavSidebar extends StatelessWidget {
  /// Creates a [NavSidebar].
  const NavSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const double width = 220;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      width: width,
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'block_editor',
              style: TextStyle(
                color: colors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Demo',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: colors.border),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.edit_outlined,
                  label: 'Editor',
                  selected: selectedIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  label: 'Demo Blocks',
                  selected: selectedIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
                const SizedBox(height: 2),
                _NavItem(
                  icon: Icons.extension_outlined,
                  label: 'Custom Block',
                  selected: selectedIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
              ],
            ),
          ),
          const Spacer(),
          Divider(height: 1, thickness: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              'v0.0.4-dev.1',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final Color bg;
    final Color fg;

    if (widget.selected) {
      bg = colors.accent.withValues(alpha: 0.12);
      fg = colors.accent;
    } else if (_hovered) {
      bg = colors.surfaceVariant;
      fg = colors.text;
    } else {
      bg = colors.surface.withValues(alpha: 0.0);
      fg = colors.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  child: Text(widget.label, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
