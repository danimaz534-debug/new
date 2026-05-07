import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/core/providers/app_state_provider.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/screens/auth/auth_screen.dart';
import 'package:mobile_app/screens/cart/cart_screen.dart';
import 'package:mobile_app/screens/catalog/catalog_screen.dart';
import 'package:mobile_app/screens/chat/user_chat_screen.dart';
import 'package:mobile_app/screens/checkout/checkout_screen.dart';
import 'package:mobile_app/screens/favorites/favorites_screen.dart';
import 'package:mobile_app/screens/home/home_screen.dart';
import 'package:mobile_app/screens/notifications/notifications_screen.dart';
import 'package:mobile_app/screens/product/product_detail_screen.dart';
import 'package:mobile_app/screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onProductSelected: _onProductSelected,
        onExploreCatalog: _onExploreCatalog,
        onRequireAuth: () {
          _onRequireAuth();
        },
        onOpenChat: _onOpenChat,
        onOpenProfile: _openProfileTab,
        onOpenNotifications: _onOpenNotifications,
      ),
      CatalogScreen(
        onProductSelected: _onProductSelected,
        onRequireAuth: () {
          _onRequireAuth();
        },
      ),
      FavoritesScreen(
        onProductSelected: _onProductSelected,
        onRequireAuth: () {
          _onRequireAuth();
        },
      ),
      CartScreen(
        onProductSelected: _onProductSelected,
        onRequireAuth: () {
          _onRequireAuth();
        },
        onCheckout: _onCheckout,
      ),
      ProfileScreen(
        onRequireAuth: () {
          _onRequireAuth();
        },
      ),
    ];
  }

  void _onProductSelected(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          onRequireAuth: () {
            _onRequireAuth();
          },
        ),
      ),
    );
  }

  void _onExploreCatalog() {
    setState(() {
      _selectedIndex = 1; // Switch to catalog tab
    });
  }

  Future<void> _onRequireAuth() async {
    final appState = context.read<AppStateProvider>();
    if (appState.isAuthenticated) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: AuthScreen(onSupportChat: _onOpenChat),
      ),
    );
  }

  void _onOpenChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserChatScreen()));
  }

  void _onCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          onOrderPlaced: () {
            Navigator.of(context).pop();
          },
          onRequireAuth: () {
            Navigator.of(context).pop();
            _onRequireAuth();
          },
        ),
      ),
    );
  }

  void _onOpenNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProfileTab() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final navBackground = theme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBackground,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08,
              ),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: _selectedIndex,
              selectedItemColor: scheme.primary,
              unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: appState.text(en: 'Home', ar: 'الرئيسية'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view_outlined),
                  activeIcon: const Icon(Icons.grid_view_rounded),
                  label: appState.text(en: 'Gallery', ar: 'المعرض'),
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.favorite_border_rounded),
                      if (appState.favoriteProducts.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${appState.favoriteProducts.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.favorite_rounded),
                      if (appState.favoriteProducts.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${appState.favoriteProducts.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: appState.text(en: 'Favorites', ar: 'المفضلة'),
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      if (appState.cart.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${appState.cart.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag_rounded),
                      if (appState.cart.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${appState.cart.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: appState.text(en: 'Collection', ar: 'المجموعة'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: appState.text(en: 'Profile', ar: 'الحساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
