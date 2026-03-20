import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import 'order_item_card.dart';
import '../../shared/widgets/common_empty_state.dart';

class OrdersListTab extends StatefulWidget {
  final List<OrderStatus> statusFilters;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  const OrdersListTab({
    super.key,
    required this.statusFilters,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  bool get wantKeepAlive => true; // Mantener estado al cambiar tab

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Refrescar cada 5 segundos para actualizar el estado simulado
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final userId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).usuarioActual?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final orders = await _apiService.getMyOrders(userId);

    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para KeepAlive

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Filtrar órdenes por estado (usando el getter dinámico 'status' que depende del tiempo)
    final filteredOrders = _orders.where((order) {
      return widget.statusFilters.contains(order.status);
    }).toList();

    if (filteredOrders.isEmpty) {
      return CommonEmptyState(
        icon: widget.emptyIcon,
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
        buttonText: 'Explorar Productos',
        onButtonPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return OrderItemCard(order: filteredOrders[index]);
          },
        ),
      ),
    );
  }
}
