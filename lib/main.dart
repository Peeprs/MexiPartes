import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
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
import 'services/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: 'https://numwrtupwzmdnzbrocje.supabase.co',
    anonKey: 'sb_publishable_72-9aK0-INOH4LFZOUJqKw_hxNb0Ou1',
  );

  try {
    await NotificationService().initialize();
    await FirebaseNotificationService().initialize();
    print('Notificaciones inicializadas');
  } catch (e) {
    print('Error al inicializar notificaciones: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AGREGAMOS EL MULTIPROVIDER AQUÍ
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MexiPartes',

        // Tema Premium Dark/Red/White
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black, // Negro puro
          primaryColor: Colors.red,

          // Definición de colores principales
          colorScheme: const ColorScheme.dark(
            primary: Colors.red, // Rojo principal
            onPrimary: Colors.white,
            secondary: Colors.redAccent,
            surface: Color(
              0xFF101010,
            ), // Superficies (tarjetas) ligeramente grises
            onSurface: Colors.white,
            error: Colors.redAccent,
          ),

          // Tipografía moderna (Google Fonts style placeholder)
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
            bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
          ),

          // Inputs (TextFields) estilo Dark
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            labelStyle: const TextStyle(color: Colors.white54),
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),

          // Botones Elevados (Rojos por defecto)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.red.withOpacity(0.4),
            ),
          ),

          // AppBars limpias
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            surfaceTintColor: Colors.black,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0A0A0A),
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),

        home: const AuthWrapper(),

        // La tabla de rutas se mantiene para la navegación interna (Navigator.pushNamed)
        routes: {
          '/login': (context) => const LoginScreen(),
          '/user_crud': (context) => const UsuarioCrudScreen(),
          '/usuarios': (context) => const UsuariosListScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/main': (context) => const MainScreen(),
          '/email_confirmation': (context) => const EmailConfirmationScreen(),
          '/car_selection': (context) => const CarSelectionScreen(),
          '/privacy_policy': (context) => const PrivacyPolicyScreen(),
          '/cookie_notice': (context) => const CookieNoticeScreen(),
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
      ),
    );
  }
}
