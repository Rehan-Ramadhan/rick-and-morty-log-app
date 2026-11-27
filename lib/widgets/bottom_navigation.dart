import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../routing/app_routing.dart';
import '../screens/collection/collection_page.dart';
import '../screens/explore/explore_page.dart';
import '../screens/profile/profile_about_page.dart';
import 'portal_background.dart';

/// Responsive shell hosting Explore, Collection, and Profile destinations.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  int _collectionRefreshTick = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _collectionRefreshTick++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      });
    }

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 860;

    final pages = [
      const ExplorePage(),
      CollectionPage(refreshTick: _collectionRefreshTick),
      const ProfileAboutPage(),
    ];

    return Scaffold(
      body: PortalBackground(
        child: isDesktop
            ? Row(
                children: [
                  _DesktopLabSidebar(
                    currentIndex: _currentIndex,
                    userName: auth.user?.name ?? 'Researcher',
                    userEmail: auth.user?.email ?? 'Citadel Member',
                    onSelect: _onSelectTab,
                  ),
                  const VerticalDivider(width: 1, color: AppColors.borderSubtle),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: pages,
                    ),
                  ),
                ],
              )
            : IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _MobilePortalBottomNav(
              currentIndex: _currentIndex,
              onSelect: _onSelectTab,
            ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;
}

const _navItems = [
  _NavItemData(
    label: 'Explore',
    subtitle: 'Multiverse Index',
    icon: Icons.travel_explore_outlined,
    activeIcon: Icons.travel_explore_rounded,
  ),
  _NavItemData(
    label: 'Collection',
    subtitle: 'Dimension Vault',
    icon: Icons.workspaces_outline,
    activeIcon: Icons.workspaces_rounded,
  ),
  _NavItemData(
    label: 'Profile',
    subtitle: 'Lab Identity',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

class _DesktopLabSidebar extends StatelessWidget {
  const _DesktopLabSidebar({
    required this.currentIndex,
    required this.userName,
    required this.userEmail,
    required this.onSelect,
  });

  final int currentIndex;
  final String userName;
  final String userEmail;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 252,
      color: AppColors.secondaryBackground.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.dimensionalGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryNeonGreen.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.portalGradient,
                      ),
                      child: const Icon(
                        Icons.science_rounded,
                        color: AppColors.background,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'R&M LOG',
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'ARCHIVE TERMINAL',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: AppColors.primaryNeonGreen,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'MODULES',
                  style: textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < _navItems.length; i++) ...[
                _SidebarNavTile(
                  item: _navItems[i],
                  isSelected: currentIndex == i,
                  onTap: () => onSelect(i),
                ),
                const SizedBox(height: 8),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryNeonGreen.withValues(
                        alpha: 0.16,
                      ),
                      child: Text(
                        userName.isNotEmpty
                            ? userName.substring(0, 1).toUpperCase()
                            : 'R',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryNeonGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge,
                          ),
                          Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected
          ? AppColors.primaryNeonGreen.withValues(alpha: 0.14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryNeonGreen.withValues(alpha: 0.55)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected
                    ? AppColors.primaryNeonGreen
                    : AppColors.secondaryText,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? AppColors.mainText
                            : AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.cyan
                            : AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobilePortalBottomNav extends StatelessWidget {
  const _MobilePortalBottomNav({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 68,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primaryNeonGreen.withValues(alpha: 0.16),
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in _navItems)
              NavigationDestination(
                icon: Icon(item.icon, color: AppColors.secondaryText),
                selectedIcon: Icon(
                  item.activeIcon,
                  color: AppColors.primaryNeonGreen,
                ),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
