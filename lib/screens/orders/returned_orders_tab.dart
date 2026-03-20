import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'orders_list_tab.dart';

class ReturnedOrdersTab extends StatelessWidget {
  const ReturnedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListTab(
      statusFilters: [OrderStatus.returned],
      emptyIcon: Icons.assignment_return_outlined,
      emptyTitle: "Sin devoluciones",
      emptySubtitle: "Historial de devoluciones o cancelaciones.",
    );
  }
}
