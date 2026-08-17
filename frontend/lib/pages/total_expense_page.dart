import 'package:flutter/material.dart';

class TotalExpensePage extends StatefulWidget {
  const TotalExpensePage({super.key});

  @override
  State<TotalExpensePage> createState() =>
      _TotalExpensePageState();
}

class _TotalExpensePageState
    extends State<TotalExpensePage> {
  // ============================================================
  // FILTER VALUES
  // ============================================================

  String selectedYear = '2026';
  String selectedCrop = 'ઘઉં';

  DateTime? startDate;
  DateTime? endDate;

  // ============================================================
  // DEMO EXPENSE DATA
  //
  // Later this data will come from Spring Boot API.
  // ============================================================

  final List<Map<String, dynamic>> expenseData = [
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
  ];

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectStartDate() async {
    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate:
          startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate:
          endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  // ============================================================
  // DATE TEXT
  // ============================================================

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'તારીખ પસંદ કરો';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // GET FARM TOTAL
  // ============================================================

  double getFarmTotal(
    Map<String, dynamic> farm,
  ) {
    final List expenses =
        farm['expenses'];

    double total = 0;

    for (final expense in expenses) {
      total +=
          expense['amount'] as double;
    }

    return total;
  }

  // ============================================================
  // GET REGION TOTAL
  // ============================================================

  double getRegionTotal(
    Map<String, dynamic> region,
  ) {
    final List farms =
        region['farms'];

    double total = 0;

    for (final farm in farms) {
      total += getFarmTotal(farm);
    }

    return total;
  }

  // ============================================================
  // GET GRAND TOTAL
  // ============================================================

  double getGrandTotal() {
    double total = 0;

    for (final region in expenseData) {
      total += getRegionTotal(region);
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
    final double grandTotal =
        getGrandTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'કુલ ખર્ચ',
        ),
        centerTitle: true,
      ),

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
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        5,
                        16,
                        20,
                      ),

                      children: [

                        // --------------------------------------
                        // SUMMARY
                        // --------------------------------------

                        _buildSummaryCard(
                          grandTotal,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // --------------------------------------
                        // REGION LIST
                        // --------------------------------------

                        ...List.generate(
                          expenseData.length,
                          (index) {
                            return _buildRegionCard(
                              expenseData[index],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // --------------------------------------
                        // GRAND TOTAL
                        // --------------------------------------

                        _buildGrandTotalCard(
                          grandTotal,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // --------------------------------------
                        // PDF BUTTON
                        // --------------------------------------

                        SizedBox(
                          height: 52,

                          child:
                              ElevatedButton.icon(
                            onPressed:
                                generatePdf,

                            icon:
                                const Icon(
                              Icons
                                  .picture_as_pdf_outlined,
                            ),

                            label:
                                const Text(
                              'PDF બનાવો',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
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
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,

        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black
                .withValues(alpha: 0.08),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            'ખર્ચ જુઓ',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: [

              // ----------------------------------------------
              // YEAR
              // ----------------------------------------------

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  initialValue:
                      selectedYear,

                  decoration:
                      InputDecoration(
                    labelText: 'વર્ષ',
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: '2026',
                      child: Text('2026'),
                    ),
                    DropdownMenuItem(
                      value: '2025',
                      child: Text('2025'),
                    ),
                    DropdownMenuItem(
                      value: '2024',
                      child: Text('2024'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear =
                            value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // ----------------------------------------------
              // CROP
              // ----------------------------------------------

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  initialValue:
                      selectedCrop,

                  decoration:
                      InputDecoration(
                    labelText: 'પાક',
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: 'ઘઉં',
                      child: Text('ઘઉં'),
                    ),
                    DropdownMenuItem(
                      value: 'કપાસ',
                      child: Text('કપાસ'),
                    ),
                    DropdownMenuItem(
                      value: 'મગફળી',
                      child: Text('મગફળી'),
                    ),
                    DropdownMenuItem(
                      value: 'બાજરી',
                      child: Text('બાજરી'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCrop =
                            value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // ----------------------------------------------
          // DATE RANGE
          // ----------------------------------------------

          Row(
            children: [

              Expanded(
                child:
                    _buildDateButton(
                  title: 'શરૂઆત',
                  date: startDate,
                  onTap:
                      selectStartDate,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    _buildDateButton(
                  title: 'અંત',
                  date: endDate,
                  onTap:
                      selectEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE BUTTON
  // ============================================================

  Widget _buildDateButton({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(10),

      child: Container(
        padding:
            const EdgeInsets.all(12),

        decoration:
            BoxDecoration(
          border:
              Border.all(
            color:
                Colors.grey.shade400,
          ),

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Row(
              children: [

                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 18,
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child: Text(
                    formatDate(date),
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    double total,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(16),

        color: Colors.green
            .withValues(alpha: 0.08),

        border:
            Border.all(
          color: Colors.green
              .withValues(alpha: 0.25),
        ),
      ),

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration:
                BoxDecoration(
              color: Colors.green
                  .withValues(
                alpha: 0.15,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 30,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  'કુલ ખર્ચ',
                  style:
                      TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  money(total),

                  style:
                      const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
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

  Widget _buildRegionCard(
    Map<String, dynamic> region,
  ) {
    final String regionName =
        region['region'];

    final double regionTotal =
        getRegionTotal(region);

    final List farms =
        region['farms'];

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        childrenPadding:
            const EdgeInsets.fromLTRB(
          10,
          0,
          10,
          10,
        ),

        leading: Container(
          padding:
              const EdgeInsets.all(9),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              10,
            ),

            color: Colors.green
                .withValues(
              alpha: 0.1,
            ),
          ),

          child: const Icon(
            Icons.location_on_outlined,
          ),
        ),

        title: Text(
          regionName,

          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${farms.length} ખેતર',
        ),

        trailing: Text(
          money(regionTotal),

          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,

            color:
                Colors.green.shade700,
          ),
        ),

        children: [
          ...List.generate(
            farms.length,
            (index) {
              return _buildFarmCard(
                farms[index],
              );
            },
          ),

          // Region total
          Container(
            margin:
                const EdgeInsets.only(
              top: 8,
            ),

            padding:
                const EdgeInsets.all(
              14,
            ),

            decoration:
                BoxDecoration(
              color: Colors.grey
                  .withValues(
                alpha: 0.08,
              ),

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  'વિસ્તારનો કુલ ખર્ચ',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  money(regionTotal),

                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
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

  Widget _buildFarmCard(
    Map<String, dynamic> farm,
  ) {
    final String farmName =
        farm['farm'];

    final double farmTotal =
        getFarmTotal(farm);

    final List expenses =
        farm['expenses'];

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      elevation: 0,

      color: Colors.grey
          .withValues(alpha: 0.06),

      child: ExpansionTile(
        title: Text(
          farmName,

          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Text(
          '${expenses.length} ખર્ચ',
        ),

        leading:
            const Icon(
          Icons.agriculture_outlined,
        ),

        trailing: Text(
          money(farmTotal),

          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
            color:
                Colors.green.shade700,
          ),
        ),

        children: [

          // -----------------------------------------------
          // EXPENSE ITEMS
          // -----------------------------------------------

          ...List.generate(
            expenses.length,
            (index) {
              return _buildExpenseItem(
                expenses[index],
              );
            },
          ),

          // -----------------------------------------------
          // FARM TOTAL
          // -----------------------------------------------

          Container(
            margin:
                const EdgeInsets.all(
              12,
            ),

            padding:
                const EdgeInsets.all(
              14,
            ),

            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              color: Colors.white,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  'ખેતરનો કુલ ખર્ચ',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  money(farmTotal),

                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
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

  Widget _buildExpenseItem(
    Map<String, dynamic> expense,
  ) {
    final double amount =
        expense['amount'];

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        4,
      ),

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        border:
            Border.all(
          color:
              Colors.grey.shade300,
        ),

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Icon(
            Icons.receipt_long_outlined,
            size: 22,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  expense['type'],

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  expense['work'],
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  expense['details'],
                  style:
                      const TextStyle(
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  expense['date'],
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            money(amount),

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAND TOTAL CARD
  // ============================================================

  Widget _buildGrandTotalCard(
    double total,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(16),

        color: Colors.green
            .withValues(
          alpha: 0.1,
        ),

        border:
            Border.all(
          color: Colors.green
              .withValues(
            alpha: 0.3,
          ),
        ),
      ),

      child: Column(
        children: [

          const Text(
            'બધા વિસ્તારોનો કુલ ખર્ચ',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            money(total),

            style:
                const TextStyle(
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
            ),
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
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'હજુ કોઈ ખર્ચ મળ્યો નથી.',
            style:
                TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Text(
            'પાક અને ખર્ચ ઉમેર્યા પછી અહીં દેખાશે.',
            style:
                TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF
  // ============================================================

  void generatePdf() {
    // ----------------------------------------------------------
    // Later we will connect the PDF package here.
    //
    // PDF structure:
    //
    // Year → Crop → Date
    //       ↓
    //     Region
    //       ↓
    //     Farm
    //       ↓
    //     Expenses
    //       ↓
    //     Farm Total
    //       ↓
    //     Region Total
    //       ↓
    //     Grand Total
    // ----------------------------------------------------------

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'PDF બનાવવાનું આગળના સ્ટેપમાં જોડશું.',
        ),
      ),
    );
  }
}