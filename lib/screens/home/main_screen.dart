import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../search/search_screen.dart';
import '../../../services/realtime_notification_service.dart';
import '../../../shared/widgets/menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // VINCULAR CARRITO AL USUARIO
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cart = Provider.of<CartProvider>(context, listen: false);
      // 'guest' o ID real
      String userId = auth.usuarioActual?.id ?? 'guest';

      // AUTO-CORRECCIÓN: Si el ID es "0", forzamos logout para limpiar sesión corrupta
      if (userId == '0') {
        auth.logout();
        userId = 'guest';
      }

      cart.init(userId);

      // Iniciar notificaciones realtime si es vendedor
      if (userId != 'guest' && (auth.usuarioActual?.bitEsVendedor ?? false)) {
        RealtimeNotificationService().startListeningForOrders(userId);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentPageIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          cacheWidth: 120,
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: const [
            HomeScreen(key: ValueKey('home')),
            SearchScreen(key: ValueKey('search')),
            MenuScreen(key: ValueKey('menu')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white12,
              width: 1,
            ), // Borde superior sutil
          ),
        ),
        child: BottomAppBar(
          color: const Color(
            0xFF151515,
          ), // Tono ligeramente más claro que negro
          padding: EdgeInsets.zero,
          height: 70,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. INICIO
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  label: 'INICIO',
                ),
              ),

              // 2. BUSCAR
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.search,
                  label: 'BUSCAR',
                  isCenter: true,
                ),
              ),

              // 3. MENÚ
              Expanded(
                child: _buildNavItem(index: 2, icon: Icons.menu, label: 'MENÚ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isCenter = false,
  }) {
    final bool isSelected = _currentPageIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: isSelected ? 1.15 : 1.0,
            child: Container(
              padding: isCenter ? const EdgeInsets.all(8) : null,
              decoration: isCenter
                  ? BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    )
                  : null,
              child: Icon(
                icon,
                color: isCenter
                    ? (isSelected ? Colors.black : Colors.white)
                    : (isSelected ? Colors.redAccent : Colors.grey),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (!isCenter) ...[
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuad,
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
