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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
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
      name: 'Expense_Report.pdf',
    );
  }

  // Helper method to construct the document header
  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Personal Expense Tracker', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('Monthly Financial Report', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
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
        pw.Text('INR ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  // Helper method to generate the data table
  static pw.Widget _buildExpenseTable(List<Map<String, dynamic>> expenses) {
    // Defining table headers
    final headers = ['Transaction Title', 'Category', 'Amount (INR)'];

    // Mapping raw data to table rows
    final data = expenses.map((expense) {
      final title = expense['title'].toString();
      final category = expense['category'].toString();
      final amount = expense['amount'].toString();
      return [title, category, amount];
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
        2: pw.Alignment.centerRight,
      },
    );
  }
}