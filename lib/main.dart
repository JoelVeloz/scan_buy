import 'package:flutter/material.dart';
import 'package:scan_buy/pages/product_detail.dart';
import 'package:scan_buy/pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/scan_page.dart';
import 'package:scan_buy/models/cart_item.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Scan & Buy",
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Aquí defines tu carrito como lista de CartItem
  List<CartItem> carrito = [];

  void _onCodeScanned(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: code),
      ),
    );
  }

  // Para que desde ProductDetailScreen puedas agregar items al carrito,
  // tendrías que usar callbacks o estado global. Por simplicidad,
  // aquí solo mostramos el carrito.

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(),
      ScanPage(onCodeScanned: _onCodeScanned),
      CartScreen(items: carrito), // <-- Pasas la lista carrito
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFF0D6),
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Escanear",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Carrito",
          ),
        ],
      ),
    );
  }
}
