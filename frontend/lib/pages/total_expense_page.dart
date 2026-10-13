import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TotalExpensePage extends StatefulWidget {
  const TotalExpensePage({super.key});

  @override
  State<TotalExpensePage> createState() => _TotalExpensePageState();
}

class _TotalExpensePageState extends State<TotalExpensePage> {
  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedYear = '2026';
  String selectedCrop = 'ઘઉં';

  // ============================================================
  // DEMO EXPENSE DATA
  //
  // Final structure:
  //
  // Village
  //    ↓
  // Region
  //    ↓
  // Farm
  //    ↓
  // Expense
  //
  // Later this data will come from Spring Boot API.
  // ============================================================

  final List<Map<String, dynamic>> expenseData = [
    {
      'village': 'જલસણ',
      'regions': [
        {
          'region': 'નદી વાળો વિસ્તાર',
          'farms': [
            {
              'farm': 'ખેતર નંબર 1',
              'expenses': [
                {
                  'date': '12/08/2026',
                  'work': 'વાવણી',
                  'type': 'મજૂરી',
                  'details': '5 મજૂર × ₹400',
                  'amount': 2000.0,
                },
                {
                  'date': '12/08/2026',
                  'work': 'વાવણી',
                  'type': 'ચા',
                  'details': '450 ml × ₹65/L',
                  'amount': 29.25,
                },
                {
                  'date': '13/08/2026',
                  'work': 'ખાતર નાખવું',
                  'type': 'યુરિયા',
                  'details': '10 kg ઉપયોગ',
                  'amount': 66.67,
                },
                {
                  'date': '14/08/2026',
                  'work': 'દવા છંટકાવ',
                  'type': 'મજૂરી',
                  'details': '2 મજૂર × ₹400',
                  'amount': 800.0,
                },
              ],
            },
            {
              'farm': 'ખેતર નંબર 2',
              'expenses': [
                {
                  'date': '12/08/2026',
                  'work': 'વાવણી',
                  'type': 'મજૂરી',
                  'details': '4 મજૂર × ₹400',
                  'amount': 1600.0,
                },
                {
                  'date': '13/08/2026',
                  'work': 'દવા છંટકાવ',
                  'type': 'દવા',
                  'details': 'દવાનો ઉપયોગ',
                  'amount': 400.0,
                },
              ],
            },
          ],
        },
        {
          'region': 'મંદિર પાસેનો વિસ્તાર',
          'farms': [
            {
              'farm': 'ખેતર નંબર 3',
              'expenses': [
                {
                  'date': '15/08/2026',
                  'work': 'વાવણી',
                  'type': 'મજૂરી',
                  'details': '5 મજૂર × ₹400',
                  'amount': 2000.0,
                },
                {
                  'date': '15/08/2026',
                  'work': 'વાવણી',
                  'type': 'નાસ્તો',
                  'details': '5 લોકો × 1 ડિશ × ₹15',
                  'amount': 75.0,
                },
              ],
            },
          ],
        },
      ],
    },

    // ==========================================================
    // SECOND VILLAGE
    // ==========================================================
    {
      'village': 'ધર્મજ',
      'regions': [
        {
          'region': 'મુખ્ય વિસ્તાર',
          'farms': [
            {
              'farm': 'ખેતર નંબર 4',
              'expenses': [
                {
                  'date': '16/08/2026',
                  'work': 'વાવણી',
                  'type': 'મજૂરી',
                  'details': '4 મજૂર × ₹400',
                  'amount': 1600.0,
                },
                {
                  'date': '17/08/2026',
                  'work': 'ખાતર નાખવું',
                  'type': 'યુરિયા',
                  'details': '15 kg ઉપયોગ',
                  'amount': 100.0,
                },
              ],
            },
          ],
        },
        {
          'region': 'તળાવ પાસેનો વિસ્તાર',
          'farms': [
            {
              'farm': 'ખેતર નંબર 5',
              'expenses': [
                {
                  'date': '18/08/2026',
                  'work': 'દવા છંટકાવ',
                  'type': 'દવા',
                  'details': 'દવાનો ઉપયોગ',
                  'amount': 500.0,
                },
              ],
            },
          ],
        },
      ],
    },
  ];

  // ============================================================
  // GET FARM TOTAL
  // ============================================================

  double getFarmTotal(Map<String, dynamic> farm) {
    final List expenses = farm['expenses'];

    double total = 0;

    for (final expense in expenses) {
      total += expense['amount'] as double;
    }

    return total;
  }

  // ============================================================
  // GET REGION TOTAL
  // ============================================================

  double getRegionTotal(Map<String, dynamic> region) {
    final List farms = region['farms'];

    double total = 0;

    for (final farm in farms) {
      total += getFarmTotal(farm);
    }

    return total;
  }

  // ============================================================
  // GET VILLAGE TOTAL
  // ============================================================

  double getVillageTotal(Map<String, dynamic> village) {
    final List regions = village['regions'];

    double total = 0;

    for (final region in regions) {
      total += getRegionTotal(region);
    }

    return total;
  }

