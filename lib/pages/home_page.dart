import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('https://scan-buy-local.recargaloya.com');

class HomePage extends StatefulWidget {
  final String? lastCode;

  const HomePage({super.key, this.lastCode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecordModel> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final records = await pb.collection('products').getFullList();
      setState(() {
        products = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar productos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            widget.lastCode == null
                ? const Text(
                    "Aún no has escaneado ningún código",
                    style: TextStyle(fontSize: 18),
                  )
                : Text(
                    "Último código: ${widget.lastCode}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final name =
                            product.getStringValue('name') ?? 'Sin nombre';
                        final price = product.getDoubleValue('price') ?? 0.0;

                        return ListTile(
                          title: Text(name),
                          subtitle: Text(
                            'Precio: \$${price.toStringAsFixed(2)}',
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
}
