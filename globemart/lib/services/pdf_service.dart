import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';

class PdfService {
  static Future<Uint8List> buildInvoice(Map trx) async {
    final pdf = pw.Document();
    final List items = trx['items'] ?? [];

    double total = 0;
    for (var i in items) {
      total += (i['price'] * i['qty']);
    }

    final qrData = '''
GLOBEMART-INVOICE
ID: ${trx['trxId']}
DATE: ${trx['date']}
TOTAL: ${trx['total']}
PAYMENT: ${trx['method']}
ADDRESS: ${trx['address']}
''';

    final barcode = Barcode.qrCode();
    final svg = barcode.toSvg(qrData, width: 180, height: 180);

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("GLOBEMART INVOICE",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SvgImage(svg: svg),
                ],
              ),

              pw.SizedBox(height: 8),

              pw.Text("Invoice ID : ${trx['trxId']}"),
              pw.Text("Tanggal    : ${trx['date']}"),
              pw.Text("Metode     : ${trx['method']}"),
              pw.Text("Alamat     : ${trx['address']}"),

              pw.Divider(),

              pw.Text("DETAIL BARANG:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              ...items.map((i) {
                final sub = i['price'] * i['qty'];
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text("${i['title']} x${i['qty']}")),
                    pw.Text("\$${sub.toString()}"),
                  ],
                );
              }).toList(),

              pw.Divider(),

              pw.Text("TOTAL: \$${total.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 12),
              pw.Text("Scan QR untuk verifikasi transaksi."),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
