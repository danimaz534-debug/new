import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../auth/auth_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query == _lastQuery) return;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _lastQuery = '';
      });
      return;
    }

    setState(() => _isLoading = true);

    final appState = context.read<AppStateProvider>();
    final results = await appState.searchProducts(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _lastQuery = query;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.read<AppStateProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  _performSearch(value);
                }
              });
            },
            decoration: InputDecoration(
              hintText: appState.text(
                en: 'Search products...',
                ar: 'بحث عن المنتجات...',
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator()
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appState.text(
                        en: 'No results found',
                        ar: 'لا توجد نتائج',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.text(
                        en: 'Try searching for something else',
                        ar: 'جرب البحث عن شيء آخر',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isEmpty)
            Expanded(child: _buildRecentSearches(appState, theme))
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ProductCard(
                    product: product,
                    isFavorite: appState.favoriteIds.contains(product.id),
                    isAdmin: appState.isAdmin,
                    favoriteCount: appState.favoriteCounts[product.id] ?? 0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            onRequireAuth: () => _showAuthModal(context),
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () async {
                      if (appState.isGuest) {
                        _showAuthModal(context);
                        return;
                      }
                      await appState.toggleFavorite(product);
                    },
                    onAddToCart: () async {
                      if (appState.isGuest) {
                        _showAuthModal(context);
                        return;
                      }
                      await appState.addToCart(product);
                    },
                    isWholesale: appState.isWholesale,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(AppStateProvider appState, ThemeData theme) {
    // Mock categories for quick search
    final categories = [
      'Laptops',
      'Smartphones',
      'Audio',
      'Cameras',
      'Tablets',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          appState.text(en: 'Browse Categories', ar: 'تصفح الفئات'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories
              .map(
                (cat) => InkWell(
                  onTap: () {
                    _searchController.text = cat;
                    _performSearch(cat);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showAuthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: AuthScreen(
          onSupportChat: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
