import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'services/api_service.dart';

class TotalExpensePage extends StatefulWidget {
  const TotalExpensePage({super.key});

  @override
  State<TotalExpensePage> createState() => _TotalExpensePageState();
}

class _TotalExpensePageState extends State<TotalExpensePage> {
  final ApiService apiService = ApiService();

  String selectedYear = '2026';
  String selectedCrop = 'ઘઉં';
  String? selectedFarmId;

  final List<String> years = ['2026', '2025', '2024'];
  final List<String> crops = ['ઘઉં', 'કપાસ', 'મગફળી', 'બાજરી'];

  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> farms = [];

  int currentPage = 0;
  final int pageSize = 20;

  bool isLoading = false;
  bool isExporting = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFarms();
    fetchExpenses();
  }

  // Load the farm list from the existing API.
  Future<void> fetchFarms() async {
    try {
      final result = await ApiService.getFarms();

      if (!mounted) return;

      setState(() {
        farms = result
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading farms: $e');
    }
  }

  // Filter the search results to the selected farm.
  List<Map<String, dynamic>> get selectedFarmExpenses {
    if (selectedFarmId == null) {
      return [];
    }

    return expenses.where((expense) {
      return expense['farmId']?.toString() == selectedFarmId;
    }).toList();
  }

  // Display only 20 rows per page for the selected farm.
  List<Map<String, dynamic>> get currentPageFarmExpenses {
    final filtered = selectedFarmExpenses;
    final start = currentPage * pageSize;

    if (start >= filtered.length) {
      return [];
    }

    return filtered.skip(start).take(pageSize).toList();
  }

  int get totalPages {
    final count = selectedFarmExpenses.length;

    if (count == 0) {
      return 0;
    }

    return (count + pageSize - 1) ~/ pageSize;
  }

  String get selectedFarmName {
    for (final farm in farms) {
      if (farm['id']?.toString() == selectedFarmId) {
        return farm['name']?.toString() ?? 'ખેતર';
      }
    }

    return 'ખેતર';
  }

  // IMPORTANT:
  // Use the existing working search endpoint.
  // Do not call GET /api/farm_expense here.
  Future<void> fetchExpenses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final firstResult = await apiService.searchFarmExpenses(
        cropName: selectedCrop,
        year: int.parse(selectedYear),
        page: 0,
        size: pageSize,
      );

      final allExpenses = <Map<String, dynamic>>[];

      final firstContent =
          (firstResult['content'] as List<dynamic>?) ?? [];

      allExpenses.addAll(
        firstContent.map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

      final serverTotalPages =
          (firstResult['totalPages'] as num?)?.toInt() ?? 1;

      // Load the remaining pages from the server.
      for (var page = 1; page < serverTotalPages; page++) {
        final result = await apiService.searchFarmExpenses(
          cropName: selectedCrop,
          year: int.parse(selectedYear),
          page: page,
          size: pageSize,
        );

        final content =
            (result['content'] as List<dynamic>?) ?? [];

        allExpenses.addAll(
          content.map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        expenses = allExpenses;
        currentPage = 0;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        expenses = [];
        errorMessage = 'ખર્ચ લાવવામાં સમસ્યા આવી.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double get currentPageTotal {
    return currentPageFarmExpenses.fold<double>(
      0,
      (total, expense) {
        return total + numberValue(expense['totalCost']);
      },
    );
  }

  double get allSelectedFarmTotal {
    return selectedFarmExpenses.fold<double>(
      0,
      (total, expense) {
        return total + numberValue(expense['totalCost']);
      },
    );
  }

  double numberValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String money(dynamic value) {
    return '₹${numberValue(value).toStringAsFixed(2)}';
  }

  String displayDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String displayText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '-';
    }

    return value.toString();
  }

  void changeYear(String? value) {
    if (value == null || value == selectedYear) {
      return;
    }

    setState(() {
      selectedYear = value;
      currentPage = 0;
    });

    fetchExpenses();
  }

  void changeCrop(String? value) {
    if (value == null || value == selectedCrop) {
      return;
    }

    setState(() {
      selectedCrop = value;
      currentPage = 0;
    });

    fetchExpenses();
  }

  void changeFarm(String? value) {
    if (value == selectedFarmId) {
      return;
    }

    setState(() {
      selectedFarmId = value;
      currentPage = 0;
    });
  }

  void changePage(int page) {
    if (page < 0 || page >= totalPages || isLoading) {
      return;
    }

    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કુલ ખર્ચ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // Year, crop and farm filters.
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ખર્ચ જુઓ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Year and crop selection.
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedYear,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'વર્ષ',
                    border: OutlineInputBorder(),
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: changeYear,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCrop,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'પાક',
                    border: OutlineInputBorder(),
                  ),
                  items: crops.map((crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Text(crop),
                    );
                  }).toList(),
                  onChanged: changeCrop,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Farm selection.
          DropdownButtonFormField<String>(
            initialValue: selectedFarmId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ખેતર પસંદ કરો',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.agriculture),
            ),
            hint: const Text('ખર્ચ જોવા માટે ખેતર પસંદ કરો'),
            items: farms.map((farm) {
              final id = farm['id']?.toString();
              final name = farm['name']?.toString() ?? 'ખેતર';

              return DropdownMenuItem<String>(
                value: id,
                child: Text('$name (ID: $id)'),
              );
            }).where((item) => item.value != null).toList(),
            onChanged: changeFarm,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 45,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: fetchExpenses,
                icon: const Icon(Icons.refresh),
                label: const Text('ફરી પ્રયત્ન કરો'),
              ),
            ],
          ),
        ),
      );
    }

    if (farms.isEmpty) {
      return const Center(
        child: Text('ખેતરની યાદી મળી નથી.'),
      );
    }

    if (selectedFarmId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'ખર્ચ જોવા માટે પહેલાં ખેતર પસંદ કરો.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (selectedFarmExpenses.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSummary(),
        Expanded(
          child: _buildExpenseTable(),
        ),
        _buildPagination(),
        _buildPdfButton(),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ખેતર: $selectedFarmName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'વર્ષ: $selectedYear  •  પાક: $selectedCrop',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text('કુલ રેકોર્ડ: ${selectedFarmExpenses.length}'),
          const SizedBox(height: 4),
          Text(
            'ખેતરનો કુલ ખર્ચ: ${money(allSelectedFarmTotal)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'આ પાનાંનો કુલ ખર્ચ: ${money(currentPageTotal)}',
          ),
        ],
      ),
    );
  }

  // Tabular display of expenses for the selected farm.
  Widget _buildExpenseTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          border: TableBorder.all(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          columns: const [
            DataColumn(label: Text('તારીખ')),
            DataColumn(label: Text('ખેતર ID')),
            DataColumn(label: Text('ખર્ચનું નામ')),
            DataColumn(label: Text('પ્રકાર')),
            DataColumn(
              label: Text('રકમ'),
              numeric: true,
            ),
          ],
          rows: currentPageFarmExpenses.map((expense) {
            return DataRow(
              cells: [
                DataCell(
                  Text(displayDate(expense['expenseDate'])),
                ),
                DataCell(
                  Text(displayText(expense['farmId'])),
                ),
                DataCell(
                  Text(displayText(expense['expenseName'])),
                ),
                DataCell(
                  Text(displayText(expense['expenseType'])),
                ),
                DataCell(
                  Text(
                    money(expense['totalCost']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (totalPages <= 1) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('પાનું 1 / 1'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'પહેલાનું પાનું',
            onPressed: currentPage > 0
                ? () => changePage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('પાનું ${currentPage + 1} / $totalPages'),
          IconButton(
            tooltip: 'આગળનું પાનું',
            onPressed: currentPage + 1 < totalPages
                ? () => changePage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed:
              isExporting ? null : generatePdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(
            isExporting
                ? 'PDF તૈયાર થઈ રહ્યું છે...'
                : 'PDF બનાવો',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'ખર્ચ મળ્યો નથી.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$selectedFarmName માટે '
              '$selectedYear • $selectedCrop માં કોઈ રેકોર્ડ નથી.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: fetchExpenses,
              icon: const Icon(Icons.refresh),
              label: const Text('ફરી લોડ કરો'),
            ),
          ],
        ),
      ),
    );
  }

  // Export the selected farm's filtered expenses to PDF.
  Future<void> generatePdf() async {
    if (selectedFarmExpenses.isEmpty) {
      return;
    }

    setState(() {
      isExporting = true;
    });

    try {
      final pdf = pw.Document();

      // Export every selected-farm record, not only the visible page.
      final rows = selectedFarmExpenses.map((expense) {
        return [
          displayDate(expense['expenseDate']),
          displayText(expense['farmId']),
          displayText(expense['expenseName']),
          displayText(expense['expenseType']),
          money(expense['totalCost']),
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return [
              pw.Text(
                'Farm Expense Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Farm: $selectedFarmName'),
              pw.Text('Year: $selectedYear'),
              pw.Text('Crop: $selectedCrop'),
              pw.Text('Total records: ${selectedFarmExpenses.length}'),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Date',
                  'Farm ID',
                  'Expense Name',
                  'Type',
                  'Amount',
                ],
                data: rows,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 9,
                ),
                border: pw.TableBorder.all(
                  color: PdfColors.grey,
                  width: 0.5,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total expense: ${money(allSelectedFarmTotal)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF બનાવવામાં ભૂલ: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }
}