  // ============================================================
  // GET GRAND TOTAL
  // ============================================================

  double getGrandTotal() {
    double total = 0;

    for (final village in expenseData) {
      total += getVillageTotal(village);
    }

    return total;
  }

  // ============================================================
  // CURRENCY FORMAT
  // ============================================================

  String money(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double grandTotal = getGrandTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('કુલ ખર્ચ'), centerTitle: true),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // FILTER SECTION
            // ==================================================
            _buildFilterSection(),

            // ==================================================
            // EXPENSE LIST
            // ==================================================
            Expanded(
              child: expenseData.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
                      children: [
                        // --------------------------------------
                        // SUMMARY
                        // --------------------------------------
                        _buildSummaryCard(grandTotal),

                        const SizedBox(height: 20),

                        // --------------------------------------
                        // VILLAGE LIST
                        // --------------------------------------
                        ...List.generate(expenseData.length, (index) {
                          return _buildVillageCard(expenseData[index]);
                        }),

                        const SizedBox(height: 10),

                        // --------------------------------------
                        // GRAND TOTAL
                        // --------------------------------------
                        _buildGrandTotalCard(grandTotal),

                        const SizedBox(height: 20),

                        // --------------------------------------
                        // PDF BUTTON
                        // --------------------------------------
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: generatePdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text(
                              'PDF બનાવો',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTER SECTION
  // ============================================================

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,

        boxShadow: [
          BoxShadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.08)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'ખર્ચ જુઓ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              // =================================================
              // YEAR
              // =================================================
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedYear,

                  decoration: InputDecoration(
                    labelText: 'વર્ષ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(value: '2026', child: Text('2026')),
                    DropdownMenuItem(value: '2025', child: Text('2025')),
                    DropdownMenuItem(value: '2024', child: Text('2024')),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 10),

              // =================================================
              // CROP
              // =================================================
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCrop,

                  decoration: InputDecoration(
                    labelText: 'પાક',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(value: 'ઘઉં', child: Text('ઘઉં')),
                    DropdownMenuItem(value: 'કપાસ', child: Text('કપાસ')),
                    DropdownMenuItem(value: 'મગફળી', child: Text('મગફળી')),
                    DropdownMenuItem(value: 'બાજરી', child: Text('બાજરી')),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCrop = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: Colors.green.withValues(alpha: 0.08),

        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(Icons.account_balance_wallet_outlined, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'કુલ ખર્ચ - $selectedYear',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 3),

                Text(
                  selectedCrop,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  money(total),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VILLAGE CARD
  // ============================================================

  Widget _buildVillageCard(Map<String, dynamic> village) {
    final String villageName = village['village'];

    final List regions = village['regions'];

    final double villageTotal = getVillageTotal(village);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),

        leading: Container(
          padding: const EdgeInsets.all(9),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),

            color: Colors.green.withValues(alpha: 0.1),
          ),

          child: const Icon(Icons.location_city_outlined),
        ),

        title: Text(
          villageName,

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        subtitle: Text('${regions.length} વિસ્તાર'),

        trailing: Text(
          money(villageTotal),

          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),

        children: [
          // ====================================================
          // REGIONS
          // ====================================================
          ...List.generate(regions.length, (index) {
            return _buildRegionCard(regions[index]);
          }),

          // ====================================================
          // VILLAGE TOTAL
          // ====================================================
          Container(
            margin: const EdgeInsets.only(top: 8),

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'ગામનો કુલ ખર્ચ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  money(villageTotal),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REGION CARD
  // ============================================================

  Widget _buildRegionCard(Map<String, dynamic> region) {
    final String regionName = region['region'];

    final double regionTotal = getRegionTotal(region);

    final List farms = region['farms'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      elevation: 0,

      color: Colors.grey.withValues(alpha: 0.06),

      child: ExpansionTile(
        leading: const Icon(Icons.map_outlined),

        title: Text(
          regionName,

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        subtitle: Text('${farms.length} ખેતર'),

        trailing: Text(
          money(regionTotal),

          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),

        children: [
          // ====================================================
          // FARMS
          // ====================================================
          ...List.generate(farms.length, (index) {
            return _buildFarmCard(farms[index]);
          }),

          // ====================================================
          // REGION TOTAL
          // ====================================================
          Container(
            margin: const EdgeInsets.fromLTRB(12, 5, 12, 12),

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'વિસ્તારનો કુલ ખર્ચ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  money(regionTotal),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM CARD
  // ============================================================

  Widget _buildFarmCard(Map<String, dynamic> farm) {
    final String farmName = farm['farm'];

    final double farmTotal = getFarmTotal(farm);

    final List expenses = farm['expenses'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      elevation: 0,

      color: Colors.grey.withValues(alpha: 0.04),

      child: ExpansionTile(
        title: Text(
          farmName,

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text('${expenses.length} ખર્ચ'),

        leading: const Icon(Icons.agriculture_outlined),

        trailing: Text(
          money(farmTotal),

          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),

        children: [
          // ==================================================
          // EXPENSE ITEMS
          // ==================================================
          ...List.generate(expenses.length, (index) {
            return _buildExpenseItem(expenses[index]);
          }),

          // ==================================================
          // FARM TOTAL
          // ==================================================
          Container(
            margin: const EdgeInsets.all(12),

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),

              color: Colors.white,
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'ખેતરનો કુલ ખર્ચ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  money(farmTotal),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPENSE ITEM
  // ============================================================

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final double amount = expense['amount'];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(Icons.receipt_long_outlined, size: 22),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  expense['type'],

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 3),

                Text(
                  expense['work'],

                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 3),

                Text(expense['details'], style: const TextStyle(fontSize: 13)),

                const SizedBox(height: 3),

                Text(
                  expense['date'],

                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            money(amount),

            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAND TOTAL CARD
  // ============================================================

  Widget _buildGrandTotalCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: Colors.green.withValues(alpha: 0.1),

        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),

      child: Column(
        children: [
          const Text(
            'બધા ગામોનો કુલ ખર્ચ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            '$selectedYear • $selectedCrop',

            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 8),

          Text(
            money(total),

            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 15),

          const Text(
            'હજુ કોઈ ખર્ચ મળ્યો નથી.',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 5),

          const Text(
            'પાક અને ખર્ચ ઉમેર્યા પછી અહીં દેખાશે.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),

        header: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'Farm Expense Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
            ],
          );
        },

        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        },

        build: (context) {
          List<pw.Widget> content = [];

          // -----------------------------
          // YEAR + CROP
          // -----------------------------

          content.add(
            pw.Text('Year: $selectedYear', style: pw.TextStyle(fontSize: 12)),
          );

          content.add(
            pw.Text('Crop: $selectedCrop', style: pw.TextStyle(fontSize: 12)),
          );

          content.add(pw.SizedBox(height: 15));

          // -----------------------------
          // VILLAGES
          // -----------------------------

          for (final villageData in expenseData) {
            final String village = villageData['village'];

            final List regions = villageData['regions'];

            // Village heading
            content.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey300,
                child: pw.Text(
                  'Village: $village',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            content.add(pw.SizedBox(height: 8));

            // -----------------------------
            // REGIONS
            // -----------------------------

            for (final regionData in regions) {
              final String region = regionData['region'];

              final List farms = regionData['farms'];

              content.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8, bottom: 5),
                  child: pw.Text(
                    'Region: $region',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );

              // -----------------------------
              // FARMS
              // -----------------------------

              for (final farmData in farms) {
                final String farm = farmData['farm'];

                final List expenses = farmData['expenses'];

                content.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 5, bottom: 5),
                    child: pw.Text(
                      'Farm: $farm',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                );

                // -----------------------------
                // EXPENSE TABLE
                // -----------------------------

                List<List<String>> tableData = [
                  ['Date', 'Work', 'Type', 'Details', 'Amount'],
                ];

                for (final expense in expenses) {
                  tableData.add([
                    expense['date'].toString(),
                    expense['work'].toString(),
                    expense['type'].toString(),
                    expense['details'].toString(),
                    '₹${expense['amount'].toStringAsFixed(2)}',
                  ]);
                }

                content.add(
                  pw.TableHelper.fromTextArray(
                    headers: tableData.first,
                    data: tableData.skip(1).toList(),

                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),

                    cellStyle: const pw.TextStyle(fontSize: 8),

                    cellAlignment: pw.Alignment.centerLeft,

                    border: pw.TableBorder.all(
                      color: PdfColors.grey,
                      width: 0.5,
                    ),

                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),

                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.2),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.2),
                      3: const pw.FlexColumnWidth(2.5),
                      4: const pw.FlexColumnWidth(1.2),
                    },
                  ),
                );

                // -----------------------------
                // FARM TOTAL
                // -----------------------------

                final double farmTotal = getFarmTotal(farmData);

                content.add(
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        'Farm Total: ₹${farmTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );

                content.add(pw.SizedBox(height: 10));
              }

              // -----------------------------
              // REGION TOTAL
              // -----------------------------

              final double regionTotal = getRegionTotal(regionData);

              content.add(
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Region Total: ₹${regionTotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );

              content.add(pw.SizedBox(height: 12));
            }

            // -----------------------------
            // VILLAGE TOTAL
            // -----------------------------

            final double villageTotal = getVillageTotal(villageData);

            content.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  'Village Total: ₹${villageTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            content.add(pw.SizedBox(height: 15));
          }

          // -----------------------------
          // GRAND TOTAL
          // -----------------------------

          final double grandTotal = getGrandTotal();

          content.add(
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              color: PdfColors.grey300,
              child: pw.Text(
                'GRAND TOTAL: ₹${grandTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );

          return content;
        },
      ),
    );

    // -----------------------------
    // OPEN / PRINT PDF
    // -----------------------------

    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }
}
