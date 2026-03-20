class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final int stock;
  final String? sellerId;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    required this.stock,
    this.sellerId,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? 'Producto Desconocido',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      precio: (json['precio'] ?? 0.0).toDouble(),
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'] ?? '',
      categoria: json['categoria'] ?? '',
      stock: json['stock'] ?? 0,
      sellerId: json['seller_id'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(), // Fallback si no existe la columna
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // No enviamos ID si es autogenerado (en create), pero para updates sí.
      // Si la DB es bigint e id es "", fallará.
      // Mejor omitimos ID en toJson si es para insertar, y lo usamos explícito en updates.
      // Si el id es numérico, postgres lo maneja.
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'categoria': categoria,
      'stock': stock,
      'seller_id': sellerId,
      // 'updated_at': updatedAt.toIso8601String(), // Generalmente manejado por la DB
    };
  }
}
