import 'dart:typed_data';

import 'package:excel/excel.dart';

/// The first sheet of an Excel file as rows of text: dates as yyyy-mm-dd, numbers as written.
List<List<String>> xlsxRows(Uint8List bytes) {
  final book = Excel.decodeBytes(bytes);
  if (book.tables.isEmpty) return const [];
  final sheet = book.tables.values.first;
  String two(int v) => v.toString().padLeft(2, '0');
  String text(Data? d) {
    final v = d?.value;
    if (v == null) return '';
    if (v is DateCellValue) return '${v.year}-${two(v.month)}-${two(v.day)}';
    if (v is DateTimeCellValue) {
      return '${v.year}-${two(v.month)}-${two(v.day)}T${two(v.hour)}:${two(v.minute)}:${two(v.second)}';
    }
    return v.toString();
  }

  return [for (final row in sheet.rows) row.map(text).toList()];
}
