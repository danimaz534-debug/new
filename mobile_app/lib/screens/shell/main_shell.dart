import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../checkout/checkout_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

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
        onRequireAuth: _onRequireAuth,
        onOpenChat: _onOpenChat,
      ),
      CatalogScreen(
        onProductSelected: _onProductSelected,
        onRequireAuth: _onRequireAuth,
      ),
      CartScreen(
        onProductSelected: _onProductSelected,
        onRequireAuth: _onRequireAuth,
        onCheckout: _onCheckout,
      ),
      ProfileScreen(
        onRequireAuth: _onRequireAuth,
      ),
    ];
  }

  void _onProductSelected(Product product) {
    // TODO: Navigate to product detail
  }

  void _onExploreCatalog() {
    setState(() {
      _selectedIndex = 1; // Switch to catalog tab
    });
  }

  void _onRequireAuth() {
    // TODO: Show auth required dialog
  }

  void _onOpenChat() {
    // TODO: Open chat
  }

  void _onCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
      ),
    );
  }
}