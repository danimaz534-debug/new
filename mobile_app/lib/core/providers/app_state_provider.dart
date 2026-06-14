import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_notification.dart';
import '../../models/app_user.dart';
import '../../models/cart_entry.dart';
import '../../models/chat_models.dart';
import '../../models/order_summary.dart';
import '../../models/product.dart';
import '../../models/product_comment.dart';
import '../../models/product_rating.dart';
import '../../models/review.dart';
import '../../models/shipping_address.dart';
import '../../models/user_address.dart';
import '../services/address_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/catalog_service.dart';
import '../services/chat_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/notification_handler.dart';
import '../services/notifications_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/review_service.dart';

enum CatalogSort {
  recommended,
  priceLowHigh,
  priceHighLow,
}

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    AuthService? authService,
    ProfileService? profileService,
    CatalogService? catalogService,
    CartService? cartService,
    FavoritesService? favoritesService,
    OrderService? orderService,
    NotificationsService? notificationsService,
    ChatService? chatService,
    ReviewService? reviewService,
    HistoryService? historyService,
    AddressService? addressService,
  })  : _authService = authService ?? AuthService(),
        _profileService = profileService ?? ProfileService(),
        _catalogService = catalogService ?? CatalogService(),
        _cartService = cartService ?? CartService(),
        _favoritesService = favoritesService ?? FavoritesService(),
        _orderService = orderService ?? OrderService(),
        _notificationsService = notificationsService ?? NotificationsService(),
        _chatService = chatService ?? ChatService(),
        _reviewService = reviewService ?? ReviewService(),
        _historyService = historyService ?? HistoryService(),
        _addressService = addressService ?? AddressService();

  final AuthService _authService;
  final ProfileService _profileService;
  final CatalogService _catalogService;
  final CartService _cartService;
  final FavoritesService _favoritesService;
  final OrderService _orderService;
  final NotificationsService _notificationsService;
  final ChatService _chatService;
  final ReviewService _reviewService;
  final HistoryService _historyService;
  final AddressService _addressService;

  SharedPreferences? _prefs;
  StreamSubscription<AuthState>? _authSubscription;
  final List<RealtimeChannel> _channels = [];

  bool _initialized = false;
  bool _busy = false;
  bool _catalogLoading = false;
  bool _cartLoading = false;
  bool _checkoutLoading = false;
  bool _chatLoading = false;
  bool _isDisposed = false;
  bool _isPreparingChat = false;
  bool _isBlocked = false;
  DateTime? _lastChatViewedAt;
  String? _lastError;

  User? _authUser;
  AppUser? _profile;
  List<Product> _products = [];
  List<CartEntry> _cartItems = [];
  Set<String> _favoriteIds = <String>{};
  List<OrderSummary> _orders = [];
  List<AppNotification> _notifications = [];
  List<Product> _watchHistory = [];
  ChatThread? _chatThread;
  List<ChatMessage> _chatMessages = [];
  final Map<String, List<Review>> _reviewsByProduct = {};
  final Map<String, List<ProductComment>> _commentsByProduct = {};
  final Map<String, ProductRating?> _ratingsByProduct = {};
  final Map<String, String> _previousOrderStatuses = {};
  List<UserAddress> _userAddresses = [];
  UserAddress? _defaultAddress;

  ThemeMode _themeMode = ThemeMode.light;
  String _localeCode = 'en';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';
  double? _priceCap;
  CatalogSort _sort = CatalogSort.recommended;

  bool get isInitialized => _initialized;
  bool get isBusy => _busy;
  bool get isCatalogLoading => _catalogLoading;
  bool get isCartLoading => _cartLoading;
  bool get isCheckoutLoading => _checkoutLoading;
  bool get isChatLoading => _chatLoading;
  bool get isAuthenticated => _authUser != null;
  bool get isGuest => _authUser == null;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isBlocked => _isBlocked;
  User? get authUser => _authUser;
  AppUser? get profile => _profile;
  AppUser? get currentUser => profile;
  ThemeMode get themeMode => _themeMode;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);
  String? get lastError => _lastError;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedBrand => _selectedBrand;
  double? get priceCap => _priceCap;
  CatalogSort get sort => _sort;

  List<Product> get products => List.unmodifiable(_products);
  List<CartEntry> get cartItems => List.unmodifiable(_cartItems);
  List<CartEntry> get cartEntries => cartItems;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Map<String, int> _favoriteCounts = {};
  Map<String, int> get favoriteCounts => Map.unmodifiable(_favoriteCounts);
  List<OrderSummary> get orders => List.unmodifiable(_orders);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<Product> get watchHistory => List.unmodifiable(_watchHistory);
  ChatThread? get chatThread => _chatThread;
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  List<UserAddress> get userAddresses => List.unmodifiable(_userAddresses);
  UserAddress? get defaultAddress => _defaultAddress;

  bool get isAiModeActive => _chatThread?.aiModeActive ?? false;
  bool get isAwaitingAdminResponse => _chatThread?.awaitingAdminResponse ?? false;

  int get unreadChatCount {
    final nonUserMessages = _chatMessages.where((m) => m.senderType != 'user').toList();
    if (nonUserMessages.isEmpty) return 0;

    if (_lastChatViewedAt == null) {
      return nonUserMessages.length;
    }

    return nonUserMessages
        .where((m) => m.createdAt != null && m.createdAt!.isAfter(_lastChatViewedAt!))
        .length;
  }

  double get maxCatalogPrice {
    if (_products.isEmpty) return 0;
    return _products
        .map((product) => product.discountedPrice)
        .reduce(math.max);
  }

  Iterable<Product> get _filteredProducts {
    Iterable<Product> result = _products;

    if (_selectedCategory != 'All') {
      result = result.where((product) => product.category == _selectedCategory);
    }

    if (_selectedBrand != 'All') {
      result = result.where((product) => product.brand == _selectedBrand);
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query);
      });
    }

    if (_priceCap != null) {
      result = result.where((product) => product.discountedPrice <= _priceCap!);
    }

    final items = result.toList();
    switch (_sort) {
      case CatalogSort.priceLowHigh:
        items.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case CatalogSort.priceHighLow:
        items.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case CatalogSort.recommended:
        items.sort((a, b) {
          final scoreA = (a.isBestSeller ? 3 : 0) +
              (a.isFeatured ? 2 : 0) +
              (a.isHotDeal ? 4 : 0) +
              a.discountPercent;
          final scoreB = (b.isBestSeller ? 3 : 0) +
              (b.isFeatured ? 2 : 0) +
              (b.isHotDeal ? 4 : 0) +
              b.discountPercent;
          return scoreB.compareTo(scoreA);
        });
        break;
    }

    return items;
  }

  List<Product> get visibleProducts => List.unmodifiable(_filteredProducts);
  List<Product> get featuredProducts =>
      _products.where((product) => product.isFeatured).take(8).toList();
  List<Product> get bestSellerProducts =>
      _products.where((product) => product.isBestSeller).take(8).toList();
  List<Product> get hotDeals =>
      [..._products]..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
  List<Product> get favoriteProducts => _products
      .where((product) => _favoriteIds.contains(product.id))
      .toList(growable: false);

  int get cartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get unreadNotifications =>
      _notifications.where((item) => !item.isRead).length;
  double get cartSubtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.total);

  /// True when the signed-in user has the 'wholesale' role.
  bool get isWholesale => _profile?.isWholesale ?? false;

  /// Wholesale users always get 10 % off.
  double get wholesaleDiscount =>
      isWholesale ? cartSubtotal * 0.10 : 0;

  /// Loyalty discount (after 10 orders) only applies to non-wholesale users.
  double get estimatedLoyaltyDiscount =>
      (!isWholesale && _orders.length >= 10) ? cartSubtotal * 0.10 : 0;

  /// Total active discount (the higher of wholesale or loyalty — they don't stack).
  double get activeDiscount =>
      isWholesale ? wholesaleDiscount : estimatedLoyaltyDiscount;

  double get estimatedTotal => math.max(cartSubtotal - activeDiscount, 0);

  String text({
    required String en,
    required String ar,
  }) {
    return _localeCode == 'ar' ? ar : en;
  }
  String _translateError(String error) {
    switch (error) {
      case 'invalid-credentials':
        return text(
          en: 'Invalid email or password. Please check your credentials.',
          ar: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التحقق من بياناتك.',
        );
      case 'email-not-confirmed':
        return text(
          en: 'Please verify your email address before signing in.',
          ar: 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.',
        );
      case 'user-already-exists':
        return text(
          en: 'An account with this email already exists.',
          ar: 'يوجد حساب مسجل بهذا البريد الإلكتروني بالفعل.',
        );
      case 'rate-limit-exceeded':
        return text(
          en: 'Too many attempts. Please try again later.',
          ar: 'محاولات كثيرة جداً. يرجى المحاولة مرة أخرى لاحقاً.',
        );
      case 'network-error':
        return text(
          en: 'Network error. Please check your connection.',
          ar: 'خطأ في الشبكة. يرجى التحقق من الاتصال.',
        );
      case 'oauth-error':
        return text(
          en: 'Authentication failed. Please try again.',
          ar: 'فشلت عملية التحقق. يرجى المحاولة مرة أخرى.',
        );
      case 'Please enter a valid email address.':
        return text(
          en: 'Please enter a valid email address.',
          ar: 'يرجى إدخال بريد إلكتروني صحيح.',
        );
      case 'Password must be at least 6 characters.':
        return text(
          en: 'Password must be at least 6 characters.',
          ar: 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',
        );
      case 'Please enter your full name.':
        return text(
          en: 'Please enter your full name.',
          ar: 'يرجى إدخال اسمك الكامل.',
        );
      default:
        return error;
    }
  }

  Future<void> bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = _themeModeFromString(_prefs?.getString('theme_mode'));
    _localeCode = _prefs?.getString('locale_code') ?? 'en';
    _authUser = _authService.currentUser;

    _authSubscription ??= _authService.authChanges.listen((event) {
      unawaited(_handleAuthState(event.session?.user));
    });

    await _loadCatalog();
    await _handleAuthState(_authUser, reloadCatalog: false);

    _processPendingNotifications();

    _initialized = true;
    _safeNotify();
  }

  void _processPendingNotifications() {
    if (kIsWeb || _authUser == null) return;
    
    try {
      final handler = NotificationHandler();
      
      handler.addListener((notification) {
        final appNotif = AppNotification(
          id: notification['id']?.toString() ?? 'unknown',
          title: notification['title']?.toString() ?? '',
          body: notification['body']?.toString() ?? '',
          type: notification['type']?.toString() ?? '',
          isRead: notification['is_read'] == true,
          createdAt: notification['created_at'] != null
              ? DateTime.tryParse(notification['created_at'].toString())
              : DateTime.now(),
        );
        
        if (!_notifications.any((n) => n.id == appNotif.id)) {
          _notifications.insert(0, appNotif);
          _safeNotify();
        }
      });
      
      debugPrint('Notification listeners attached');
    } catch (e) {
      debugPrint('Error processing pending notifications: $e');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _runBusy(() => _authService.signIn(email: email, password: password));
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _runBusy(() async {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.session == null) {
        _lastError = text(
          en: 'Account created. Confirm your email if Supabase email verification is enabled.',
          ar: 'تم إنشاء الحساب. أكد بريدك إذا كان تفعيل البريد الإلكتروني مفعلًا في Supabase.',
        );
      }
    });
  }

  Future<void> signInWithGoogle() => _runBusy(_authService.signInWithGoogle);

  Future<void> signInWithGitHub() => _runBusy(_authService.signInWithGitHub);

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> loadReviews(String productId) async {
    final reviews = await _reviewService.fetchReviews(productId);
    _reviewsByProduct[productId] = reviews;
    _safeNotify();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    await _requireAuthenticated();
    await _ensureProfile();
    await _cartService.addToCart(productId: product.id, quantity: quantity);
    await loadCart();
  }

  Future<void> updateCartItemQuantity(CartEntry entry, int quantity) async {
    await _requireAuthenticated();
    await _cartService.updateQuantity(itemId: entry.id, quantity: quantity);
    await loadCart();
  }

  Future<void> removeCartItem(CartEntry entry) async {
    await _requireAuthenticated();
    await _cartService.removeItem(entry.id);
    await loadCart();
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    final entry = _cartItems.firstWhere((item) => item.product.id == productId);
    await updateCartItemQuantity(entry, quantity);
  }

  Future<void> removeFromCart(String productId) async {
    final entry = _cartItems.firstWhere((item) => item.product.id == productId);
    await removeCartItem(entry);
  }

  Future<void> toggleFavorite(Product product) async {
    await _requireAuthenticated();
    await _ensureProfile();

    final isFavorite = _favoriteIds.contains(product.id);
    if (isFavorite) {
      _favoriteIds.remove(product.id);
      _safeNotify();
      await _favoritesService.removeFavorite(product.id);
    } else {
      _favoriteIds.add(product.id);
      _safeNotify();
      await _favoritesService.addFavorite(product.id);
    }

    await loadFavorites();
  }

  Future<OrderSummary> checkout({
    required String paymentMethod,
    required ShippingAddress shippingAddress,
  }) async {
    await _requireAuthenticated();
    _checkoutLoading = true;
    _safeNotify();

    try {
      final order = await _orderService.createOrderFromCart(
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress.toJson(),
      );
      await Future.wait([
        loadOrders(),
        loadCart(),
        loadNotifications(),
        _loadCatalog(),
      ]);
      return order;
    } finally {
      _checkoutLoading = false;
      _safeNotify();
    }
  }

  Future<void> prepareChat({
    bool showLoader = true,
    bool markAsRead = false,
  }) async {
    if (_isPreparingChat) return;
    _isPreparingChat = true;

    try {
      await _requireAuthenticated();
      if (showLoader) {
        _chatLoading = true;
        _safeNotify();
      }

      await _ensureProfile();
      _chatThread = await _chatService.ensureThread();
      if (_chatThread != null) {
        _chatMessages = await _chatService.fetchMessages(_chatThread!.id);
        if (markAsRead) {
          _lastChatViewedAt = DateTime.now();
        }
      }
    } finally {
      _isPreparingChat = false;
      if (showLoader) {
        _chatLoading = false;
      }
      _safeNotify();
    }
  }

  Future<void> sendChatMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    await _requireAuthenticated();
    await prepareChat();

    final thread = _chatThread;
    if (thread == null) {
      throw StateError('Unable to start a chat thread.');
    }

    await _chatService.sendMessage(threadId: thread.id, message: trimmed);
    _chatMessages = await _chatService.fetchMessages(thread.id);
    _lastChatViewedAt = DateTime.now();
    _safeNotify();
    if (thread.aiModeActive) {
      unawaited(_chatService.triggerAiResponse(thread.id));
    }
  }

  void markChatAsRead() {
    _lastChatViewedAt = DateTime.now();
    _safeNotify();
  }

  void clearBlockedFlag() {
    _isBlocked = false;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _notificationsService.markAsRead(notificationId);
    _notifications = _notifications.map((notification) {
      if (notification.id == notificationId) {
        return AppNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }
      return notification;
    }).toList(growable: false);
    _safeNotify();
  }

  Future<void> updateProfile({
    required String fullName,
    required String preferredLanguage,
  }) async {
    await _requireAuthenticated();
    _profile = await _profileService.updateProfile(
      fullName: fullName,
      preferredLanguage: preferredLanguage,
    );
    _localeCode = preferredLanguage;
    await _prefs?.setString('locale_code', preferredLanguage);
    _safeNotify();
  }

  Future<void> recordProductView(Product product) async {
    if (!isAuthenticated) return;
    await _historyService.recordView(product.id);
    _watchHistory = await _historyService.fetchHistory();
    _safeNotify();
  }

  Future<void> changePassword(String newPassword) async {
    await _requireAuthenticated();
    await _authService.updatePassword(newPassword);
  }

  Future<void> updateAvatar(String avatarUrl) async {
    await _requireAuthenticated();
    _profile = await _profileService.updateAvatar(avatarUrl);
    _safeNotify();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setString('theme_mode', mode.name);
    _safeNotify();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _safeNotify();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    if (value == 'All') {
      _selectedBrand = 'All';
    }
    _safeNotify();
  }

  void setPriceCap(double? value) {
    _priceCap = value;
    _safeNotify();
  }

  void setSort(CatalogSort value) {
    _sort = value;
    _safeNotify();
  }

  Future<void> refreshAll() async {
    await _loadCatalog();
    if (isAuthenticated) {
      await Future.wait([
        loadCart(),
        loadFavorites(),
        loadOrders(),
        loadNotifications(),
        _loadWatchHistory(),
      ]);
    }
  }

  Future<void> loadCart() async {
    if (!isAuthenticated) {
      _cartItems = [];
      _safeNotify();
      return;
    }

    _cartLoading = true;
    _safeNotify();
    try {
      _cartItems = await _cartService.fetchCart();
    } finally {
      _cartLoading = false;
      _safeNotify();
    }
  }

  Future<void> loadFavorites() async {
    if (!isAuthenticated) {
      _favoriteIds = <String>{};
      _safeNotify();
      return;
    }

    _favoriteIds = await _favoritesService.fetchFavoriteIds();
    _safeNotify();
  }

  Future<void> loadOrders() async {
    _orders = await _orderService.fetchOrders();
    for (final order in _orders) {
      _previousOrderStatuses[order.id] = order.status;
    }
    _safeNotify();
  }

  Future<void> loadNotifications() async {
    _notifications = await _notificationsService.fetchNotifications();
    _safeNotify();
  }

  Future<void> _loadCatalog() async {
    _catalogLoading = true;
    _safeNotify();
    try {
      _products = await _catalogService.fetchProducts();
      if (_priceCap != null && _priceCap! > maxCatalogPrice) {
        _priceCap = maxCatalogPrice;
      }
    } finally {
      _catalogLoading = false;
      _safeNotify();
    }
  }

  Future<void> _loadWatchHistory() async {
    _watchHistory = await _historyService.fetchHistory();
    _safeNotify();
  }

  Future<void> _handleAuthState(
    User? user, {
    bool reloadCatalog = true,
  }) async {
    _authUser = user;
    _lastError = null;
    _disposeChannels();

    if (reloadCatalog && _products.isEmpty) {
      await _loadCatalog();
    }

    if (user == null) {
      _profile = null;
      _cartItems = [];
      _favoriteIds = <String>{};
      _favoriteCounts = {};
      _orders = [];
      _notifications = [];
      _watchHistory = [];
      _isBlocked = false;
      _chatThread = null;
      _chatMessages = [];
      _previousOrderStatuses.clear();
      _lastChatViewedAt = null;
      _attachRealtimeSubscriptions();
      _safeNotify();
      return;
    }

    try {
      await _ensureProfile();
      
      // Initialize notification handler for real-time updates
      if (!kIsWeb) {
        await NotificationHandler().initialize(user.id);
        await NotificationHandler().fetchPendingNotifications();
      }

      await Future.wait([
        loadCart(),
        loadFavorites(),
        loadOrders(),
        loadNotifications(),
        _loadWatchHistory(),
      ]);
    } catch (error) {
      _lastError = error.toString();
    }

    _attachRealtimeSubscriptions();
    _safeNotify();
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _busy = true;
    _lastError = null;
    _safeNotify();

    try {
      await action();
    } catch (error) {
      _lastError = _translateError(error.toString().replaceFirst('Exception: ', ''));
      rethrow;
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  Future<void> _ensureProfile() async {
    if (_authUser == null) return;

    _profile = await _profileService.ensureProfile(
      fullName:
          _authUser!.userMetadata?['full_name']?.toString() ??
          _authUser!.userMetadata?['name']?.toString(),
      role: 'retail',
      language: _localeCode,
    );
  }

  Future<void> loadUserAddresses() async {
    try {
      await _requireAuthenticated();
      _userAddresses = await _addressService.fetchUserAddresses();
      _defaultAddress = await _addressService.getDefaultAddress();
      _safeNotify();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  Future<UserAddress> createAddress(UserAddress address) async {
    try {
      await _requireAuthenticated();
      final newAddress = await _addressService.createAddress(address);
      _userAddresses.add(newAddress);
      if (newAddress.isDefault) {
        _defaultAddress = newAddress;
      }
      _safeNotify();
      return newAddress;
    } catch (e) {
      debugPrint('Error creating address: $e');
      rethrow;
    }
  }

  Future<UserAddress> updateAddress(UserAddress address) async {
    try {
      await _requireAuthenticated();
      final updated = await _addressService.updateAddress(address);
      final index = _userAddresses.indexWhere((a) => a.id == address.id);
      if (index >= 0) {
        _userAddresses[index] = updated;
      }
      if (updated.isDefault) {
        _defaultAddress = updated;
      }
      _safeNotify();
      return updated;
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _requireAuthenticated();
      await _addressService.deleteAddress(addressId);
      _userAddresses.removeWhere((a) => a.id == addressId);
      if (_defaultAddress?.id == addressId) {
        _defaultAddress = null;
      }
      _safeNotify();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  List<ProductComment> getProductComments(String productId) {
    return List.unmodifiable(_commentsByProduct[productId] ?? []);
  }

  ProductRating? getProductRating(String productId) {
    return _ratingsByProduct[productId];
  }

  Future<void> loadProductComments(String productId) async {
    try {
      final comments = await _reviewService.fetchProductComments(productId);
      _commentsByProduct[productId] = comments;
      _safeNotify();
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> loadProductRating(String productId) async {
    try {
      final rating = await _reviewService.fetchProductRating(productId);
      _ratingsByProduct[productId] = rating;
      _safeNotify();
    } catch (e) {
      debugPrint('Error loading rating: $e');
    }
  }

  Future<ProductComment> submitProductComment({
    required String productId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      await _requireAuthenticated();
      final newComment = await _reviewService.submitComment(
        productId: productId,
        rating: rating,
        title: title,
        comment: comment,
      );
      
      if (!_commentsByProduct.containsKey(productId)) {
        _commentsByProduct[productId] = [];
      }
      _commentsByProduct[productId]!.insert(0, newComment);
      
      // Reload rating to reflect the new comment
      await loadProductRating(productId);
      _safeNotify();
      return newComment;
    } catch (e) {
      debugPrint('Error submitting comment: $e');
      rethrow;
    }
  }

  Future<void> _requireAuthenticated() async {
    if (_authUser == null) {
      throw StateError(
        text(
          en: 'Sign in to use this feature.',
          ar: 'سجّل الدخول لاستخدام هذه الميزة.',
        ),
      );
    }
  }

  void _attachRealtimeSubscriptions() {
    final client = Supabase.instance.client;

    final productsChannel = client.channel('mobile-products-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'products',
        callback: (_) {
          unawaited(_loadCatalog());
        },
      )
      ..subscribe();
    _channels.add(productsChannel);

    if (!isAuthenticated) {
      return;
    }

    final cartChannel = client.channel('mobile-cart-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'cart_items',
        callback: (_) {
          unawaited(loadCart());
        },
      )
      ..subscribe();

    final favoriteChannel = client.channel('mobile-favorite-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'favorites',
        callback: (_) {
          unawaited(loadFavorites());
        },
      )
      ..subscribe();

    final currentUserId = _authUser?.id;

    final ordersChannel = client.channel('mobile-orders-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: currentUserId,
        ),
        callback: (payload) {
          final newOrder = payload.newRecord;
          final orderId = newOrder['id']?.toString() ?? '';
          final newStatus = newOrder['status']?.toString() ?? '';

          final previousStatus = _previousOrderStatuses[orderId];
          if (previousStatus != null && previousStatus != newStatus) {
            unawaited(loadNotifications());
          }
          _previousOrderStatuses[orderId] = newStatus;

          unawaited(loadOrders());
        },
      )
      ..subscribe();

    final ordersInsertChannel = client.channel('mobile-orders-insert-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: currentUserId,
        ),
        callback: (payload) {
          final newOrder = payload.newRecord;
          final orderId = newOrder['id']?.toString() ?? '';
          final newStatus = newOrder['status']?.toString() ?? '';
          _previousOrderStatuses[orderId] = newStatus;
          unawaited(loadOrders());
        },
      )
      ..subscribe();

    final notificationsChannel = client.channel('mobile-notifications-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        callback: (_) {
          unawaited(loadNotifications());
        },
      )
      ..subscribe();

    final chatMessagesChannel = client.channel('mobile-chat-messages-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (_) {
          final thread = _chatThread;
          if (thread != null) {
            unawaited(
              _chatService.fetchMessages(thread.id).then((messages) {
                _chatMessages = messages;
                _safeNotify();
              }),
            );
          }
        },
      )
      ..subscribe();

    final chatThreadsChannel = client.channel('mobile-chat-thread-sync')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_threads',
        callback: (_) {
          unawaited(prepareChat());
        },
      )
      ..subscribe();

    _channels.addAll([
      cartChannel,
      favoriteChannel,
      ordersChannel,
      ordersInsertChannel,
      notificationsChannel,
      chatMessagesChannel,
      chatThreadsChannel,
    ]);
  }

  void _disposeChannels() {
    final client = Supabase.instance.client;
    for (final channel in _channels) {
      client.removeChannel(channel);
    }
    _channels.clear();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    _disposeChannels();
    super.dispose();
  }
}
