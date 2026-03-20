import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../search/search_screen.dart';
import '../../../services/realtime_notification_service.dart';
import '../../../shared/widgets/menu_screen.dart';
import '../../../services/chat_service.dart';
import '../../screens/buyer_chats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  // ── Contador de mensajes no leídos del comprador ────────
  final _supabase    = Supabase.instance.client;
  final _chatService = ChatService();
  int _unreadCount   = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUser();
      _listenUnread();
    });
  }

  void _initUser() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    String userId = auth.usuarioActual?.id ?? 'guest';

    if (userId == '0') {
      auth.logout();
      userId = 'guest';
    }
    cart.init(userId);

    if (userId != 'guest' && (auth.usuarioActual?.bitEsVendedor ?? false)) {
      RealtimeNotificationService().startListeningForOrders(userId);
    }
  }

  // Escuchar mensajes no leídos en tiempo real (para el comprador)
  void _listenUnread() {
    final buyerId = _chatService.currentUserId;
    if (buyerId == null) return;

    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('is_read', false)
        .listen((msgs) async {
          if (!mounted) return;
          int count = 0;
          for (final msg in msgs) {
            final senderId = msg['sender_id'] as String?;
            if (senderId == buyerId) continue; // son míos

            final chatId = msg['chat_id'] as String?;
            if (chatId == null) continue;

            try {
              final chat = await _supabase
                  .from('chats')
                  .select('buyer_id')
                  .eq('id', chatId)
                  .maybeSingle();
              if (chat?['buyer_id'] == buyerId) count++;
            } catch (_) {}
          }
          if (mounted) setState(() => _unreadCount = count);
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentPageIndex != index) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth   = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 40, cacheWidth: 120),
        centerTitle: false,
        actions: [
          // ── Icono de chat con badge ──────────────────
          if (!auth.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BuyerChatsScreen(),
                      ),
                    ),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── Carrito ──────────────────────────────────
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined,
                color: theme.iconTheme.color),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentPageIndex = i),
          physics: const BouncingScrollPhysics(),
          children: const [
            HomeScreen(key: ValueKey('home')),
            SearchScreen(key: ValueKey('search')),
            MenuScreen(key: ValueKey('menu')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 1,
            ),
          ),
        ),
        child: BottomAppBar(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          padding: EdgeInsets.zero,
          height: 70,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavItem(
                    index: 0, icon: Icons.home_outlined, label: 'INICIO'),
              ),
              Expanded(
                child: _buildNavItem(
                    index: 1,
                    icon: Icons.search,
                    label: 'BUSCAR',
                    isCenter: true),
              ),
              Expanded(
                child: _buildNavItem(
                    index: 2, icon: Icons.menu, label: 'MENÚ'),
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
    final theme      = Theme.of(context);
    final isSelected = _currentPageIndex == index;
    final primary    = theme.colorScheme.primary;
    final unselected =
        theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;

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
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                icon,
                color: isCenter
                    ? (isSelected
                        ? theme.scaffoldBackgroundColor
                        : unselected)
                    : (isSelected ? primary : unselected),
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
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : unselected,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}