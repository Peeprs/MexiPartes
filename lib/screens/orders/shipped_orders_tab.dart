import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'orders_list_tab.dart';

class ShippedOrdersTab extends StatelessWidget {
  const ShippedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListTab(
      statusFilters: [OrderStatus.shipped],
      emptyIcon: Icons.local_shipping_outlined,
      emptyTitle: "Sin pedidos en camino",
      emptySubtitle: "Toda la información de tus envíos vivirá aquí.",
    );
  }
}
