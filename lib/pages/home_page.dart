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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('appName')),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            tooltip: l.text('myPosts'),
            onPressed: () => Navigator.pushNamed(context, '/my-posts'),
            icon: const Icon(Icons.list_alt_outlined),
          ),
          IconButton(
            tooltip: l.text('profile'),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: l.text('logout'),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              AppSnackbars.showSuccess(context, l.text('logoutSuccess'));
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
            final matchesCategory =
                _selectedCategory == 'all' ||
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
            onRefresh: provider.fetchPosts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l.text('searchHint'),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 14),
                if (filteredPosts.isEmpty)
                  EmptyWidget(message: l.text('noPostsYet'))
                else
                  ...filteredPosts.map((post) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(
                        post: post,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: post,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-post'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.text('add')),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<String>(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.card;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return AppColors.text;
              }),
              side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.border),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            segments: [
              ButtonSegment(value: 'all', label: Text(l.text('all'))),
              ButtonSegment(value: 'lost', label: Text(l.text('lost'))),
              ButtonSegment(value: 'found', label: Text(l.text('found'))),
            ],
            selected: {selectedType},
            onSelectionChanged: (values) => onTypeChanged(values.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedWilaya),
            initialValue: selectedWilaya,
            decoration: InputDecoration(
              labelText: l.text('wilayaFilter'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text(l.text('all')),
              ),
              ...MauritaniaLocations.wilayas.map(
                (w) => DropdownMenuItem(value: w, child: Text(w)),
              ),
            ],
            onChanged: (val) {
              if (val != null) onWilayaChanged(val);
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryFilterChip(
                  label: l.text('all'),
                  selected: selectedCategory == 'all',
                  onSelected: () => onCategoryChanged('all'),
                ),
                ...PostCategories.values.map(
                  (category) => _CategoryFilterChip(
                    label: PostCategories.label(l, category),
                    selected: selectedCategory == category,
                    onSelected: () => onCategoryChanged(category),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: const Color(0xFFEAD6BA),
        backgroundColor: const Color(0xFFF8F3ED),
        checkmarkColor: AppColors.secondary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
