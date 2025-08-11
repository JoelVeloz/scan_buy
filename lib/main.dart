import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/cart_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Escáner & Carrito",
      theme: ThemeData(primarySwatch: Colors.blue),
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
  String? lastCode; // último código escaneado
  final List<String> cartItems = [];

  void _onCodeScanned(String code) {
    setState(() {
      lastCode = code;
      if (!cartItems.contains(code)) {
        cartItems.add(code);
      }
      _selectedIndex = 0; // volver a Home después de escanear
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(lastCode: lastCode),
      ScanPage(onCodeScanned: _onCodeScanned),
      CartPage(items: cartItems),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
