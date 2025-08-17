import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_item.dart';

class CartStorage {
  static const _key = 'cart_items';

  // Guardar carrito completo
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // Leer carrito completo
  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CartItem.fromJson(e)).toList();
  }

  // Agregar un item (si existe, incrementa la cantidad)
  static Future<void> addItem(CartItem newItem) async {
    final items = await loadCart();
    final existingIndex = items.indexWhere((i) => i.id == newItem.id);
    if (existingIndex != -1) {
      items[existingIndex].quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }
    await saveCart(items);
  }

  // Incrementar cantidad de un item por su id
  static Future<void> incrementItem(String id) async {
    final items = await loadCart();
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      items[index].quantity++;
      await saveCart(items);
    }
  }

  // Decrementar cantidad de un item por su id
  static Future<void> decrementItem(String id) async {
    final items = await loadCart();
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        // Si la cantidad es 1 y se decremente, se elimina el item
        items.removeAt(index);
      }
      await saveCart(items);
    }
  }

  // Eliminar un item
  static Future<void> removeItem(String id) async {
    final items = await loadCart();
    items.removeWhere((i) => i.id == id);
    await saveCart(items);
  }

  // Vaciar carrito
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
