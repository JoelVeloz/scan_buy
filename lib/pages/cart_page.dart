import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<String> items;

  const CartPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de Compras"),
        backgroundColor: Colors.blueAccent,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                "El carrito está vacío",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(items[index]),
                );
              },
            ),
    );
  }
}
