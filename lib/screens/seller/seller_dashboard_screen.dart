import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/realtime_notification_service.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'publish_product_screen.dart';
import '../../shared/widgets/seller_chat_fab.dart'; // <-- NUEVO

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

    final allProducts = await _apiService.getProducts(includeHidden: true);
    _myProducts = allProducts;
    _mySales = await _apiService.getMySales(userId);

    try {
      if (mounted) {
        await RealtimeNotificationService().startListeningForOrders(userId);
        await RealtimeNotificationService().startListeningForStockChanges(userId);
      }
    } catch (e) {
      debugPrint('Error notificaciones: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    RealtimeNotificationService().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Panel de Vendedor'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Productos'),
            Tab(text: 'Ventas'),
          ],
        ),
      ),

      // ── FABs apilados ───────────────────────────────
      // floatingActionButton acepta una Column para apilar
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Chat con compradores (con badge de no leídos)
          const SellerChatFab(),
          const SizedBox(height: 12),
          // 2. Publicar producto
          FloatingActionButton(
            heroTag: 'publish_fab',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PublishProductScreen(),
                ),
              );
              _loadData();
            },
            backgroundColor: Colors.red,
            tooltip: 'Publicar producto',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : TabBarView(
              controller: _tabController,
              children: [_buildProductsTab(), _buildSalesTab()],
            ),
    );
  }

  // ──────────────────────────────────────────────────────
  // TAB: Mis Productos
  // ──────────────────────────────────────────────────────
  Widget _buildProductsTab() {
    if (_myProducts.isEmpty) {
      return Center(
        child: Text(
          'No tienes productos publicados',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myProducts.length,
      itemBuilder: (context, index) {
        final product = _myProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imagenUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            title: Text(
              product.nombre,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Stock: ${product.stock} | \$${product.precio.toStringAsFixed(2)}',
              style: TextStyle(
                color: product.stock == 0
                    ? Colors.red
                    : Theme.of(context).textTheme.bodySmall?.color,
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

  // ──────────────────────────────────────────────────────
  // TAB: Ventas
  // ──────────────────────────────────────────────────────
  Widget _buildSalesTab() {
    if (_mySales.isEmpty) {
      return Center(
        child: Text(
          'No tienes ventas registradas',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySales.length,
      itemBuilder: (context, index) {
        final order = _mySales[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Pedido #${order.id}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Total: \$${order.total.toStringAsFixed(2)}'),
                    Text('${order.items.length} producto(s)'),
                  ],
                ),
                trailing: _buildStatusChip(order.status),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (order.status == OrderStatus.processing)
                      _buildActionButton(
                        label: 'Marcar Enviado',
                        icon: Icons.local_shipping,
                        color: Colors.blue,
                        onPressed: () =>
                            _updateOrderStatus(order.id!, 'shipped'),
                      ),
                    if (order.status == OrderStatus.shipped)
                      _buildActionButton(
                        label: 'Marcar Entregado',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: () =>
                            _updateOrderStatus(order.id!, 'delivered'),
                      ),
                    if (order.status == OrderStatus.processing ||
                        order.status == OrderStatus.shipped)
                      _buildActionButton(
                        label: 'Devolver',
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

  // ──────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────
  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.processing:
        color = Colors.orange; text = 'PROCESANDO'; break;
      case OrderStatus.shipped:
        color = Colors.blue;   text = 'ENVIADO';    break;
      case OrderStatus.delivered:
        color = Colors.green;  text = 'ENTREGADO';  break;
      case OrderStatus.returned:
        color = Colors.red;    text = 'DEVUELTO';   break;
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
        elevation: 0,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final success = await _apiService.updateOrderStatus(orderId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Estado actualizado' : 'Error al actualizar',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) _loadData();
    }
  }

  void _showEditStockDialog(Product product) {
    final controller = TextEditingController(text: product.stock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stock: ${product.nombre}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nuevo stock'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock == null) return;
              Navigator.pop(ctx);
              final ok = await _apiService.updateProductStock(
                product.id, newStock,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Stock actualizado' : 'Error al actualizar stock',
                    ),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
                if (ok) _loadData();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Producto?'),
        content: Text(
          "¿Eliminar '${product.nombre}'? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _apiService.deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Producto eliminado' : 'Error al eliminar',
                    ),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
                if (ok) _loadData();
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}