import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class HiveService {
  static Future init() async {
    await Hive.openBox('users');
    await Hive.openBox('session');
    await Hive.openBox('cart');
    await Hive.openBox('address');
    await Hive.openBox('transaction');
    await Hive.openBox('suggestion');
    await Hive.openBox('profilePhoto');
  }

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static bool register(String username, String password) {
    final users = Hive.box('users');
    if (users.containsKey(username)) return false;

    final hashed = hashPassword(password);
    users.put(username, hashed);

    Hive.box('session').put('user', username);
    Hive.box('cart').put(username, []);
    Hive.box('address').put(username, []);
    Hive.box('transaction').put(username, []);
    Hive.box('suggestion').put(username, []);

    return true;
  }

  static bool login(String username, String password) {
    final users = Hive.box('users');
    if (!users.containsKey(username)) return false;

    final stored = users.get(username);
    if (stored == hashPassword(password)) {
      Hive.box('session').put('user', username);
      return true;
    }
    return false;
  }

  static String? getSession() {
    return Hive.box('session').get('user');
  }

  static void logout() {
    Hive.box('session').delete('user');
  }
}
