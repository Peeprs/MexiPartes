import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Conexión con el Provider para obtener datos y funciones
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuarioActual;

    // Calculamos la inicial para el Avatar o usamos icono para invitado
    final bool isGuest = authProvider.isGuest;
    final String inicial = (usuario?.strNombre.isNotEmpty == true)
        ? usuario!.strNombre[0].toUpperCase()
        : "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),

            // --- ENCABEZADO DE PERFIL ---
            InkWell(
              onTap: () => _handleMenuAction(
                context,
                authProvider,
                () {
                  // Navegar a editar perfil (definiremos la ruta luego)
                  Navigator.pushNamed(context, '/edit_profile');
                },
                allowGuest: false, // Bloquear invitado
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isGuest
                          ? Colors.grey[800]
                          : Colors.redAccent,
                      child: isGuest
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                          : Text(
                              inicial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest || usuario == null
                                ? "Invitado"
                                : "${usuario.strNombre} ${usuario.strApellidoPaterno}"
                                      .trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                isGuest
                                    ? "Toca para registrarte"
                                    : (usuario?.strCorreo ?? "Sin correo"),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              if (!isGuest)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // --- SECCIÓN VENDEDOR (Solo si es vendedor) ---
            if (usuario?.bitEsVendedor == true) ...[
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  "MI TIENDA",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.storefront,
                title: 'Panel de Vendedor',
                onTap: () {
                  Navigator.pushNamed(context, '/seller_dashboard');
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.add_circle_outline,
                title: 'Publicar Producto',
                onTap: () {
                  Navigator.pushNamed(context, '/publish_product');
                },
              ),
              const Divider(color: Colors.white24, height: 40),
            ],

            // --- OPCIONES DE MENÚ ---
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Pedidos',
              onTap: () => _handleMenuAction(
                context,
                authProvider,
                () => Navigator.pushNamed(context, '/orders'),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Mis Direcciones',
              onTap: () => _handleMenuAction(
                context,
                authProvider,
                () => Navigator.pushNamed(context, '/addresses'),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.directions_car_outlined,
              title: 'Mis Vehículos',
              onTap: () => _handleMenuAction(
                context,
                authProvider,
                () => Navigator.pushNamed(context, '/car_selection'),
              ),
            ),
            // --- BOTÓN CERRAR SESIÓN ---
            if (!isGuest)
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, authProvider),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            // --- ENLACES LEGALES (Juntos y menos prominentes) ---
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/privacy_policy'),
                  child: const Text(
                    'Política de Privacidad',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/cookie_notice'),
                  child: const Text(
                    'Cookies',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            if (isGuest)
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Iniciar Sesión / Registrarse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- BOTÓN ELIMINAR CUENTA ---
            if (!authProvider.isGuest)
              TextButton.icon(
                onPressed: () =>
                    _showDeleteAccountDialog(context, authProvider),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Eliminar mi cuenta',
                  style: TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // HELPER: CONTROL DE ACCESO INVITADOS
  // ----------------------------------------------------------------------
  void _handleMenuAction(
    BuildContext context,
    AuthProvider authProvider,
    VoidCallback action, {
    bool allowGuest = false,
  }) {
    if (authProvider.isGuest && !allowGuest) {
      // Mostrar alerta
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Función Restringida",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Esta función es exclusiva para usuarios registrados. \n\nRegístrate o inicia sesión para acceder a pedidos, direcciones y más.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Cerrar diálogo
                Navigator.pushNamed(ctx, '/login'); // Ir a login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Iniciar Sesión"),
            ),
          ],
        ),
      );
    } else {
      action();
    }
  }

  // ----------------------------------------------------------------------
  // HELPER: DIÁLOGO DE CONFIRMACIÓN DE LOGOUT
  // ----------------------------------------------------------------------
  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Cerrar Sesión",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "¿Estás seguro que deseas salir?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text(
              "Salir",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // HELPER: DIÁLOGO DE ELIMINAR CUENTA (CON PASSWORD)
  // ----------------------------------------------------------------------
  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Eliminar Cuenta",
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Esta acción borrará todos tus datos permanentemente. Ingresa tu contraseña para confirmar.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final pwd = passwordController.text;
              if (pwd.isEmpty) return;

              // 1. Cerramos el diálogo primero para que no estorbe
              Navigator.pop(ctx);

              // 2. Llamamos al método DELETE del Provider
              final success = await authProvider.deleteAccount(pwd);

              // 3. VALIDAMOS EL RESULTADO
              if (success) {
                // ✅ ESTO ES LO QUE FALTABA:
                // Si se borró, forzamos la salida inmediata al Login y borramos el historial
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } else {
                // Si falló (contraseña incorrecta), mostramos error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Error: Contraseña incorrecta o fallo de red.",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "ELIMINAR DEFINITIVAMENTE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // HELPER: DISEÑO DE LOS ITEMS DEL MENÚ
  // ----------------------------------------------------------------------
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
