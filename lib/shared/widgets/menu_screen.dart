import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider  = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final usuario  = authProvider.usuarioActual;
    final isGuest  = authProvider.isGuest;
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    final String inicial = (usuario?.strNombre.isNotEmpty == true)
        ? usuario!.strNombre[0].toUpperCase()
        : '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),

            // ── HEADER PERFIL ──────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleMenuAction(
                context,
                authProvider,
                () => Navigator.pushNamed(context, '/edit_profile'),
                allowGuest: false,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isGuest
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.primary,
                      child: isGuest
                          ? Icon(
                              Icons.person,
                              color: Theme.of(context).iconTheme.color,
                              size: 30,
                            )
                          : Text(
                              inicial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                                ? 'Invitado'
                                : '${usuario.strNombre} ${usuario.strApellidoPaterno}'.trim(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGuest
                                ? 'Toca para registrarte'
                                : (usuario?.strCorreo ?? 'Sin correo'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (!isGuest)
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 8),

            // ── TEMA ───────────────────────────────────────
            _buildSectionLabel(context, 'APARIENCIA'),
            const SizedBox(height: 8),

            // Selector de 3 opciones: Automático / Claro / Oscuro
            _ThemeSelector(themeProvider: themeProvider),

            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 8),

            // ── VENDEDOR ───────────────────────────────────
            if (usuario?.bitEsVendedor == true) ...[
              _buildSectionLabel(context, 'MI TIENDA'),
              const SizedBox(height: 8),
              _buildMenuItem(
                context,
                icon: Icons.storefront,
                title: 'Panel de Vendedor',
                onTap: () => Navigator.pushNamed(context, '/seller_dashboard'),
              ),
              _buildMenuItem(
                context,
                icon: Icons.add_circle_outline,
                title: 'Publicar Producto',
                onTap: () => Navigator.pushNamed(context, '/publish_product'),
              ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 8),
            ],

            // ── OPCIONES ───────────────────────────────────
            _buildSectionLabel(context, 'MI CUENTA'),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Pedidos',
              onTap: () => _handleMenuAction(
                context, authProvider,
                () => Navigator.pushNamed(context, '/orders'),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Mis Direcciones',
              onTap: () => _handleMenuAction(
                context, authProvider,
                () => Navigator.pushNamed(context, '/addresses'),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.directions_car_outlined,
              title: 'Mis Vehículos',
              onTap: () => _handleMenuAction(
                context, authProvider,
                () => Navigator.pushNamed(context, '/car_selection'),
              ),
            ),

            const SizedBox(height: 24),

            // ── CERRAR SESIÓN ──────────────────────────────
            if (!isGuest)
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, authProvider),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

            // ── INVITADO ───────────────────────────────────
            if (isGuest)
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Iniciar Sesión / Registrarse'),
              ),

            // ── LEGALES ────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legalLink(context, 'Privacidad', '/privacy_policy'),
                const SizedBox(width: 24),
                _legalLink(context, 'Cookies', '/cookie_notice'),
              ],
            ),

            // ── ELIMINAR CUENTA ────────────────────────────
            if (!isGuest)
              Center(
                child: TextButton.icon(
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
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // HELPERS DE UI
  // ──────────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, size: 26),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _legalLink(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // LÓGICA
  // ──────────────────────────────────────────────────────
  void _handleMenuAction(
    BuildContext context,
    AuthProvider authProvider,
    VoidCallback action, {
    bool allowGuest = false,
  }) {
    if (authProvider.isGuest && !allowGuest) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Función Restringida'),
          content: const Text(
            'Regístrate o inicia sesión para acceder a esta función.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(ctx, '/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
    } else {
      action();
    }
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Eliminar Cuenta',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Esta acción borrará todos tus datos permanentemente. Ingresa tu contraseña para confirmar.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final pwd = passwordController.text;
              if (pwd.isEmpty) return;
              Navigator.pop(ctx);
              final success = await authProvider.deleteAccount(pwd);
              if (success && context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña incorrecta o fallo de red.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// WIDGET: Selector de tema con 3 opciones
// ──────────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final ThemeProvider themeProvider;
  const _ThemeSelector({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _option(context, AppThemeMode.system, Icons.brightness_auto, 'Auto'),
          _option(context, AppThemeMode.light,  Icons.light_mode_outlined, 'Claro'),
          _option(context, AppThemeMode.dark,   Icons.dark_mode_outlined, 'Oscuro'),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    AppThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = themeProvider.mode == mode;
    final primary    = Theme.of(context).colorScheme.primary;
    final textColor  = Theme.of(context).textTheme.bodyMedium?.color;

    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : textColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}