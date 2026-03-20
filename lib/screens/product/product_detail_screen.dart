import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../chat_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Product? product =
        ModalRoute.of(context)?.settings.arguments as Product?;

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text("Producto no encontrado")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEN GRANDE ---
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.imagenUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imagenUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: isDark ? Colors.grey[850] : Colors.grey[300],
                            child: Icon(
                              Icons.broken_image,
                              color: isDark ? Colors.white24 : Colors.black26,
                              size: 50,
                            ),
                          ),
                        )
                      : Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            color: isDark ? Colors.white24 : Colors.black26,
                            size: 50,
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- DETALLES ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      product.categoria.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    product.nombre,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Precio
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),

                  Text(
                    "Descripción",
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    product.descripcion.isNotEmpty
                        ? product.descripcion
                        : "Sin descripción disponible.",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -----------------------------------------------
                  // BOTÓN CHAT CON VENDEDOR
                  // Solo si hay vendedor y el usuario es diferente
                  // -----------------------------------------------
                  if (product.sellerId != null &&
                      product.sellerId!.isNotEmpty)
                    _ChatButton(product: product),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardTheme.color,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: ElevatedButton(
          onPressed: product.stock == 0
              ? null
              : () {
                  final cart =
                      Provider.of<CartProvider>(context, listen: false);
                  cart.addItem(
                    product.id.toString(),
                    product.nombre,
                    product.precio,
                    product.imagenUrl,
                    sellerId: product.sellerId ?? '',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${product.nombre} agregado al carrito!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'VER CARRITO',
                        textColor: Colors.white,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/cart'),
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                product.stock == 0 ? Colors.grey[800] : Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            product.stock == 0 ? 'AGOTADO' : 'AGREGAR AL CARRITO',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------
// Widget separado para el botón de chat
// Maneja el estado de carga de forma independiente
// -----------------------------------------------
class _ChatButton extends StatefulWidget {
  final Product product;
  const _ChatButton({required this.product});

  @override
  State<_ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<_ChatButton> {
  bool _isLoading = false;

  Future<void> _openChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Bloquear invitados
    if (authProvider.isGuest || authProvider.usuarioActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para chatear con el vendedor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUserId = authProvider.usuarioActual!.id;
    final sellerId = widget.product.sellerId!;

    // No chatear consigo mismo (si eres el vendedor de este producto)
    if (currentUserId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este es tu propio producto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final chatService = ChatService();
      final chatId = await chatService.getOrCreateChat(
        sellerId: sellerId,
        productId: widget.product.id,
        productName: widget.product.nombre,
      );

      if (!mounted) return;

      // Navegar al chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserName: 'Vendedor', // Puedes mejorar esto fetching el nombre
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _openChat,
        icon: _isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )
            : const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(
          _isLoading ? 'Abriendo chat...' : 'Preguntar al vendedor',
          style: const TextStyle(fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black),
          side: BorderSide(color: isDark ? Colors.white30 : Colors.black38),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}