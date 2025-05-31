import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';
import 'package:road_accident_system/models/accident_model.dart';

class ReportGenerator {
  Future<void> generatePdfReport(
    List<Accident> accidents,
    Map<String, int> counts,
    String title,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat.yMd();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Header(level: 0, child: pw.Text(title)),
              pw.Header(level: 1, child: pw.Text('Summary')),
              pw.Bullet(text: 'Total Accidents: ${accidents.length}'),
              pw.Bullet(
                text:
                    'By Region: ${counts.entries.map((e) => "${e.key}: ${e.value}").join(", ")}',
              ),
              pw.Header(level: 1, child: pw.Text('Accident Details')),
              pw.Table.fromTextArray(
                headers: ['Road', 'Date', 'Type', 'Effects', 'Region'],
                data:
                    accidents
                        .map(
                          (a) => [
                            a.roadName,
                            dateFormat.format(a.date),
                            a.type,
                            a.effects,
                            a.region,
                          ],
                        )
                        .toList(),
              ),
            ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '$title.pdf');
  }

  Future<File> generateCsvReport(
    List<Accident> accidents,
    String fileName,
  ) async {
    final dateFormat = DateFormat.yMd();
    final data = [
      [
        'Road Name',
        'Date',
        'Type',
        'Effects',
        'Region',
        'District',
        'Weather',
        'Visibility',
      ],
      ...accidents.map(
        (a) => [
          a.roadName,
          dateFormat.format(a.date),
          a.type,
          a.effects,
          a.region,
          a.district,
          a.weather,
          a.visibility,
        ],
      ),
    ];
    final csv = ListToCsvConverter().convert(data);
    final file = File('${Directory.systemTemp.path}/$fileName.csv');
    return await file.writeAsString(csv);
  }
}
