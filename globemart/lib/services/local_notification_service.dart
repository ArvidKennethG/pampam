import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(iOS: ios);
    await _plugin.initialize(settings);
  }

  // ================================
  // NOTIF SAAT CART BELUM CHECKOUT
  // ================================
  static Future notifyPendingCart() async {
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const detail = NotificationDetails(iOS: ios);

    await _plugin.show(
      100,
      "Keranjang Masih Ada Barang",
      "Segera selesaikan pembayaran sebelum kehabisan!",
      detail,
    );
  }

  // ================================
  // NOTIF BERHASIL BAYAR
  // ================================
  static Future notifySuccess() async {
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const detail = NotificationDetails(iOS: ios);

    await _plugin.show(
      200,
      "Pembayaran Berhasil",
      "Terima kasih telah berbelanja di GlobeMart!",
      detail,
    );
  }
}
