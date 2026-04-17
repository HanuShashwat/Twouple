import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';

class MoreView extends StatelessWidget {
  const MoreView();

  // ── Section data ───────────────────────────────────────────────────────────
  static const _kSections = [
    MoreSection(
      title: 'MY WORLD',
      items: [
        MoreItem(icon: Icons.person_outline_rounded, label: 'My Profile', subtitle: 'Edit name, photo & birth details', route: '/profile', color: Color(0xFF8784B4)),
        MoreItem(icon: Icons.circle_outlined, label: 'Birth Chart', subtitle: 'View your full natal chart', route: '/import', color: Color(0xFFDEA080)),
        MoreItem(icon: Icons.auto_awesome_outlined, label: 'My Zodiac', subtitle: 'Scorpio · Water · Fixed', color: Color(0xFF9C4F36)),
      ],
    ),
    MoreSection(
      title: 'RELATIONSHIP',
      items: [
        MoreItem(icon: Icons.people_outline_rounded, label: 'Partner Sync', subtitle: 'Manage your linked partner', color: Color(0xFFDEA080)),
        MoreItem(icon: Icons.favorite_border_rounded, label: 'Compatibility Report', subtitle: 'Full synastry deep-dive', route: '/paywall', color: Color(0xFFB47B80)),
        MoreItem(icon: Icons.timeline_rounded, label: 'Relationship Timeline', subtitle: 'Key cosmic milestones', color: Color(0xFF788B7A)),
      ],
    ),
    MoreSection(
      title: 'SETTINGS',
      items: [
        MoreItem(icon: Icons.notifications_none_rounded, label: 'Notifications', subtitle: 'Daily reminders & alerts', color: Color(0xFF788B7A)),
        MoreItem(icon: Icons.workspace_premium_outlined, label: 'Upgrade to Premium', subtitle: 'Unlock all cosmic insights', route: '/paywall', color: Color(0xFFE7AD5D), isPremium: true),
        MoreItem(icon: Icons.lock_outline_rounded, label: 'Privacy & Data', subtitle: 'Manage your information', color: Color(0xFF8784B4)),
        MoreItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', subtitle: 'Answers to common questions', color: Color(0xFF788B7A)),
        MoreItem(icon: Icons.mail_outline_rounded, label: 'Contact Support', subtitle: 'We\'re here to help', color: Color(0xFF8784B4)),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildProfileCard(context)),
            // ── Sections ────────────────────────────────────────────────────
            for (final section in _kSections) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(section.title)),
              SliverToBoxAdapter(
                child: _buildSectionCard(context, section.items),
              ),
            ],
            // ── Sign out ────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSignOut(context)),
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.elevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              // Zodiac badge
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name & tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Scorpio · Born under a soulful sky',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Premium badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7AD5D), Color(0xFFDEA080)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  // ── Section card ───────────────────────────────────────────────────────────
  Widget _buildSectionCard(BuildContext context, List<MoreItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return _buildItem(context, item, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, MoreItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isLast && item == _kSections.last.items.last ? 0 : 0),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        onTap: () {
          if (item.route != null) context.push(item.route!);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                            if (item.isPremium) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE7AD5D), Color(0xFFDEA080)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                endIndent: 0,
                color: AppColors.elevated,
              ),
          ],
        ),
      ),
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Widget _buildSignOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showSignOutDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ll need to sign back in to access your cosmic insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.go('/landing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────


class MoreSection {
  final String title;
  final List<MoreItem> items;
  const MoreSection({required this.title, required this.items});
}


class MoreItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? route;
  final Color color;
  final bool isPremium;
  const MoreItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.route,
    required this.color,
    this.isPremium = false,
  });
}

// ── Influence card data model ─────────────────────────────────────────────────

