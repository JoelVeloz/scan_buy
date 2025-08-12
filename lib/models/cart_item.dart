class CartItem {
  final String name;
  final double unitPrice;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => unitPrice * quantity;
}

List<CartItem> carrito = [];
