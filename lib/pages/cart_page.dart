import 'package:flutter/material.dart';
import '../models/cart_item.dart'; // ajusta el import a tu ruta real

class CartScreen extends StatefulWidget {
  final List<CartItem> items;
  const CartScreen({super.key, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
  double get impuestos => subtotal * 0.15;
  double get total => subtotal + impuestos;

  void _incrementQuantity(int index) {
    setState(() {
      items[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header...
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                color: const Color(0xFFF4B048),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Carrito',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 26),
                  ],
                ),
              ),
            ),

            // Lista de items
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2F80ED),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
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
                        onDecrement: () => _decrementQuantity(index),
                        onIncrement: () => _incrementQuantity(index),
                      ),
                    ],
                  ),
                );
              }, childCount: items.length),
            ),

            // Totales
            SliverToBoxAdapter(
              child: Padding(
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
              ),
            ),
          ],
        ),
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
