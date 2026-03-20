import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/cart_item_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart  = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyCart(context, theme)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) =>
                        _buildCartItem(ctx, cart, cart.items[i], theme),
                  ),
          ),
          if (cart.items.isNotEmpty) _buildSummary(context, cart, theme),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 80,
                  color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 30),
            Text('Tu carrito está vacío',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('¡Agrega las mejores refacciones para tu auto!',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('EXPLORAR CATÁLOGO'),
            ),
          ],
        ),
      );

  Widget _buildCartItem(BuildContext context, CartProvider cart, CartItem item, ThemeData theme) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      onDismissed: (_) {
        cart.removeFromCart(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado del carrito')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: theme.dividerColor),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.image, color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  _qtyBtn(icon: Icons.remove, onTap: () => cart.updateQuantity(item.id, -1), theme: theme),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${item.quantity}',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  _qtyBtn(icon: Icons.add, onTap: () => cart.updateQuantity(item.id, 1), theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap, required ThemeData theme}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: theme.textTheme.bodyMedium?.color),
        ),
      );

  Widget _buildSummary(BuildContext context, CartProvider cart, ThemeData theme) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Subtotal', cart.subtotal, theme),
            const SizedBox(height: 10),
            _summaryRow('Envío', 0, theme),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: theme.dividerColor),
            ),
            _summaryRow('Total', cart.total, theme, isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/checkout', arguments: cart.items),
                child: const Text('PROCEDER AL PAGO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      );

  Widget _summaryRow(String label, double amount, ThemeData theme, {bool isTotal = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? theme.textTheme.titleLarge?.copyWith(fontSize: 18)
                  : theme.textTheme.bodyMedium),
          Text(
            amount == 0 && label == 'Envío' ? 'GRATIS' : '\$${amount.toStringAsFixed(2)}',
            style: (amount == 0 && label == 'Envío')
                ? const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                : isTotal
                    ? theme.textTheme.titleLarge?.copyWith(fontSize: 22)
                    : theme.textTheme.bodyLarge,
          ),
        ],
      );
}