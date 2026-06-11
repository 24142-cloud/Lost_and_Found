import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/constants/post_categories.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/core/widgets/empty_widget.dart';
import 'package:lost_and_found/core/widgets/loading_widget.dart';
import 'package:lost_and_found/core/widgets/post_card.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';
import 'package:lost_and_found/widgets/language_switcher.dart';
import 'package:lost_and_found/core/constants/mauritania_locations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedType = 'all';
  String _selectedCategory = 'all';
  String _selectedWilaya = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _currentNavIndex = 3;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    Future.microtask(() {
      authProvider.loadCurrentUser();
      postProvider.fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
  if (index == 2) {
    Navigator.pushNamed(context, '/add-post');
    return;
  }

  setState(() => _currentNavIndex = index);

  switch (index) {
    case 0:
      Navigator.pushNamed(context, '/profile');
      break;

    case 1:
      Navigator.pushNamed(context, '/my-posts');
      break;

    case 3:
      break; // Home
  }
}

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l, context),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.posts.isEmpty) {
            return EmptyWidget(message: l.text('noPostsYet'));
          }

          final filteredPosts = provider.posts.where((post) {
            final matchesType =
                _selectedType == 'all' || post.type == _selectedType;
            final matchesCategory = _selectedCategory == 'all' ||
                PostCategories.filterValue(post.category) == _selectedCategory;
            final matchesWilaya =
                _selectedWilaya == 'all' || post.wilaya == _selectedWilaya;
            final query = _searchQuery.trim().toLowerCase();
            final matchesSearch = query.isEmpty ||
                post.title.toLowerCase().contains(query) ||
                post.description.toLowerCase().contains(query);
            return matchesType && matchesCategory && matchesWilaya && matchesSearch;
          }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.fetchPosts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _buildSearchBar(l),
                const SizedBox(height: 14),
                _HomeFilters(
                  selectedType: _selectedType,
                  selectedCategory: _selectedCategory,
                  selectedWilaya: _selectedWilaya,
                  onTypeChanged: (value) =>
                      setState(() => _selectedType = value),
                  onCategoryChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  onWilayaChanged: (value) =>
                      setState(() => _selectedWilaya = value),
                ),
                const SizedBox(height: 16),
                if (filteredPosts.isEmpty)
                  EmptyWidget(message: l.text('noPostsYet'))
                else
                  ...filteredPosts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PostCard(
                          post: post,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: post,
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(l),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l, BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      centerTitle: true,
      leading: const LanguageSwitcher(),
      title: Text(
        l.text('appName'),
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [
        
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.text),
          tooltip: l.text('logout'),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            AppSnackbars.showSuccess(context, l.text('logoutSuccess'));
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: l.text('searchHint'),
          hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 14),
          prefixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.subtext, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          suffixIcon:
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l) {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 74,
        child: Row(
          children: [

            Expanded(
              child: _NavItem(
                icon: Icons.person_outline_rounded,
                label: l.text('profile'),
                selected: _currentNavIndex == 0,
                onTap: () => _onNavTapped(0),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.article_outlined,
                label: l.text('myPosts'),
                selected: _currentNavIndex == 1,
                onTap: () => _onNavTapped(1),
              ),
            ),

            Expanded(
              child: Center(
                child: _CenterAddButton(
                  onTap: () => _onNavTapped(2),
                ),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: l.text('home'),
                selected: _currentNavIndex == 3,
                onTap: () => _onNavTapped(3),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.subtext,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : AppColors.subtext,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  const _CenterAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x330F6B6F),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _HomeFilters extends StatelessWidget {
  const _HomeFilters({
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedWilaya,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onWilayaChanged,
  });

  final String selectedType;
  final String selectedCategory;
  final String selectedWilaya;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onWilayaChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type filter chips
        Row(
          children: [
            _TypeChip(
              label: l.text('all'),
              selected: selectedType == 'all',
              onTap: () => onTypeChanged('all'),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: l.text('lost'),
              selected: selectedType == 'lost',
              onTap: () => onTypeChanged('lost'),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: l.text('found'),
              selected: selectedType == 'found',
              onTap: () => onTypeChanged('found'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Wilaya dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            key: ValueKey(selectedWilaya),
            initialValue: selectedWilaya,
            decoration: InputDecoration(
              labelText: l.text('wilayaFilter'),
              labelStyle: const TextStyle(
                  color: AppColors.subtext, fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.card,
            ),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l.text('all'))),
              ...MauritaniaLocations.wilayas.map(
                (w) => DropdownMenuItem(value: w, child: Text(w)),
              ),
            ],
            onChanged: (val) {
              if (val != null) onWilayaChanged(val);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: l.text('all'),
                selected: selectedCategory == 'all',
                onTap: () => onCategoryChanged('all'),
              ),
              ...PostCategories.values.map(
                (cat) => _CategoryChip(
                  label: PostCategories.label(l, cat),
                  selected: selectedCategory == cat,
                  onTap: () => onCategoryChanged(cat),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.secondary : AppColors.subtext,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}