import 'package:flutter/material.dart';

class FarmExpensePage extends StatefulWidget {
  // ============================================================
  // FARM INFORMATION
  // ============================================================

  final String regionName;
  final String farmName;
  final int farmId;
  final String cropType;

  const FarmExpensePage({
    super.key,
    required this.regionName,
    required this.farmName,
    required this.farmId,
    required this.cropType,
  });

  @override
  State<FarmExpensePage> createState() => _FarmExpensePageState();
}

class _FarmExpensePageState extends State<FarmExpensePage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController laborCountController = TextEditingController();

  final TextEditingController laborAmountController = TextEditingController();

  final TextEditingController teaQuantityController = TextEditingController();

  final TextEditingController teaPriceController = TextEditingController(
    text: '65',
  );

  final TextEditingController panMasalaCountController =
      TextEditingController();

  final TextEditingController panMasalaPriceController =
      TextEditingController();

  final TextEditingController snackPriceController = TextEditingController(
    text: '15',
  );

  // ============================================================
  // VARIABLES
  // ============================================================

  String? selectedWorkType;

  DateTime selectedDate = DateTime.now();

  double laborTotal = 0;
  double teaTotal = 0;
  double panMasalaTotal = 0;
  double snackTotal = 0;
  double grandTotal = 0;

  // ============================================================
  // WORK TYPES
  //
  // These depend on the current crop.
  // ============================================================

  List<String> get workTypes {
    final crop = widget.cropType.toLowerCase();

    // ----------------------------------------------------------
    // COTTON
    // ----------------------------------------------------------

    if (crop == 'કપાસ' || crop == 'cotton') {
      return [
        'જમીન તૈયાર કરવી',
        'વાવણી',
        'નિંદામણ',
        'ખાતર નાખવું',
        'દવા છાંટવી',
        'પાણી આપવું',
        'કપાસ વીણવો',
        'કાપણી',
        'અન્ય કામ',
      ];
    }

    // ----------------------------------------------------------
    // WHEAT
    // ----------------------------------------------------------

    if (crop == 'ઘઉં' || crop == 'wheat') {
      return [
        'જમીન તૈયાર કરવી',
        'વાવણી',
        'ખાતર નાખવું',
        'પાણી આપવું',
        'દવા છાંટવી',
        'કાપણી',
        'અન્ય કામ',
      ];
    }

    // ----------------------------------------------------------
    // GROUNDNUT
    // ----------------------------------------------------------

    if (crop == 'મગફળી' || crop == 'groundnut') {
      return [
        'જમીન તૈયાર કરવી',
        'વાવણી',
        'નિંદામણ',
        'ખાતર નાખવું',
        'દવા છાંટવી',
        'પાણી આપવું',
        'મગફળી ઉપાડવી',
        'કાપણી',
        'અન્ય કામ',
      ];
    }

    // ----------------------------------------------------------
    // DEFAULT
    // ----------------------------------------------------------

    return [
      'જમીન તૈયાર કરવી',
      'વાવણી',
      'નિંદામણ',
      'ખાતર નાખવું',
      'દવા છાંટવી',
      'પાણી આપવું',
      'કાપણી',
      'લણણી',
      'અન્ય કામ',
    ];
  }

  // ============================================================
  // CALCULATE EXPENSES
  // ============================================================

  void calculateExpenses() {
    // ----------------------------------------------------------
    // LABOR
    // ----------------------------------------------------------

    final double laborCount = double.tryParse(laborCountController.text) ?? 0;

    final double laborAmount = double.tryParse(laborAmountController.text) ?? 0;

    laborTotal = laborCount * laborAmount;

    // ----------------------------------------------------------
    // TEA
    //
    // Quantity = milliliters
    // Price = price per liter
    // ----------------------------------------------------------

    final double teaQuantityMl =
        double.tryParse(teaQuantityController.text) ?? 0;

    final double teaPricePerLiter =
        double.tryParse(teaPriceController.text) ?? 65;

    teaTotal = (teaQuantityMl / 1000) * teaPricePerLiter;

    // ----------------------------------------------------------
    // PAN MASALA
    // ----------------------------------------------------------

    final double panMasalaCount =
        double.tryParse(panMasalaCountController.text) ?? 0;

    final double panMasalaPrice =
        double.tryParse(panMasalaPriceController.text) ?? 0;

    panMasalaTotal = panMasalaCount * panMasalaPrice;

    // ----------------------------------------------------------
    // SNACK
    //
    // One snack/dish per laborer.
    // ----------------------------------------------------------

    final double snackPrice = double.tryParse(snackPriceController.text) ?? 15;

    snackTotal = laborCount * snackPrice;

    // ----------------------------------------------------------
    // GRAND TOTAL
    // ----------------------------------------------------------

    grandTotal = laborTotal + teaTotal + panMasalaTotal + snackTotal;

    setState(() {});
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  void addExpense() {
    // Calculate latest values first.
    calculateExpenses();

    // ----------------------------------------------------------
    // VALIDATE WORK TYPE
    // ----------------------------------------------------------

    if (selectedWorkType == null) {
      showMessage('કામનો પ્રકાર પસંદ કરો');
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE LABOR COUNT
    // ----------------------------------------------------------

    final double laborCount = double.tryParse(laborCountController.text) ?? 0;

    if (laborCount <= 0) {
      showMessage('મજૂરોની સંખ્યા દાખલ કરો');
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE LABOR AMOUNT
    // ----------------------------------------------------------

    final double laborAmount = double.tryParse(laborAmountController.text) ?? 0;

    if (laborAmount <= 0) {
      showMessage('એક મજૂરની રકમ દાખલ કરો');
      return;
    }

    // ==========================================================
    // EXPENSE OBJECT
    //
    // Later this object can be sent to Spring Boot API.
    // ==========================================================

    final Map<String, dynamic> farmExpense = {
      'regionId': null,
      'regionName': widget.regionName,

      'farmId': widget.farmId,
      'farmName': widget.farmName,

      'cropType': widget.cropType,

      'workType': selectedWorkType,

      'laborCount': laborCount,
      'laborAmount': laborAmount,
      'laborTotal': laborTotal,

      'teaQuantityMl': double.tryParse(teaQuantityController.text) ?? 0,

      'teaPricePerLiter': double.tryParse(teaPriceController.text) ?? 65,

      'teaTotal': teaTotal,

      'panMasalaCount': double.tryParse(panMasalaCountController.text) ?? 0,

      'panMasalaPrice': double.tryParse(panMasalaPriceController.text) ?? 0,

      'panMasalaTotal': panMasalaTotal,

      'snackPricePerPerson': double.tryParse(snackPriceController.text) ?? 15,

      'snackTotal': snackTotal,

      'totalAmount': grandTotal,

      'date': selectedDate.toIso8601String(),
    };

    // ==========================================================
    // TEMPORARY DEBUG
    //
    // Later replace this with API call.
    // ==========================================================

    debugPrint('====================================');

    debugPrint('FARM EXPENSE');

    debugPrint(farmExpense.toString());

    debugPrint('====================================');

    // ==========================================================
    // SUCCESS
    // ==========================================================

    showMessage('ખેતરનો ખર્ચ સફળતાપૂર્વક ઉમેરાયો');

    // ==========================================================
    // CLEAR FORM
    // ==========================================================

    setState(() {
      selectedWorkType = null;

      laborCountController.clear();
      laborAmountController.clear();
      teaQuantityController.clear();
      panMasalaCountController.clear();
      panMasalaPriceController.clear();

      // Keep default prices.
      teaPriceController.text = '65';
      snackPriceController.text = '15';

      laborTotal = 0;
      teaTotal = 0;
      panMasalaTotal = 0;
      snackTotal = 0;
      grandTotal = 0;
    });
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    laborCountController.dispose();
    laborAmountController.dispose();
    teaQuantityController.dispose();
    teaPriceController.dispose();
    panMasalaCountController.dispose();
    panMasalaPriceController.dispose();
    snackPriceController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ખેતરનો ખર્ચ'), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // SELECTED FARM
              // ==================================================
              _buildSelectedFarmCard(),

              const SizedBox(height: 22),

              // ==================================================
              // WORK TYPE
              // ==================================================
              const Text(
                'કામનો પ્રકાર',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedWorkType,

                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.agriculture_outlined),

                  hintText: 'કામ પસંદ કરો',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                items: workTypes.map((String work) {
                  return DropdownMenuItem<String>(
                    value: work,
                    child: Text(work),
                  );
                }).toList(),

                onChanged: (String? value) {
                  setState(() {
                    selectedWorkType = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LABOR
              // ==================================================
              _buildSectionTitle('મજૂરીનો ખર્ચ', Icons.people_outline),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: laborCountController,
                label: 'કેટલા મજૂર કામ કરે છે?',
                hint: 'ઉદાહરણ: 8',
                icon: Icons.people_outline,
                decimal: false,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: laborAmountController,
                label: 'એક મજૂરની રકમ',
                hint: 'ઉદાહરણ: ₹400',
                icon: Icons.currency_rupee,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildCalculationRow(title: 'કુલ મજૂરી', amount: laborTotal),

              const SizedBox(height: 25),

              // ==================================================
              // TEA
              // ==================================================
              _buildSectionTitle('ચાનો ખર્ચ', Icons.local_cafe_outlined),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: teaQuantityController,
                label: 'ચા કેટલી લીધી? (મિલીલીટર)',
                hint: 'ઉદાહરણ: 450',
                icon: Icons.local_cafe_outlined,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: teaPriceController,
                label: 'ચાનો ભાવ (₹ પ્રતિ લીટર)',
                hint: 'ઉદાહરણ: ₹65',
                icon: Icons.currency_rupee,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildCalculationRow(title: 'કુલ ચાનો ખર્ચ', amount: teaTotal),

              const SizedBox(height: 25),

              // ==================================================
              // PAN MASALA
              // ==================================================
              _buildSectionTitle(
                'પાન મસાલાનો ખર્ચ',
                Icons.shopping_bag_outlined,
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: panMasalaCountController,
                label: 'કેટલી વસ્તુ લીધી?',
                hint: 'ઉદાહરણ: 10',
                icon: Icons.shopping_bag_outlined,
                decimal: false,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: panMasalaPriceController,
                label: 'એક વસ્તુનો ભાવ',
                hint: 'ઉદાહરણ: ₹5',
                icon: Icons.currency_rupee,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildCalculationRow(
                title: 'કુલ પાન મસાલાનો ખર્ચ',
                amount: panMasalaTotal,
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SNACK
              // ==================================================
              _buildSectionTitle('નાસ્તાનો ખર્ચ', Icons.restaurant_outlined),

              const SizedBox(height: 12),

              const Text(
                'દરેક મજૂર માટે એક ડિશ ગણવામાં આવશે.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: snackPriceController,
                label: 'એક ડિશનો ભાવ',
                hint: 'ઉદાહરણ: ₹15',
                icon: Icons.currency_rupee,
                onChanged: (_) {
                  calculateExpenses();
                },
              ),

              const SizedBox(height: 14),

              _buildCalculationRow(
                title: 'કુલ નાસ્તાનો ખર્ચ',
                amount: snackTotal,
              ),

              const SizedBox(height: 25),

              // ==================================================
              // DATE
              // ==================================================
              _buildSectionTitle('તારીખ', Icons.calendar_today_outlined),

              const SizedBox(height: 10),

              InkWell(
                onTap: selectDate,

                borderRadius: BorderRadius.circular(12),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),

                      const SizedBox(width: 12),

                      Text(formattedDate, style: const TextStyle(fontSize: 16)),

                      const Spacer(),

                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TOTAL
              // ==================================================
              _buildGrandTotalCard(),

              const SizedBox(height: 22),

              // ==================================================
              // ADD EXPENSE
              // ==================================================
              SizedBox(
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: addExpense,

                  icon: const Icon(Icons.add),

                  label: const Text(
                    'ખર્ચ ઉમેરો',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED FARM CARD
  // ============================================================

  Widget _buildSelectedFarmCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.green.shade50,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.green.shade200),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.agriculture,
              color: Colors.green.shade700,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'પસંદ કરેલ ખેતર',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.regionName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  widget.farmName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Icon(
                      Icons.grass_outlined,
                      size: 16,
                      color: Colors.green.shade700,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'ચાલુ પાક: ${widget.cropType}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ============================================================
  // NUMBER FIELD
  // ============================================================

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool decimal = true,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,

      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,

      onChanged: onChanged,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
      ),
    );
  }

  // ============================================================
  // CALCULATION ROW
  // ============================================================

  Widget _buildCalculationRow({required String title, required double amount}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),

          const Spacer(),

          Text(
            '₹${amount.toStringAsFixed(2)}',

            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAND TOTAL CARD
  // ============================================================

  Widget _buildGrandTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.green.shade50,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.green.shade200),
      ),

      child: Column(
        children: [
          const Text(
            'આ ખેતરનો કુલ ખર્ચ',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 6),

          Text(
            '₹${grandTotal.toStringAsFixed(2)}',

            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              _buildSmallTotal('મજૂરી', laborTotal),

              _buildSmallTotal('ચા', teaTotal),

              _buildSmallTotal('પાન મસાલા', panMasalaTotal),

              _buildSmallTotal('નાસ્તો', snackTotal),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL TOTAL
  // ============================================================

  Widget _buildSmallTotal(String title, double amount) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),

        const SizedBox(height: 3),

        Text(
          '₹${amount.toStringAsFixed(0)}',

          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
