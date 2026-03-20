import '../models/address_model.dart';

enum OrderStatus {
  processing, // Pagado, esperando envío
  shipped, // Enviado
  delivered, // Entregado
  returned, // Devuelto
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;
  final String sellerId; // Quién vendió esto

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.sellerId,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'price': price,
    'quantity': quantity,
    'image_url': imageUrl,
    'seller_id': sellerId,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['image_url'],
      sellerId: json['seller_id'] ?? '',
    );
  }
}

class OrderModel {
  final int? id;
  final String buyerId;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final Address shippingAddress;
  final OrderStatus status; // Ahora persistente desde BD

  OrderModel({
    this.id,
    required this.buyerId,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.shippingAddress,
    this.status = OrderStatus.processing, // Por defecto
  });

  Map<String, dynamic> toJson() => {
    'buyer_id': buyerId,
    'total': total,
    'created_at': createdAt.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'shipping_address': shippingAddress.toJson(),
    'status': _statusToString(status),
  };

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.returned:
        return 'returned';
    }
  }

  static OrderStatus _statusFromString(String? status) {
    switch (status) {
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.processing;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      shippingAddress: Address.fromJson(json['shipping_address']),
      status: _statusFromString(json['status']),
    );
  }
}
