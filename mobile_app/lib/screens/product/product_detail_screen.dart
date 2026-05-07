import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../models/product.dart';
import '../../widgets/network_product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onRequireAuth,
  });

  final Product product;
  final VoidCallback onRequireAuth;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _userRating = 0;
  final _reviewTitleController = TextEditingController();
  final _reviewCommentController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _reviewsLoading = true;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviewsData();
    });
  }

  Future<void> _loadReviewsData() async {
    setState(() {
      _reviewsLoading = true;
      _reviewsError = null;
    });

    try {
      final appState = context.read<AppStateProvider>();
      await Future.wait([
        appState.loadReviews(widget.product.id),
        appState.loadProductComments(widget.product.id),
        appState.loadProductRating(widget.product.id),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() => _reviewsError = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _reviewsLoading = false);
        context.read<AppStateProvider>().recordProductView(widget.product);
      }
    }
  }

  @override
  void dispose() {
    _reviewTitleController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_quantity < widget.product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart() async {
    final appState = context.read<AppStateProvider>();
    if (appState.isGuest) {
      widget.onRequireAuth();
      return;
    }
    await appState.addToCart(widget.product, quantity: _quantity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.text(en: 'Added to cart', ar: 'تمت الإضافة إلى السلة'),
          ),
          backgroundColor: const Color(0xFFD4AF37),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final appState = context.read<AppStateProvider>();
    if (appState.isGuest) {
      widget.onRequireAuth();
      return;
    }
    await appState.toggleFavorite(widget.product);
  }

  void _showReviewModal() {
    final appState = context.read<AppStateProvider>();
    if (appState.isGuest) {
      widget.onRequireAuth();
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.text(en: 'Write a Review', ar: 'اكتب مراجعة'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => setModalState(() => _userRating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _userRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reviewTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: appState.text(
                    en: 'Review Title',
                    ar: 'عنوان المراجعة',
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewCommentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: appState.text(en: 'Your Experience', ar: 'تجربتك'),
                  labelStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmittingReview
                      ? null
                      : () async {
                          if (_userRating == 0 ||
                              _reviewTitleController.text.trim().isEmpty) {
                            return;
                          }
                          setModalState(() => _isSubmittingReview = true);
                          try {
                            await appState.submitProductComment(
                              productId: widget.product.id,
                              rating: _userRating,
                              title: _reviewTitleController.text.trim(),
                              comment: _reviewCommentController.text.trim(),
                            );
                            _reviewTitleController.clear();
                            _reviewCommentController.clear();
                            _userRating = 0;
                            if (mounted) {
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appState.text(
                                      en: 'Your review has been saved.',
                                      ar: 'تم حفظ تقييمك.',
                                    ),
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setModalState(() => _isSubmittingReview = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSubmittingReview
                        ? appState.text(
                            en: 'Submitting...',
                            ar: 'جاري الإرسال...',
                          )
                        : appState.text(en: 'Post Review', ar: 'نشر المراجعة'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final product = widget.product;
    final isFavorite = appState.favoriteIds.contains(product.id);
    final comments = appState.getProductComments(product.id);
    final ratingSummary = appState.getProductRating(product.id);
    final isAdmin = appState.currentUser?.isAdmin ?? false;
    final favoriteCount = appState.favoriteCounts[product.id] ?? 0;

    final basePrice = product.discountedPrice;
    final hasRetailDiscount = product.discountPercent > 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: scheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isAdmin)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: scheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$favoriteCount',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : scheme.onSurface,
                  ),
                  onPressed: _toggleFavorite,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkProductImage(
                    imageUrl: product.imageUrl,
                    borderRadius: BorderRadius.zero,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Color(0xFF0A0A0A),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.brand.toUpperCase(),
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (product.stock > 0)
                        Text(
                          '${appState.text(en: 'IN STOCK', ar: 'متوفر')}: ${product.stock}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(
                          appState.text(en: 'OUT OF STOCK', ar: 'نفد'),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasRetailDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.4),
                                decoration: TextDecoration.lineThrough,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (appState.isWholesale) ...[
                        const SizedBox(height: 8),
                        Text(
                          appState.text(
                            en: 'Wholesale discount is applied at checkout.',
                            ar: 'يتم تطبيق خصم الجملة عند إتمام الطلب.',
                          ),
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    appState.text(en: 'Description', ar: 'الوصف'),
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (product.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.24,
                                  ),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 40),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appState.text(en: 'Client Reviews', ar: 'آراء العملاء'),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showReviewModal,
                        child: Text(
                          appState.text(en: 'Add Review', ar: 'إضافة تقييم'),
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (ratingSummary != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            ratingSummary.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index <
                                              ratingSummary.averageRating
                                                  .round()
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 18,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ratingSummary.totalReviews} ${appState.text(en: 'reviews', ar: 'تقييمات')}',
                                  style: TextStyle(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_reviewsLoading)
                    Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    )
                  else if (_reviewsError != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _reviewsError!,
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    )
                  else if (comments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          appState.text(
                            en: 'Be the first to review this masterpiece.',
                            ar: 'كن أول من يقيم هذه التحفة.',
                          ),
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...comments.map(
                      (review) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(
                              alpha: 0.24,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    review.reviewerName ?? 'Anonymous',
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < review.rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 14,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (review.title.isNotEmpty)
                              Text(
                                review.title,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            if (review.comment != null &&
                                review.comment!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  review.comment!,
                                  style: TextStyle(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (review.isVerifiedPurchase)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      appState.text(
                                        en: 'Verified',
                                        ar: 'شراء موثّق',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  MaterialLocalizations.of(
                                    context,
                                  ).formatShortDate(review.createdAt),
                                  style: TextStyle(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.45,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.24),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: scheme.onSurface),
                      onPressed: _decrement,
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: scheme.onSurface),
                      onPressed: _increment,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: product.stock > 0 ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    appState.text(en: 'Add to Cart', ar: 'أضف إلى السلة'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
