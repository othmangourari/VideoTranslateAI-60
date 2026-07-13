import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/project_model.dart';

/// خدمة تصدير الملفات
class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  /// تصدير إلى PDF
  Future<ExportResult> exportToPdf(ProjectModel project) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // عنوان المشروع
              pw.Header(
                level: 0,
                child: pw.Text(
                  project.name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // معلومات الفيديو
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Video: ${project.videoName}'),
                    pw.Text('Duration: ${project.durationText}'),
                    pw.Text('Size: ${project.sizeText}'),
                    pw.Text(
                        'Source Language: ${project.sourceLanguage.toUpperCase()}'),
                    pw.Text(
                        'Target Language: ${project.targetLanguage.toUpperCase()}'),
                    pw.Text(
                        'Created: ${_formatDate(project.createdAt)}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // النص الأصلي
              pw.Header(level: 1, text: 'Original Text'),
              pw.Paragraph(text: project.originalText),

              pw.SizedBox(height: 20),

              // النص المترجم
              pw.Header(level: 1, text: 'Translated Text'),
              pw.Paragraph(text: project.translatedText),
            ];
          },
        ),
      );

      final outputDir = await _getExportDirectory();
      final fileName = '${project.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(p.join(outputDir, fileName));
      await file.writeAsBytes(await pdf.save());

      return ExportResult(
        filePath: file.path,
        success: true,
        message: 'تم تصدير ملف PDF بنجاح',
      );
    } catch (e) {
      return ExportResult(
        filePath: null,
        success: false,
        message: 'فشل تصدير PDF: $e',
      );
    }
  }

  /// تصدير إلى TXT
  Future<ExportResult> exportToTxt(ProjectModel project) async {
    try {
      final content = '''${project.name}
${'=' * project.name.length}

معلومات الفيديو:
- اسم الفيديو: ${project.videoName}
- المدة: ${project.durationText}
- الحجم: ${project.sizeText}
- اللغة الأصلية: ${project.sourceLanguage}
- لغة الترجمة: ${project.targetLanguage}
- تاريخ الإنشاء: ${_formatDate(project.createdAt)}

النص الأصلي:
${'─' * 40}
${project.originalText}

النص المترجم:
${'─' * 40}
${project.translatedText}

---
تم إنشاؤه بواسطة VideoTranslate AI
''';

      final outputDir = await _getExportDirectory();
      final fileName = '${project.name}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(p.join(outputDir, fileName));
      await file.writeAsString(content, encoding: const SystemEncoding());

      return ExportResult(
        filePath: file.path,
        success: true,
        message: 'تم تصدير ملف النص بنجاح',
      );
    } catch (e) {
      return ExportResult(
        filePath: null,
        success: false,
        message: 'فشل تصدير TXT: $e',
      );
    }
  }

  /// مشاركة الملف
  Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }

  /// مشاركة النص
  Future<void> shareText(String text, String subject) async {
    await Share.share(text, subject: subject);
  }

  /// نسخ النص إلى الحافظة
  Future<void> copyToClipboard(String text) async {
    // يتم ذلك من الواجهة باستخدام Clipboard
  }

  Future<String> _getExportDirectory() async {
    Directory dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/VideoTranslateAI');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir.path;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// نتيجة التصدير
class ExportResult {
  final String? filePath;
  final bool success;
  final String message;

  const ExportResult({
    required this.filePath,
    required this.success,
    required this.message,
  });
}
