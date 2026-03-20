import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/api_services.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/car_provider.dart';
import '../product/product_detail_screen.dart';
import 'widgets/section_header.dart'; // Import SectionHeader

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Future<Map<String, List<Product>>>? _dataFuture;
  String? _lastCarModel;

  final List<String> _categories = [
    'Motor',
    'Frenos',
    'Suspensión',
    'Eléctrico',
    'Interiores',
    'Carrocería'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final carProv = Provider.of<CarProvider>(context);
    if (_dataFuture == null || carProv.selectedModel != _lastCarModel) {
      _lastCarModel = carProv.selectedModel;
      _dataFuture = _loadAllData(carProv);
    }
  }

  Future<Map<String, List<Product>>> _loadAllData(CarProvider carProv) async {
    final futures = <Future>[];
    futures.add(_apiService.getFeaturedProducts());
    futures.add(_apiService.getCheapestProducts());
    futures.add(_apiService.getBestSellers());
    
    if (carProv.hasCarSelected) {
      futures.add(_apiService.getProductsByVehicle(carProv.selectedModel!));
    } else {
      futures.add(Future.value(<Product>[]));
    }

    for (var cat in _categories) {
      futures.add(_apiService.getProductsByCategory(cat));
    }

    final results = await Future.wait(futures);
    final data = <String, List<Product>>{};
    
    data['featured'] = results[0] as List<Product>;
    data['cheapest'] = results[1] as List<Product>;
    data['best_sellers'] = results[2] as List<Product>;
    data['vehicle'] = results[3] as List<Product>;
    
    for (int i = 0; i < _categories.length; i++) {
      data[_categories[i]] = results[4 + i] as List<Product>;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final carProv = Provider.of<CarProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Banner de envío animado
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: FastShippingBanner(),
          ),
          const SizedBox(height: 20),

          FutureBuilder<Map<String, List<Product>>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoading();
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar información',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                );
              }

              final data = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Carrusel Horizontal "Destacados"
                  if ((data['featured'] ?? []).isNotEmpty) ...[
                    SectionHeader(
                      title: 'Destacados',
                      onTap: () {},
                    ),
                    _buildFeaturedCarousel(data['featured']!),
                    const SizedBox(height: 10),
                  ],

                  // 3. Para tu carro
                  if (carProv.hasCarSelected && (data['vehicle'] ?? []).isNotEmpty) ...[
                    SectionHeader(
                      title: 'Para tu ${carProv.selectedBrand} ${carProv.selectedModel}',
                      onTap: () {},
                    ),
                    _buildHorizontalList(data['vehicle']!),
                    const SizedBox(height: 10),
                  ],

                  // 4. Más Vendidos
                  if ((data['best_sellers'] ?? []).isNotEmpty) ...[
                    SectionHeader(
                      title: 'Más Vendidos',
                      onTap: () {},
                    ),
                    _buildHorizontalList(data['best_sellers']!),
                    const SizedBox(height: 10),
                  ],

                  // 5. Las Mejores Ofertas (Cheapest)
                  if ((data['cheapest'] ?? []).isNotEmpty) ...[
                    SectionHeader(
                      title: 'Las Mejores Ofertas',
                      onTap: () {},
                    ),
                    _buildHorizontalList(data['cheapest']!),
                    const SizedBox(height: 10),
                  ],

                  // 6. Por categorías
                  for (var cat in _categories)
                    if ((data[cat] ?? []).isNotEmpty) ...[
                      SectionHeader(
                        title: cat,
                        onTap: () {},
                      ),
                      _buildHorizontalList(data[cat]!),
                      const SizedBox(height: 10),
                    ],
                ],
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<Product> products) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 240.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: products.take(5).map((product) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductDetailScreen(),
                    settings: RouteSettings(arguments: product),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardTheme.color,
                  image: DecorationImage(
                    image: product.imagenUrl.isNotEmpty
                        ? CachedNetworkImageProvider(product.imagenUrl)
                        : const AssetImage('assets/images/logo.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.categoria.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        product.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalList(List<Product> products) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildProductCard(products[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(3, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _PulseWidget(width: 150, height: 24),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _PulseWidget(
                      width: 180,
                      height: 280,
                      borderRadius: 12,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductDetailScreen(),
            settings: RouteSettings(arguments: product),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.imagenUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: product.imagenUrl,
                        memCacheWidth: 400,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[500], size: 40),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardTheme.color,
                      child: Center(child: Icon(Icons.image, color: Colors.grey[500], size: 40)),
                    ),
                  if (product.stock == 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Center(
                        child: Text(
                          "AGOTADO",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoria.toUpperCase(),
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.nombre,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (product.stock > 0)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).addItem(
                                product.id.toString(),
                                product.nombre,
                                product.precio,
                                product.imagenUrl,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text('${product.nombre} agregado', overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
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
    );
  }
}

class FastShippingBanner extends StatefulWidget {
  const FastShippingBanner({super.key});

  @override
  State<FastShippingBanner> createState() => _FastShippingBannerState();
}

class _FastShippingBannerState extends State<FastShippingBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Servicio Express Activado! Tu pedido llegará hoy.', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFFF5252)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF5252).withOpacity(0.5 * _opacityAnimation.value), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, color: Colors.white.withOpacity(_opacityAnimation.value), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'ENVÍO MISMO-DÍA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 2), blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Transform.translate(
                    offset: Offset(5 * _controller.value, 0),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom simple pulse animation for the shimmer
class _PulseWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _PulseWidget({required this.width, required this.height, this.borderRadius = 8});

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _colorTween = ColorTween(
      begin: isDark ? Colors.grey[800] : Colors.grey[300],
      end: isDark ? Colors.grey[700] : Colors.grey[200],
    ).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorTween.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
