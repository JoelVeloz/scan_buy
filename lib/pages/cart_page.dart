import 'package:flutter/material.dart';
import 'package:scan_buy/main.dart';
import 'package:scan_buy/models/cart_storage.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  Future<List<CartItem>> _cartFuture = CartStorage.loadCart();

  void refreshCart() {
    print("Refreshing cart");
    setState(() {
      _cartFuture = CartStorage.loadCart();
    });
    // Refrescar de nuevo después de 5 segundos
    Future.delayed(const Duration(microseconds: 500), () async {
      final items = await CartStorage.loadCart();
      setState(() {
        _cartFuture = Future.value(
          items,
        ); // actualiza el FutureBuilder con los datos listos
      });
      print("Cart refreshed after 5 seconds");
    });
  }

  double _calculateSubtotal(List<CartItem> items) =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);

  double _calculateImpuestos(List<CartItem> items) =>
      _calculateSubtotal(items) * 0.15;

  double _calculateTotal(List<CartItem> items) =>
      _calculateSubtotal(items) + _calculateImpuestos(items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                color: const Color(0xFFF4B048),
                child: const Center(
                  child: Text(
                    'Carrito',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),

            // Lista de items con FutureBuilder
            SliverToBoxAdapter(
              child: FutureBuilder<List<CartItem>>(
                future: _cartFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.orange.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "¡Tu carrito está vacío!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Agrega productos para verlos aquí.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildCartItem(item, index);
                    }).toList(),
                  );
                },
              ),
            ),

            // Totales
            SliverToBoxAdapter(
              child: FutureBuilder<List<CartItem>>(
                future: _cartFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return const SizedBox();
                  final items = snapshot.data!;
                  final subtotal = _calculateSubtotal(items);
                  final impuestos = _calculateImpuestos(items);
                  final total = _calculateTotal(items);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _lineaTotal('Subtotal', subtotal),
                        _lineaTotal('Impuestos (15%)', impuestos),
                        const SizedBox(height: 6),
                        _lineaTotal('Total', total, isBold: true),
                        const SizedBox(height: 10),
                        const Text(
                          'Por favor, acérquese a caja para realizar el pago. ✅',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2F80ED), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          _CantidadControl(
            cantidad: item.quantity,
            onDecrement: () async {
              await CartStorage.decrementItem(item.id);
              refreshCart();
            },
            onIncrement: () async {
              await CartStorage.incrementItem(item.id);
              refreshCart();
            },
          ),
        ],
      ),
    );
  }

  Widget _lineaTotal(String label, double value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 16 : 14,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}

class _CantidadControl extends StatelessWidget {
  final int cantidad;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CantidadControl({
    required this.cantidad,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    const Color acento = Color(0xFFF4B048);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BotonCircular(icon: Icons.remove, onPressed: onDecrement),
        const SizedBox(width: 10),
        Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        _BotonCircular(
          icon: Icons.add,
          onPressed: onIncrement,
          iconColor: acento,
          borderColor: acento,
        ),
      ],
    );
  }
}

class _BotonCircular extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? borderColor;

  const _BotonCircular({
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.black45),
        color: Colors.white,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Icon(icon, size: 16, color: iconColor ?? Colors.black54),
      ),
    );
  }
}
