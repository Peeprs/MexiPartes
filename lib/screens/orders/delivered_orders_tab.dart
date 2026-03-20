import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'orders_list_tab.dart';

class DeliveredOrdersTab extends StatelessWidget {
  const DeliveredOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListTab(
      statusFilters: [OrderStatus.delivered],
      emptyIcon: Icons.check_circle_outline,
      emptyTitle: "Sin pedidos entregados",
      emptySubtitle: "Tus pedidos completados aparecerán aquí.",
    );
  }
}
