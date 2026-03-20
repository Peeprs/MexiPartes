import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

// Theme
import 'screens/core/app_theme.dart';
import 'providers/theme_provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/car_provider.dart';

// Screens - Auth
import 'screens/auth/screens/auth_wrapper.dart';
import 'screens/auth/screens/login_screen.dart';
import 'screens/auth/screens/register_screen.dart';
import 'screens/auth/screens/forgot_password_screen.dart';
import 'screens/auth/screens/email_confirmation_screen.dart';
import 'screens/auth/screens/privacy_policy_screen.dart';
import 'screens/auth/screens/cookie_notice_screen.dart';

// Screens - Car
import 'screens/car/screens/car_selection_screen.dart';
import 'screens/buyer_chats_screen.dart';

// Screens - Home
import 'screens/home/main_screen.dart';
import 'screens/user/usuarios_list_screen.dart';
import 'screens/user/user_crud_screen.dart';

// Screens - Orders
import 'screens/orders/orders_screen.dart';

// Screens - Address
import 'screens/address/screens/addresses_screen.dart';
import 'screens/address/screens/add_edit_address_screen.dart';

// Screens - Cart
import 'screens/cart/screens/cart_screen.dart';

// Screens - Checkout
import 'screens/checkout/screens/checkout_screen.dart';
import 'screens/checkout/screens/address_selection_screen.dart';
import 'screens/checkout/screens/processing_screen.dart';
import 'screens/checkout/screens/confirmation_screen.dart';

// Screens - Seller
import 'screens/seller/publish_product_screen.dart';
import 'screens/seller/seller_dashboard_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'services/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  await Supabase.initialize(
    url: 'https://numwrtupwzmdnzbrocje.supabase.co',
    anonKey: 'sb_publishable_72-9aK0-INOH4LFZOUJqKw_hxNb0Ou1',
  );

  try {
    await NotificationService().initialize();
    await FirebaseNotificationService().initialize();
  } catch (e) {
    debugPrint('Error al inicializar notificaciones: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NUEVO: ThemeProvider va primero para que esté disponible en todo
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      // Consumer del ThemeProvider para reconstruir MaterialApp al cambiar tema
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MexiPartes',

            // ── TEMAS ─────────────────────────────────────
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode, // Controlado por el provider

            home: const AuthWrapper(),

            routes: {
              '/login': (context) => const LoginScreen(),
              '/user_crud': (context) => const UsuarioCrudScreen(),
              '/usuarios': (context) => const UsuariosListScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot_password': (context) => const ForgotPasswordScreen(),
              '/main': (context) => const MainScreen(),
              '/email_confirmation': (context) =>
                  const EmailConfirmationScreen(),
              '/car_selection': (context) => const CarSelectionScreen(),
              '/privacy_policy': (context) => const PrivacyPolicyScreen(),
              '/cookie_notice': (context) => const CookieNoticeScreen(),
              '/buyer_chats': (context) => const BuyerChatsScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/addresses': (context) => const AddressesScreen(),
              '/add_edit_address': (context) => const AddEditAddressScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/address_selection': (context) => const AddressSelectionScreen(),
              '/processing': (context) => const ProcessingScreen(),
              '/confirmation': (context) => const ConfirmationScreen(),
              '/seller_dashboard': (context) => const SellerDashboardScreen(),
              '/publish_product': (context) => const PublishProductScreen(),
              '/edit_profile': (context) => Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = auth.usuarioActual;
                  if (user == null) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return UsuarioCrudScreen(usuario: user);
                },
              ),
            },
          );
        },
      ),
    );
  }
}
