import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

@JS('eval')
external void _evalJS(String code);

/// Triggers a file download in the browser via a Blob + temporary <a> tag,
/// built and clicked entirely inside injected JS (matches the pattern
/// already used by splash_screen_web.dart for JS interop in this project).
void _triggerDownload(String content, String fileName, String mimeType) {
  // Build the blob URL via a <a> element injected into the DOM
  final script = '''
(function() {
  var blob = new Blob([${jsonEncode(content)}], {type: '${mimeType};charset=utf-8;'});
  var url = URL.createObjectURL(blob);
  var a = document.createElement('a');
  a.href = url;
  a.download = '${fileName.replaceAll("'", "\\'")}';
  document.body.appendChild(a);
  a.click();
  setTimeout(function() {
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, 100);
})();
''';
  _evalJS(script);
}

/// Downloads data as a CSV file.
void downloadCsv(List<List<String>> rows, String fileName) {
  final sb = StringBuffer();
  for (final row in rows) {
    sb.writeln(row.map((cell) {
      final escaped = cell.replaceAll('"', '""');
      return '"$escaped"';
    }).join(','));
  }
  _triggerDownload(sb.toString(), fileName, 'text/csv');
}

/// Downloads an HTML table as a file that opens in Excel (xls-compatible HTML).
/// This approach works without any native packages on Flutter Web.
void downloadExcel(
  List<String> headers,
  List<List<String>> rows,
  String fileName,
  String sheetTitle,
) {
  final sb = StringBuffer();
  sb.write('''<html xmlns:o="urn:schemas-microsoft-com:office:office" 
xmlns:x="urn:schemas-microsoft-com:office:excel" 
xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>
<x:ExcelWorksheet><x:Name>$sheetTitle</x:Name>
<x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
</x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->
<style>
  body { font-family: Calibri, sans-serif; font-size: 11pt; }
  table { border-collapse: collapse; width: 100%; }
  th { background-color: #1E40AF; color: white; font-weight: bold; 
       padding: 8px 10px; border: 1px solid #ccc; text-align: left; }
  td { padding: 6px 10px; border: 1px solid #e0e0e0; }
  tr:nth-child(even) td { background-color: #f8fafc; }
  h2 { color: #1E40AF; margin-bottom: 4px; }
  p.subtitle { color: #64748b; margin: 0 0 16px; font-size: 10pt; }
</style>
</head><body>
<h2>MAI Coaching Academy</h2>
<p class="subtitle">$sheetTitle — Generated ${_formatNow()}</p>
<table>
<thead><tr>''');

  for (final h in headers) {
    sb.write('<th>$h</th>');
  }
  sb.write('</tr></thead><tbody>');

  for (final row in rows) {
    sb.write('<tr>');
    for (final cell in row) {
      sb.write('<td>${_escapeHtml(cell)}</td>');
    }
    sb.write('</tr>');
  }
  sb.write('</tbody></table></body></html>');

  // .xls extension with HTML content — opens natively in Excel/LibreOffice
  _triggerDownload(sb.toString(), fileName, 'application/vnd.ms-excel');
}

/// Prints an HTML receipt in a new popup window.
void printReceipt(String htmlContent) {
  final script = '''
(function() {
  var w = window.open('', '_blank', 'width=700,height=900');
  w.document.open();
  w.document.write(${jsonEncode(htmlContent)});
  w.document.close();
  w.focus();
  setTimeout(function() { w.print(); }, 500);
})();
''';
  _evalJS(script);
}

String _formatNow() {
  final n = DateTime.now();
  return '${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year}';
}

String _escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
