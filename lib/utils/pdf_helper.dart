import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportGenerator {
  // Static function to generate and display the PDF preview
  static Future<void> generateAndPrintReport(
      List<Map<String, dynamic>> expenses,
      double totalIncome,
      double totalExpense) async {

    final pdf = pw.Document();
    final double netBalance = totalIncome - totalExpense;

    // Fetch the current date and time for the document header and filename
    final now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String formattedTime = "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
    final String dynamicFileName = 'Expense_Report_${formattedDate}_$formattedTime.pdf';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(formattedDate, formattedTime),
            pw.SizedBox(height: 20),
            _buildFinancialSummary(totalIncome, totalExpense, netBalance),
            pw.SizedBox(height: 30),
            _buildExpenseTable(expenses),
          ];
        },
      ),
    );

    // This triggers the native printing/sharing dialog on the device
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: dynamicFileName,
    );
  }

  // Helper method to construct the document header
  static pw.Widget _buildHeader(String date, String time) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Personal Expense Tracker', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Financial Report', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
              // Displaying the generation timestamp inside the PDF header
              pw.Text('Generated: $date at ${time.replaceAll('-', ':')}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ]
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2),
      ],
    );
  }

  // Helper method to display aggregate financial data
  static pw.Widget _buildFinancialSummary(double income, double expense, double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _summaryColumn('Total Income', income, PdfColors.green700),
          _summaryColumn('Total Expense', expense, PdfColors.red700),
          _summaryColumn('Net Balance', balance, PdfColors.blue700),
        ],
      ),
    );
  }

  static pw.Widget _summaryColumn(String title, double amount, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text('INR ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  // Helper method to generate the data table with date and time
  static pw.Widget _buildExpenseTable(List<Map<String, dynamic>> expenses) {
    // Defining table headers with the new Date & Time column
    final headers = ['Transaction Title', 'Category', 'Date & Time', 'Amount (INR)'];

    // Mapping raw data to table rows
    final data = expenses.map((expense) {
      final title = expense['title']?.toString() ?? 'Unknown';
      final category = expense['category']?.toString() ?? 'Unknown';
      final amount = expense['amount']?.toString() ?? '0';

      String dateTimeStr = 'Unknown';

      // Safely extracting the date and time from the new explicitly saved fields
      if (expense.containsKey('displayDate') && expense.containsKey('displayTime')) {
        dateTimeStr = '${expense['displayDate']} ${expense['displayTime']}';
      }
      // Fallback logic for older transactions that only have the long ISO string
      else if (expense.containsKey('date')) {
        final rawDate = expense['date'].toString();
        if (rawDate.length >= 16) {
          dateTimeStr = rawDate.substring(0, 16).replaceFirst('T', ' ');
        } else {
          dateTimeStr = rawDate;
        }
      }

      return [title, category, dateTimeStr, amount];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center, // Center alignment for the Date & Time column
        3: pw.Alignment.centerRight,
      },
    );
  }
}