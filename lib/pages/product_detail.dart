import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:scan_buy/pages/cart_page.dart';
import 'package:scan_buy/models/cart_item.dart';

final pb = PocketBase('https://scan-buy-local.recargaloya.com');

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cantidad = 1;

  RecordModel? _producto;
  bool _isLoading = true;
  String? _error;

  // Lista local para simular el carrito de productos agregados

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await pb.collection('products').getOne(widget.productId);
      setState(() {
        _producto = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando producto: $e';
        _isLoading = false;
      });
    }
  }

  void _agregarAlCarrito() {
    final nombre = _producto?.getStringValue('name') ?? '';
    final precioDouble = _producto?.getDoubleValue('price') ?? 0.0;
    final imgFile = _producto?.getStringValue('image');
    final imgUrl = (imgFile != null && imgFile.isNotEmpty)
        ? 'https://scan-buy-local.recargaloya.com/api/files/products/${_producto!.id}/$imgFile'
        : 'https://via.placeholder.com/180';

    final nuevoItem = CartItem(
      name: nombre,
      unitPrice: precioDouble,
      quantity: _cantidad,
      imageUrl: imgUrl,
    );

    setState(() {
      // Si ya existe el producto en el carrito, suma cantidad
      final index = carrito.indexWhere((item) => item.name == nuevoItem.name);
      if (index >= 0) {
        carrito[index].quantity += _cantidad;
      } else {
        carrito.add(nuevoItem);
      }
      _cantidad = 1; // reset cantidad al agregar
    });

    // Navega a la pantalla carrito con la lista de items
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartScreen(items: carrito)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _producto?.getStringValue('name') ?? '';
    final descripcion = _producto?.getStringValue('description') ?? '';
    final precioDouble = _producto?.getDoubleValue('price') ?? 0.0;
    final precio = '\$${precioDouble.toStringAsFixed(2)}';
    final imgFile = _producto?.getStringValue('image');
    final imgUrl = (imgFile != null && imgFile.isNotEmpty)
        ? 'https://scan-buy-local.recargaloya.com/api/files/products/${_producto!.id}/$imgFile'
        : 'https://via.placeholder.com/180';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : CustomScrollView(
                slivers: [
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
                          const Text(
                            'Detalles del producto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              imgUrl,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            descripcion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                precio,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _QuantitySelector(
                                cantidad: _cantidad,
                                onIncrement: () {
                                  setState(() {
                                    _cantidad++;
                                  });
                                },
                                onDecrement: () {
                                  setState(() {
                                    if (_cantidad > 1) _cantidad--;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.red,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Disponible en otros locales:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const _StockItem(
                            tienda: 'SUP - MIRAFLORES',
                            stock: '3 en stock',
                          ),
                          const _StockItem(
                            tienda: 'SUP - MIRAFLORES',
                            stock: '3 en stock',
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4B048),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _agregarAlCarrito,
                              child: const Text(
                                'Agregar al carrito',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
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
}

class _QuantitySelector extends StatelessWidget {
  final int cantidad;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.cantidad,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF4B048)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, size: 18),
            onPressed: onDecrement,
          ),
          Text(
            '$cantidad',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 18, color: Color(0xFFF4B048)),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StockItem extends StatelessWidget {
  final String tienda;
  final String stock;

  const _StockItem({required this.tienda, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 4),
      child: Row(
        children: [
          Text(tienda, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            stock,
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
