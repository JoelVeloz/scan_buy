class CartItem {
  final String id; // Un identificador único para el item
  final String name;
  final double unitPrice;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'id': id, // Asegúrate de asignar un id único al crear el item
    'name': name,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] ?? "", // Asegúrate de que el id esté presente en el JSON
    name: json['name'],
    unitPrice: json['unitPrice'],
    quantity: json['quantity'],
    imageUrl: json['imageUrl'],
  );
}

List<CartItem> carrito = [];
