// library;

// import 'package:block_editor/block_editor.dart';
// import 'package:pdf/widgets.dart' as pw;

// /// The contract the PDF exporter implements.
// ///
// /// Separated from [BlockDocumentExporter] because PDF export produces a
// /// binary `pw.Document` object from the `pdf` package rather than a [String].
// /// The consumer is responsible for saving or sharing the returned document —
// /// this exporter never writes to disk or opens a file picker.
// ///
// /// ## Implementing a custom PDF exporter
// ///
// /// ```dart
// /// class MyPdfExporter implements BlockDocumentPdfExporter {
// ///   @override
// ///   String get formatName => 'pdf';
// ///
// ///   @override
// ///   Future<pw.Document> export(BlockDocument document) async {
// ///     final pdf = pw.Document();
// ///     // Add pages and content.
// ///     return pdf;
// ///   }
// /// }
// /// ```
// ///
// /// Call the exporter via BlockController.exportAsPdf rather than calling
// /// [export] directly.
// abstract class BlockDocumentPdfExporter {
//   /// A short human-readable identifier for this export format.
//   ///
//   /// Typically `'pdf'`.
//   String get formatName;

//   /// Converts [document] to a `pw.Document` from the `pdf` package.
//   ///
//   /// The returned [Future] completes with a fully assembled PDF document.
//   /// The caller is responsible for saving or sharing it — for example via
//   /// `document.save()` followed by writing the bytes to a file or uploading
//   /// them to a server.
//   Future<pw.Document> export(BlockDocument document);
// }
