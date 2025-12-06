import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/pdf_service.dart';
import 'home_page.dart';

class InvoicePage extends StatelessWidget {
  final Map transaction;
  const InvoicePage({super.key, required this.transaction});

  String buildQrPayload() {
    return '''
GLOBEMART-INVOICE
ID: ${transaction['trxId']}
DATE: ${transaction['date']}
TOTAL: ${transaction['displayTotal'] ?? transaction['total']}
PAYMENT: ${transaction['method']}
ADDRESS: ${transaction['address']}
''';
  }

  String formatCurrency() {
    final currency = transaction['currency'] ?? "USD";
    final rawUsd =
        (transaction['totalUSD'] ?? transaction['total'] ?? 0).toDouble();
    final display = (transaction['displayTotal'] ?? rawUsd).toDouble();

    switch (currency) {
      case "IDR":
        return "Rp ${display.toStringAsFixed(0)}";
      case "JPY":
        return "¥ ${display.toStringAsFixed(0)}";
      case "EUR":
        return "€ ${display.toStringAsFixed(2)}";
      case "GBP":
        return "£ ${display.toStringAsFixed(2)}";
      default:
        return "\$${rawUsd.toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = transaction['items'] ?? [];
    final totalFormatted = formatCurrency();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F111A) : Colors.grey[100];
    final card = isDark ? const Color(0xFF1C1F2A) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final line = isDark ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Invoice"),
        backgroundColor: isDark ? const Color(0xFF121421) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ===== SUCCESS HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 42),
                SizedBox(height: 6),
                Text(
                  "PEMBAYARAN BERHASIL",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ===== DETAIL CARD =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info("ID", transaction['trxId'], text),
                info("Tanggal", transaction['date'], text),
                info("Alamat", transaction['address'], text),
                info("Metode", transaction['method'], text),

                Divider(color: line),

                Text("Daftar Barang:",
                    style: TextStyle(color: text, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                ...items.map((i) {
                  final title = i['title'] ?? '';
                  final qty = i['qty'] ?? 0;
                  final price = (i['price'] ?? 0).toDouble();
                  final subTotal = price * qty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$title x$qty",
                            style: TextStyle(color: text),
                          ),
                        ),
                        Text(
                          "\$${subTotal.toStringAsFixed(2)}",
                          style: TextStyle(color: text),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                Divider(color: line),

                info("TOTAL", totalFormatted, text, bold: true),

                const SizedBox(height: 12),

                // ===== QR CODE (ONLY FOR APP, NOT PDF) =====
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: buildQrPayload(),
                      version: QrVersions.auto,
                      size: 140,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ===== BUTTON =====
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Share PDF"),
                  onPressed: () async {
                    final bytes = await PdfService.buildInvoice(transaction);
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: "invoice_${transaction['trxId']}.pdf",
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: const Text("Kembali ke Home"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget info(String title, String data, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: color)),
          ),
          Text(
            data,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
