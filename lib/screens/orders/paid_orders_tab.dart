import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'orders_list_tab.dart';

class PaidOrdersTab extends StatelessWidget {
  const PaidOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListTab(
      statusFilters: [OrderStatus.processing],
      emptyIcon: Icons.payment_outlined,
      emptyTitle: "Sin pedidos procesando",
      emptySubtitle:
          "Tus compras recientes aparecerán aquí mientras se preparan.",
    );
  }
}
