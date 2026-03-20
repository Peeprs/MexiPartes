import 'package:flutter/material.dart';
import 'delivered_orders_tab.dart';
import 'shipped_orders_tab.dart';
import 'paid_orders_tab.dart';
import 'returned_orders_tab.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Entregados'),
            Tab(text: 'Enviados'),
            Tab(text: 'Pagados'),
            Tab(text: 'Devueltos'),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Prevent magenta flash during transitions
        child: TabBarView(
          controller: _tabController,
          children: const [
            DeliveredOrdersTab(),
            ShippedOrdersTab(),
            PaidOrdersTab(),
            ReturnedOrdersTab(),
          ],
        ),
      ),
    );
  }
}
