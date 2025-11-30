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
TOTAL: ${transaction['total']}
PAYMENT: ${transaction['method']}
ADDRESS: ${transaction['address']}
''';
  }

  @override
  Widget build(BuildContext context) {
    final List items = transaction['items'] ?? [];
    final total = (transaction['total'] as num).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // SUCCESS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(children: [
              Icon(Icons.check_circle, color: Colors.white, size: 40),
              SizedBox(height: 6),
              Text("PEMBAYARAN BERHASIL",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),

          const SizedBox(height: 10),

          // DETAIL
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                info("ID", transaction['trxId']),
                info("Tanggal", transaction['date']),
                info("Alamat", transaction['address']),
                info("Metode", transaction['method']),
                const Divider(),

                const Text("Daftar Barang:",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                ...items.map((i) {
                  final qty = i['qty'];
                  final price = i['price'];
                  final sub = qty * price;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text("${i['title']} x$qty")),
                        Text("\$${sub.toString()}"),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(),

                info("TOTAL", "\$$total", bold: true),

                const SizedBox(height: 10),

                // ✅ QR CODE DI LAYAR
                Center(
                  child: QrImageView(
                    data: buildQrPayload(),
                    version: QrVersions.auto,
                    size: 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("Share PDF"),
                onPressed: () async {
                  final bytes =
                      await PdfService.buildInvoice(transaction);
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
          ]),
        ]),
      ),
    );
  }

  Widget info(String title, String data, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            data,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
