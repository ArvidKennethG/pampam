import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'hive_service.dart';

class NotificationService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  static Timer? _cartTimer;

  static void show(String msg) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  static void startCartReminder() {
    stopCartReminder();
    _cartTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final user = HiveService.getSession();
      if (user == null) return;

      final List items = Hive.box('cart').get(user) ?? [];
      if (items.isNotEmpty) {
        show("Kamu masih punya ${items.length} item di cart. Yuk checkout 💳");
      }
    });
  }

  static void stopCartReminder() {
    _cartTimer?.cancel();
    _cartTimer = null;
  }
}
