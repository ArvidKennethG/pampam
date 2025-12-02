import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> buildInvoice(Map trx) async {
    final pdf = pw.Document();
    final List items = trx['items'] ?? [];

    // Hitung total dari item (USD)
    double totalUsd = 0;
    for (var i in items) {
      totalUsd += (i['price'] * i['qty']);
    }

    // ==== FORMAT TOTAL SESUAI CURRENCY ====
    String formatTotal() {
      final String currency = trx['currency'] ?? "USD";
      final double displayTotal =
          (trx['displayTotal'] ?? totalUsd).toDouble();
      final double rawUsd = (trx['totalUSD'] ?? totalUsd).toDouble();

      switch (currency) {
        case "IDR":
          return "Rp ${displayTotal.toStringAsFixed(0)}";
        case "JPY":
          return "¥ ${displayTotal.toStringAsFixed(0)}";
        case "EUR":
          return "€ ${displayTotal.toStringAsFixed(2)}";
        case "GBP":
          return "£ ${displayTotal.toStringAsFixed(2)}";
        default:
          return "\$${rawUsd.toStringAsFixed(2)}";
      }
    }

    final formattedTotal = formatTotal();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "GLOBEMART INVOICE",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text("Invoice ID : ${trx['trxId']}"),
                    ],
                  ),
                  pw.Text(
                    formattedTotal,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // ===== INFO DASAR =====
              pw.Text("Tanggal    : ${trx['date']}"),
              pw.Text("Metode     : ${trx['method']}"),
              pw.Text("Alamat     : ${trx['address']}"),

              pw.SizedBox(height: 8),
              pw.Divider(),

              // ===== DETAIL BARANG =====
              pw.Text(
                "DETAIL BARANG:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),

              ...items.map((i) {
                final title = i['title'] ?? '';
                final qty = i['qty'] ?? 0;
                final price = (i['price'] ?? 0).toDouble();
                final sub = price * qty;

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text("$title x$qty"),
                      ),
                      pw.Text("\$${sub.toStringAsFixed(2)}"),
                    ],
                  ),
                );
              }).toList(),

              pw.Divider(),

              // ===== TOTAL =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    formattedTotal,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.Text(
                "Terima kasih telah berbelanja di GlobeMart.",
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
