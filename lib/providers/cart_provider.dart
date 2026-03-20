import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String _userId = 'guest'; // Default to guest

  List<CartItem> get items => _items;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal; // Assuming free shipping for now

  CartProvider() {
    // Inicialmente cargamos como invitado o esperamos a init
    _loadCart();
  }

  // Inicializar con el ID del usuario actual para separar carritos
  Future<void> init(String userId) async {
    if (_userId != userId) {
      _userId = userId;
      await _loadCart();
    }
  }

  void addItem(
    String id,
    String name,
    double price,
    String? imageUrl, {
    String sellerId = '',
  }) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      // Si ya existe, actualizamos cantidad y aseguramos sellerId
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
        sellerId: sellerId.isNotEmpty ? sellerId : _items[index].sellerId,
      );
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
          sellerId: sellerId,
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String id, int change) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final newQuantity = _items[index].quantity + change;
      if (newQuantity <= 0) {
        removeFromCart(id);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        _saveCart();
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _items.map((item) => item.toJson()).toList(),
    );
    // Clave única por usuario
    await prefs.setString('cart_items_$_userId', encodedData);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    // Cargar clave específica del usuario
    final String? encodedData = prefs.getString('cart_items_$_userId');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _items = decodedData.map((item) => CartItem.fromJson(item)).toList();
    } else {
      _items = [];
    }
    notifyListeners();
  }
}
