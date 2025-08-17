import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:scan_buy/pages/product_detail.dart';

final pb = PocketBase('https://scan-buy-local.recargaloya.com');

class HomeScreen extends StatefulWidget {
  final Function(int) goToPage; // callback

  const HomeScreen({super.key, required this.goToPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _categorias = const [
    {
      'titulo': 'Lácteos',
      'slug': 'lacteos',
      'img':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=800',
    },
    {
      'titulo': 'Frutas',
      'slug': 'frutas',
      'img':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=800',
    },
    {
      'titulo': 'Verduras',
      'slug': 'verduras',
      'img':
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=800',
    },
  ];
  Future<void> _filterByCategory(String slug) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await pb
          .collection('products')
          .getFullList(filter: "category = '$slug'");
      setState(() {
        _productos = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al filtrar productos: $e';
        _isLoading = false;
      });
    }
  }

  List<RecordModel> _productos = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    _searchController.addListener(() {
      _searchProducts(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await pb.collection('products').getFullList();
      setState(() {
        _productos = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando productos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      _fetchProducts();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await pb
          .collection('products')
          .getFullList(filter: "name ?~ '$query'");
      setState(() {
        _productos = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error en búsqueda: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _HeaderBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Busca tu producto...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Categorías',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final c = _categorias[index];
                    return _CategoriaChip(
                      titulo: c['titulo']!,
                      img: c['img']!,
                      onSelected: () {
                        _filterByCategory(c['slug']!); // filtra usando el slug
                      },
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: _isLoading
                  ? SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _error != null
                  ? SliverFillRemaining(child: Center(child: Text(_error!)))
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final p = _productos[index];
                        final nombre = p.getStringValue('name') ?? 'Sin nombre';
                        final precioDouble = p.getDoubleValue('price') ?? 0.0;
                        final precio = '\$${precioDouble.toStringAsFixed(2)}';
                        final unidad = p.getStringValue('unit') ?? '';
                        final imgFile = p.getStringValue('image');

                        final imgUrl = (imgFile != null && imgFile.isNotEmpty)
                            ? 'https://scan-buy-local.recargaloya.com/api/files/products/${p.id}/$imgFile'
                            : 'https://via.placeholder.com/150';

                        return _ProductCard(
                          nombre: nombre,
                          precio: precio,
                          unidad: unidad,
                          img: imgUrl,
                          productId: p.id, // pasa el id aquí
                          goToPage: widget.goToPage, // callback
                        );
                      }, childCount: _productos.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4B048),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 40, // ajusta la altura que quieras
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String titulo;
  final String img;
  final VoidCallback onSelected;

  const _CategoriaChip({
    required this.titulo,
    required this.img,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: SizedBox(
        width: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 2.5,
                child: Image.network(img, fit: BoxFit.cover),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String nombre;
  final String precio;
  final String unidad;
  final String img;
  final String productId;
  final Function(int) goToPage; // callback

  const _ProductCard({
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.img,
    required this.productId,
    required this.goToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navegar a detalle con productId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailScreen(productId: productId, goToPage: goToPage),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    color: const Color(0xFFF7F7F7),
                    width: double.infinity,
                    child: Image.network(img, fit: BoxFit.cover),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          precio,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          unidad,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
