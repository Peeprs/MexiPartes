import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/car_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final car = Provider.of<CarProvider>(context, listen: false);
    car.hasCarSelected ? _fetchByVehicle() : _search('');
  }

  Future<void> _fetchByVehicle() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final car = Provider.of<CarProvider>(context, listen: false);
      final r = await _api.getProductsByVehicle(car.selectedModel ?? '');
      if (mounted) setState(() => _products = r);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Error al cargar productos');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String q) async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final r = q.isEmpty ? await _api.getProducts() : await _api.searchProducts(q);
      if (mounted) setState(() => _products = r);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Error en la búsqueda');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final car   = Provider.of<CarProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: '¿Qué buscas hoy?',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchCtrl.clear(); _loadInitial(); },
                      ),
                    ),
                  ),
                  if (car.hasCarSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car, color: theme.colorScheme.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${car.selectedBrand} ${car.selectedModel}',
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: car.clearCar,
                              child: Icon(Icons.close, size: 16, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Resultados ──────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                      : _products.isEmpty
                          ? _buildEmpty(theme)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _products.length,
                              itemBuilder: (ctx, i) => _buildCard(ctx, _products[i], theme),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text('Sin resultados', style: theme.textTheme.bodyLarge),
          ],
        ),
      );

  Widget _buildCard(BuildContext context, Product product, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    image: product.imagenUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imagenUrl),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: product.imagenUrl.isEmpty
                      ? Icon(Icons.broken_image, color: theme.textTheme.bodySmall?.color)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.categoria.toUpperCase(),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(product.nombre,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('\$${product.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add_shopping_cart,
                                  color: Colors.white, size: 20),
                              constraints:
                                  const BoxConstraints(minWidth: 40, minHeight: 40),
                              onPressed: () {
                                Provider.of<CartProvider>(context, listen: false)
                                    .addItem(product.id, product.nombre,
                                        product.precio, product.imagenUrl);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('${product.nombre} agregado'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              },
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
      ),
    );
  }
}