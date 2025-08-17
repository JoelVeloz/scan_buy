import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  final Function(String) onCodeScanned;

  const ScanPage({super.key, required this.onCodeScanned});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final String? value = capture.barcodes.first.rawValue;
    if (value != null) {
      setState(() => _isScanning = false);
      widget.onCodeScanned(value);
    }
  }

  void _refreshScanner() {
    setState(() {
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (!_isScanning)
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                onPressed: _refreshScanner,
                child: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
    );
  }
}
