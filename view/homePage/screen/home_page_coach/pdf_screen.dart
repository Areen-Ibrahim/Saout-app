import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

Future<void> generatePlayerPDF(Map<String, dynamic> player) async {
  final pdf = pw.Document();

  // تحميل الخط من الـ assets
  final fontData = await rootBundle.load("fonts/PlayfairDisplay-Regular.ttf");
  final font = pw.Font.ttf(fontData.buffer.asByteData());

  // تحميل صورة اللاعب
  // final imageData = await rootBundle.load(player['image'] ?? '');
  // final image = pw.MemoryImage(imageData.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        padding: pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // عرض صورة اللاعب
            // pw.Center(
            //   child: pw.Image(image, width: 100, height: 100),
            // ),
            pw.SizedBox(height: 16),

            // اسم اللاعب الكامل
            pw.Center(
              child: pw.Text("${player['firstName']} ${player['lastName']}", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
            ),
            pw.SizedBox(height: 16),

            // معلومات اللاعب الشخصية
            pw.Text("Player Information", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
            pw.SizedBox(height: 8),
            pw.Text("Number: ${player['playerNumber']}", style: pw.TextStyle(fontSize: 14, font: font)),
            pw.Text("Height: ${player['height']} cm", style: pw.TextStyle(fontSize: 14, font: font)),
            pw.Text("Weight: ${player['weight']} kg", style: pw.TextStyle(fontSize: 14, font: font)),
            pw.Text("Position: ${player['position']}", style: pw.TextStyle(fontSize: 14, font: font)),
            pw.Text("Age: ${player['age']}", style: pw.TextStyle(fontSize: 14, font: font)),

            pw.SizedBox(height: 16),

            // عرض بيانات حارس المرمى أو لاعب ميداني حسب المركز
            if (player['position'] == 'Goalkeeper') ...[
              pw.Text("Goalkeeper Stats", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text("Clean Sheets: ${player['cleanSheets']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Saves: ${player['saves']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Penalties Saved: ${player['penaltiesSaved']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Own Goals: ${player['ownGoals']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Goals Conceded: ${player['goalsConceded']}", style: pw.TextStyle(fontSize: 14, font: font)),
            ] else ...[
              pw.Text("Field Player Stats", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text("Goals: ${player['goals']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Assists: ${player['assists']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Shots on Target: ${player['shotsOnTarget']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Tackles: ${player['tackles']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Interceptions: ${player['interceptions']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Pass Accuracy: ${player['passAccuracy']}%", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Dribbles Completed: ${player['dribblesCompleted']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Yellow Cards: ${player['yellowCards']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Red Cards: ${player['redCards']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Foul Goals: ${player['foulGoals']}", style: pw.TextStyle(fontSize: 14, font: font)),
              pw.Text("Penalty Goals: ${player['penaltyGoals']}", style: pw.TextStyle(fontSize: 14, font: font)),
            ],

            pw.SizedBox(height: 16),

            // عرض الإنجازات إن وجدت
            if (player['achievements'] != null && player['achievements'].isNotEmpty) ...[
              pw.Text("Achievements", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
              ...player['achievements'].map((achievement) => pw.Text(
                "${achievement['title']} - ${achievement['type']} (${achievement['date']})",
                style: pw.TextStyle(fontSize: 14, font: font),
              )),
            ],
          ],
        ),
      ),
    ),
  );

  // تحديد مسار الحفظ
  final directory = await getTemporaryDirectory();
  final file = File("${directory.path}/${player['firstName']}_${player['lastName']}_CV.pdf");

  await file.writeAsBytes(await pdf.save());
  print("PDF Saved: ${file.path}");

  // فتح الملف باستخدام OpenFile
  OpenFile.open(file.path);
}
