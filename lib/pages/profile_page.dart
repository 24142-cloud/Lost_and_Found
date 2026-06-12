import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';
import 'package:lost_and_found/widgets/language_switcher.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PostProvider>().fetchMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();

    final l = AppLocalizations.of(context);
    final appUser = authProvider.appUser;
    final firebaseUser = authProvider.firebaseUser;

    final totalPosts = postProvider.myPosts.length;

    final lostItems = postProvider.myPosts
        .where((post) => post.type == 'lost')
        .length;

    final foundItems = postProvider.myPosts
        .where((post) => post.type == 'found')
        .length;
    final displayName = appUser?.name ?? firebaseUser?.email ?? 'D';
    final name = appUser?.name ?? firebaseUser?.displayName ?? '-';
    final email = appUser?.email ?? firebaseUser?.email ?? '-';
    final phone = appUser?.phone.isNotEmpty == true ? appUser!.phone : '-';
    final initial = displayName.isEmpty ? 'D' : displayName.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l.text('profile'),
          style: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Compact profile header ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAEA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F6B6F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name == '-' ? email : name,
                        style: const TextStyle(
                          color: Color(0xFF2E2E2E),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Statistics ──────────────────────────────────────────
          _SectionLabel(label: l.text('myActivity')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: totalPosts.toString(),
                  label: l.text('totalPosts'),
                  color: const Color(0xFF0F6B6F),
                  bgColor: const Color(0xFF0F6B6F).withOpacity(0.07),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: lostItems.toString(),
                  label: l.text('lostItems'),
                  color: const Color(0xFFE15C4F),
                  bgColor: const Color(0xFFE15C4F).withOpacity(0.07),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: foundItems.toString(),
                  label: l.text('foundItems'),
                  color: const Color(0xFF3FA46A),
                  bgColor: const Color(0xFF3FA46A).withOpacity(0.07),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Personal information ────────────────────────────────
          _SectionLabel(label: l.text('personalInfo')),
          const SizedBox(height: 10),
          _GroupCard(
            children: [
              _RowTile(
                label: l.text('name'),
                value: name,
                isLast: false,
              ),
              _RowTile(
                label: l.text('email'),
                value: email,
                isLast: false,
              ),
              _RowTile(
                label: l.text('phoneNumber'),
                value: phone,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Settings ────────────────────────────────────────────
          _SectionLabel(label: l.text('settings')),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAEAEA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.text('language'),
                      style: const TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Logout ──────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              AppSnackbars.showSuccess(context, l.text('logoutSuccess'));
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE15C4F).withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE15C4F),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.text('logout'),
                    style: const TextStyle(
                      color: Color(0xFFE15C4F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
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
}

// ── Reusable widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF8A8A8A),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.label,
    required this.value,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF0F0F0),
          ),
      ],
    );
  }
}
