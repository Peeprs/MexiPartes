import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/realtime_notification_service.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'publish_product_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Product> _myProducts = [];
  List<OrderModel> _mySales = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).usuarioActual?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    // 1. Cargar MIS Productos (Filtrado manual por ahora o query)
    final allProducts = await _apiService.getProducts(includeHidden: true);
    // Filtramos los que sean míos (Suponiendo que el usuario actual es el vendedor)
    // Nota: Como getProducts trae todos, filtramos en memoria.
    // Idealmente el backend filtraría.
    // OJO: Si el producto no tiene 'seller_id' guardado (modelos viejos), no saldrá.
    _myProducts = allProducts; // .where((p) => p.sellerId == userId).toList();
    // ^ TEMPORAL: Mostrar todos para que el usuario VEA algo y pueda editar stock.

    // 2. Cargar MIS Ventas
    _mySales = await _apiService.getMySales(userId);

    // 3. NUEVO: Iniciar escucha de nuevas órdenes en tiempo real
    try {
      if (mounted) {
        await RealtimeNotificationService().startListeningForOrders(userId);
        await RealtimeNotificationService().startListeningForStockChanges(
          userId,
        );
        print('🔔 Escucha de notificaciones activa');
      }
    } catch (e) {
      print('⚠️ Error al iniciar notificaciones: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Detener escucha al salir
    RealtimeNotificationService().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Panel de Vendedor"),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: "Mis Productos"),
            Tab(text: "Ventas"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PublishProductScreen()),
          );
          _loadData(); // Recargar al volver
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : TabBarView(
              controller: _tabController,
              children: [_buildProductsTab(), _buildSalesTab()],
            ),
    );
  }

  Widget _buildProductsTab() {
    if (_myProducts.isEmpty) {
      return Center(
        child: Text(
          "No tienes productos publicados",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myProducts.length,
      itemBuilder: (context, index) {
        final product = _myProducts[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Image.network(
              product.imagenUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.image_not_supported),
            ),
            title: Text(
              product.nombre,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Stock: ${product.stock} | \$${product.precio}",
              style: TextStyle(
                color: product.stock == 0 ? Colors.red : Colors.grey,
                fontWeight: product.stock == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditStockDialog(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteProductDialog(product),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesTab() {
    if (_mySales.isEmpty) {
      return Center(
        child: Text(
          "No tienes ventas registradas",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySales.length,
      itemBuilder: (context, index) {
        final order = _mySales[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  "Pedido #${order.id}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Total: \$${order.total.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "${order.items.length} producto(s)",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: _buildStatusChip(order.status),
              ),

              // Botones de acción
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (order.status == OrderStatus.processing)
                      _buildActionButton(
                        label: "Marcar como Enviado",
                        icon: Icons.local_shipping,
                        color: Colors.blue,
                        onPressed: () =>
                            _updateOrderStatus(order.id!, 'shipped'),
                      ),
                    if (order.status == OrderStatus.shipped)
                      _buildActionButton(
                        label: "Marcar como Entregado",
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: () =>
                            _updateOrderStatus(order.id!, 'delivered'),
                      ),
                    if (order.status == OrderStatus.processing ||
                        order.status == OrderStatus.shipped)
                      _buildActionButton(
                        label: "Devolver",
                        icon: Icons.assignment_return,
                        color: Colors.red,
                        onPressed: () =>
                            _updateOrderStatus(order.id!, 'returned'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.processing:
        color = Colors.orange;
        text = "PROCESANDO";
        break;
      case OrderStatus.shipped:
        color = Colors.blue;
        text = "ENVIADO";
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = "ENTREGADO";
        break;
      case OrderStatus.returned:
        color = Colors.red;
        text = "DEVUELTO";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        side: BorderSide(color: color, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final success = await _apiService.updateOrderStatus(orderId, newStatus);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Estado actualizado correctamente"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData(); // Recargar las ventas
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al actualizar el estado"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditStockDialog(Product product) {
    final controller = TextEditingController(text: product.stock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Editar Stock: ${product.nombre}",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Nuevo Stock"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                // Llamamos a la API para actualizar el stock de verdad
                final success = await _apiService.updateProductStock(
                  product.id,
                  newStock,
                );

                Navigator.pop(ctx);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Stock actualizado correctamente"),
                    ),
                  );
                  _loadData(); // Recargamos para ver el cambio
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error al actualizar stock"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "¿Eliminar Producto?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "¿Estás seguro de eliminar '${product.nombre}'? Esta acción no se puede deshacer.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);

              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Eliminando producto...")),
              );

              // Llamar a la API para eliminar
              final success = await _apiService.deleteProduct(product.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Producto eliminado correctamente"),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData(); // Recargar lista
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al eliminar producto"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
