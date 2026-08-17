import 'package:flutter/material.dart';

class AgroExpensePage extends StatefulWidget {
  const AgroExpensePage({super.key});

  @override
  State<AgroExpensePage> createState() =>
      _AgroExpensePageState();
}

class _AgroExpensePageState
    extends State<AgroExpensePage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController productNameController =
      TextEditingController();

  final TextEditingController bagWeightController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController pricePerBagController =
      TextEditingController();

  final TextEditingController totalWeightController =
      TextEditingController();

  // ============================================================
  // VALUES
  // ============================================================

  String selectedUnit = 'બેગ';

  DateTime selectedDate = DateTime.now();

  double totalAmount = 0;

  // ============================================================
  // CALCULATE
  //
  // Example:
  //
  // Urea
  // 1 bag = 45 kg
  // 3 bags
  // ₹300 / bag
  //
  // Total = 3 × ₹300 = ₹900
  // Weight = 3 × 45 = 135 kg
  // ============================================================

  void calculateTotal() {
    final double quantity =
        double.tryParse(
              quantityController.text,
            ) ??
            0;

    final double price =
        double.tryParse(
              pricePerBagController.text,
            ) ??
            0;

    setState(() {
      totalAmount = quantity * price;
    });
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> selectDate() async {
    final DateTime? picked =
        await showDatePicker(
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

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  // ============================================================
  // ADD AGRO EXPENSE
  // ============================================================

  void addAgroExpense() {
    final String productName =
        productNameController.text.trim();

    final double bagWeight =
        double.tryParse(
              bagWeightController.text,
            ) ??
            0;

    final double quantity =
        double.tryParse(
              quantityController.text,
            ) ??
            0;

    final double price =
        double.tryParse(
              pricePerBagController.text,
            ) ??
            0;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (productName.isEmpty) {
      showMessage(
        'કૃષિ ઉત્પાદનનું નામ દાખલ કરો',
      );
      return;
    }

    if (bagWeight <= 0) {
      showMessage(
        'એક બેગમાં કેટલું વજન છે તે દાખલ કરો',
      );
      return;
    }

    if (quantity <= 0) {
      showMessage(
        'કેટલી બેગ ખરીદી તે દાખલ કરો',
      );
      return;
    }

    if (price <= 0) {
      showMessage(
        'એક બેગનો ભાવ દાખલ કરો',
      );
      return;
    }

    // ----------------------------------------------------------
    // TOTAL WEIGHT
    // ----------------------------------------------------------

    final double totalWeight =
        bagWeight * quantity;

    // ----------------------------------------------------------
    // TOTAL AMOUNT
    // ----------------------------------------------------------

    final double amount =
        quantity * price;

    // ----------------------------------------------------------
    // DATA
    //
    // Later this will go to Spring Boot API.
    // ----------------------------------------------------------

    final Map<String, dynamic>
        agroExpense = {
      'productName': productName,

      'weightPerBag': bagWeight,

      'quantity': quantity,

      'totalWeight': totalWeight,

      'pricePerBag': price,

      'totalAmount': amount,

      'unit': selectedUnit,

      'date':
          selectedDate.toIso8601String(),

      // Inventory quantity.
      //
      // Initially everything is available.
      'remainingWeight': totalWeight,

      'usedWeight': 0.0,
    };

    debugPrint(
      'Agro Expense: $agroExpense',
    );

    showMessage(
      'કૃષિ ઉત્પાદનનો ખર્ચ ઉમેરાયો',
    );

    // ----------------------------------------------------------
    // CLEAR FORM
    // ----------------------------------------------------------

    productNameController.clear();
    bagWeightController.clear();
    quantityController.clear();
    pricePerBagController.clear();

    setState(() {
      totalAmount = 0;
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    productNameController.dispose();
    bagWeightController.dispose();
    quantityController.dispose();
    pricePerBagController.dispose();
    totalWeightController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'કૃષિ ઉત્પાદન ખર્ચ',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'કૃષિ ઉત્પાદન ખરીદી',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'ખાતર, દવા અને અન્ય કૃષિ વસ્તુઓની ખરીદીનો ખર્ચ ઉમેરો.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // PRODUCT NAME
              // ==================================================

              _buildTextField(
                controller:
                    productNameController,

                label:
                    'કૃષિ ઉત્પાદનનું નામ',

                hint:
                    'ઉદાહરણ: યુરિયા',

                icon:
                    Icons.inventory_2_outlined,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // WEIGHT PER BAG
              // ==================================================

              _buildNumberField(
                controller:
                    bagWeightController,

                label:
                    'એક બેગનું વજન (કિલો)',

                hint:
                    'ઉદાહરણ: 45',

                icon:
                    Icons.scale_outlined,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // QUANTITY
              // ==================================================

              _buildNumberField(
                controller:
                    quantityController,

                label:
                    'કેટલી બેગ ખરીદી?',

                hint:
                    'ઉદાહરણ: 3',

                icon:
                    Icons.shopping_bag_outlined,

                decimal: false,

                onChanged: (_) {
                  calculateTotal();
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // PRICE PER BAG
              // ==================================================

              _buildNumberField(
                controller:
                    pricePerBagController,

                label:
                    'એક બેગનો ભાવ',

                hint:
                    'ઉદાહરણ: ₹300',

                icon:
                    Icons.currency_rupee,

                onChanged: (_) {
                  calculateTotal();
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TOTAL WEIGHT CARD
              // ==================================================

              _buildWeightCard(),

              const SizedBox(height: 15),

              // ==================================================
              // TOTAL AMOUNT CARD
              // ==================================================

              _buildAmountCard(),

              const SizedBox(height: 20),

              // ==================================================
              // DATE
              // ==================================================

              const Text(
                'ખરીદીની તારીખ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: selectDate,

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),

                  decoration:
                      BoxDecoration(
                    border:
                        Border.all(
                      color:
                          Colors.grey,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons
                            .calendar_today_outlined,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        formattedDate,

                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons
                            .arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // ADD BUTTON
              // ==================================================

              SizedBox(
                height: 54,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      addAgroExpense,

                  icon:
                      const Icon(
                    Icons.add,
                  ),

                  label:
                      const Text(
                    'ખર્ચ ઉમેરો',
                    style:
                        TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOTAL WEIGHT CARD
  // ============================================================

  Widget _buildWeightCard() {
    final double bagWeight =
        double.tryParse(
              bagWeightController.text,
            ) ??
            0;

    final double quantity =
        double.tryParse(
              quantityController.text,
            ) ??
            0;

    final double totalWeight =
        bagWeight * quantity;

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        color: Colors.blue
            .withValues(
          alpha: 0.08,
        ),

        border:
            Border.all(
          color: Colors.blue
              .withValues(
            alpha: 0.2,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              10,
            ),

            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              color: Colors.blue
                  .withValues(
                alpha: 0.12,
              ),
            ),

            child:
                const Icon(
              Icons.scale_outlined,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  'કુલ વજન',
                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '${totalWeight.toStringAsFixed(2)} કિલો',

                  style:
                      const TextStyle(
                    fontSize: 22,
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
  // TOTAL AMOUNT CARD
  // ============================================================

  Widget _buildAmountCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        color: Colors.green
            .withValues(
          alpha: 0.08,
        ),

        border:
            Border.all(
          color: Colors.green
              .withValues(
            alpha: 0.2,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              10,
            ),

            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              color: Colors.green
                  .withValues(
                alpha: 0.12,
              ),
            ),

            child:
                const Icon(
              Icons.currency_rupee,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  'કુલ ખરીદી ખર્ચ',
                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',

                  style:
                      const TextStyle(
                    fontSize: 22,
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
        controller,

    required String label,

    required String hint,

    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration:
          InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon:
            Icon(icon),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                Colors.green.shade700,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER FIELD
  // ============================================================

  Widget _buildNumberField({
    required TextEditingController
        controller,

    required String label,

    required String hint,

    required IconData icon,

    bool decimal = true,

    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,

      keyboardType: decimal
          ? const TextInputType
              .numberWithOptions(
              decimal: true,
            )
          : TextInputType.number,

      onChanged: onChanged,

      decoration:
          InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon:
            Icon(icon),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                Colors.green.shade700,
            width: 2,
          ),
        ),
      ),
    );
  }
}