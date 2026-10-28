import 'package:flutter/material.dart';

/// A shared dashboard header with separate controls and greeting rows.
class DashboardHeader extends StatelessWidget {
  final String name;
  final String workspace;
  final String subtitle;
  final VoidCallback? onOpenMenu;
  final VoidCallback onNotifications;
  final Key? menuKey;
  final Animation<double> greetingOpacity;
  final Animation<Offset> greetingSlide;
  final Animation<double> notificationRotation;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.workspace,
    required this.subtitle,
    required this.onOpenMenu,
    required this.onNotifications,
    this.menuKey,
    this.greetingOpacity = const AlwaysStoppedAnimation(1),
    this.greetingSlide = const AlwaysStoppedAnimation(Offset.zero),
    this.notificationRotation = const AlwaysStoppedAnimation(0),
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
    child: Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF741694), Color(0xFF9823BA)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -70,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .045),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -70,
          child: IgnorePointer(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .035),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (onOpenMenu != null) ...[
                      _HeaderAction(
                        key: menuKey,
                        tooltip: 'Open menu',
                        icon: Icons.menu_rounded,
                        onTap: onOpenMenu!,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        workspace,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .88),
                          letterSpacing: .15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: notificationRotation,
                      builder: (_, child) => Transform.rotate(
                        angle: notificationRotation.value,
                        child: child,
                      ),
                      child: _HeaderAction(
                        tooltip: 'Notifications',
                        icon: Icons.notifications_none_rounded,
                        onTap: onNotifications,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: greetingOpacity,
                  child: SlideTransition(
                    position: greetingSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.2,
                            letterSpacing: -.6,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: .85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 46,
    child: Material(
      color: Colors.white.withValues(alpha: .12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withValues(alpha: .18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 23),
      ),
    ),
  );
}
