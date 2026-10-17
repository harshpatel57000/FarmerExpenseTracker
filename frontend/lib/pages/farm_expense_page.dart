import 'package:flutter/material.dart';
import 'services/api_service.dart';

class FarmExpensePage extends StatefulWidget {
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
  String selectedExpenseType = 'Normal Expense';
  bool isSavingExpense = false;

  // Automatically loaded crop cycle for this farm.
  int? cropCycleId;
  String? activeCropName;
  bool isLoadingCropCycle = true;

  // Normal expense controllers.
  final TextEditingController expenseNameController =
      TextEditingController();
  final TextEditingController normalLabourNumberController =
      TextEditingController();
  final TextEditingController normalLabourAmountController =
      TextEditingController();
  final TextEditingController normalExtraAmountController =
      TextEditingController();

  // Agro expense controllers.
  final TextEditingController agroProductNameController =
      TextEditingController();
  final TextEditingController agroQuantityController =
      TextEditingController();
  final TextEditingController agroTotalAmountController =
      TextEditingController();
  final TextEditingController agroLabourNumberController =
      TextEditingController();
  final TextEditingController agroLabourAmountController =
      TextEditingController();
  final TextEditingController agroExtraAmountController =
      TextEditingController();

  // Normal expense totals.
  double normalLabourTotal = 0;
  double normalExtraTotal = 0;
  double normalTotalExpense = 0;

  // Agro expense totals.
  double agroProductTotal = 0;
  double agroLabourTotal = 0;
  double agroExtraTotal = 0;
  double agroTotalExpense = 0;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadFarmCropCycle();
  }

  /// Load the active crop cycle belonging to this farm.
  Future<void> loadFarmCropCycle() async {
    try {
      final cycles =
          await ApiService.getCropCyclesByFarm(widget.farmId);

      final activeCycles = cycles.where((item) {
        if (item is! Map) return false;

        return item['status']
                ?.toString()
                .trim()
                .toUpperCase() ==
            'ACTIVE';
      }).toList();

      if (activeCycles.isEmpty) {
        throw Exception(
          'No active crop cycle found for this farm. '
          'Please add or activate a crop cycle first.',
        );
      }

      if (activeCycles.length > 1) {
        throw Exception(
          'Multiple active crop cycles found for this farm. '
          'Only one active cycle should exist.',
        );
      }

      final cycle =
          Map<String, dynamic>.from(activeCycles.first as Map);

      final rawId = cycle['id'] ?? cycle['cropCycleId'];

      final id = rawId is num
          ? rawId.toInt()
          : int.tryParse(rawId?.toString() ?? '');

      final cropName = cycle['cropName']?.toString().trim();

      if (id == null) {
        throw Exception(
          'Crop cycle ID is missing in the backend response.',
        );
      }

      if (cropName == null || cropName.isEmpty) {
        throw Exception(
          'Crop name is missing in the backend response.',
        );
      }

      if (!mounted) return;

      setState(() {
        cropCycleId = id;
        activeCropName = cropName;
        isLoadingCropCycle = false;
      });

      debugPrint('Farm ID: ${widget.farmId}');
      debugPrint('Active crop cycle ID: $cropCycleId');
      debugPrint('Active crop name: $activeCropName');
    } catch (error) {
      debugPrint('LOAD CROP CYCLE ERROR: $error');

      if (!mounted) return;

      setState(() {
        cropCycleId = null;
        activeCropName = null;
        isLoadingCropCycle = false;
      });

      _showMessage(
        'Could not load the farm crop cycle: $error',
        isError: true,
      );
    }
  }

  String get formattedDate {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');

    return '$day/$month/${selectedDate.year}';
  }

  String get apiDate {
    final year = selectedDate.year.toString().padLeft(4, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _number(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  void calculateNormalExpense() {
    normalLabourTotal =
        _number(normalLabourNumberController) *
        _number(normalLabourAmountController);

    normalExtraTotal = _number(normalExtraAmountController);

    normalTotalExpense = normalLabourTotal + normalExtraTotal;

    setState(() {});
  }

  void calculateAgroExpense() {
    agroProductTotal = _number(agroTotalAmountController);

    agroLabourTotal =
        _number(agroLabourNumberController) *
        _number(agroLabourAmountController);

    agroExtraTotal = _number(agroExtraAmountController);

    agroTotalExpense =
        agroProductTotal + agroLabourTotal + agroExtraTotal;

    setState(() {});
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color.fromARGB(255, 125, 74, 70) : const Color.fromARGB(255, 63, 126, 65),
      ),
    );
  }

  bool _hasNegativeValues(List<double> values) {
    return values.any((value) => value < 0);
  }

  bool _checkCropCycleReady() {
    if (isLoadingCropCycle) {
      _showMessage(
        'Please wait while the farm crop cycle loads.',
        isError: true,
      );
      return false;
    }

    if (cropCycleId == null) {
      _showMessage(
        'Cannot save expense because this farm has no active crop cycle.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE NORMAL EXPENSE
  // POST /api/farm_expense
  // ============================================================

  Future<void> addNormalExpense() async {
    if (isSavingExpense) return;

    if (!_checkCropCycleReady()) return;

    final expenseName = expenseNameController.text.trim();
    final labourNumber = _number(normalLabourNumberController);
    final labourAmount = _number(normalLabourAmountController);
    final extraAmount = _number(normalExtraAmountController);

    if (expenseName.isEmpty) {
      _showMessage(
        'Please enter Expense Name',
        isError: true,
      );
      return;
    }

    if (_hasNegativeValues([
      labourNumber,
      labourAmount,
      extraAmount,
    ])) {
      _showMessage(
        'Amounts cannot be negative',
        isError: true,
      );
      return;
    }

    final labourTotal = labourNumber * labourAmount;
    final totalCost = labourTotal + extraAmount;

    final Map<String, dynamic> requestBody = {
      'farmId': widget.farmId,

      // Active crop cycle is loaded automatically.
      'cropCycleId': cropCycleId,

      'expenseType': 'NORMAL',
      'expenseName': expenseName,
      'agroQuantity': null,
      'totalAgroExpense': null,
      'numberOfWorkers': labourNumber,
      'pricePerWorker': labourAmount,
      'totalExpenseOfWorkers': labourTotal,
      'extraCost': extraAmount,
      'expenseDate': apiDate,
      'totalCost': totalCost,
    };

    setState(() {
      isSavingExpense = true;
    });

    try {
      final response = await ApiService.addFarmExpense(
        body: requestBody,
      );

      if (!mounted) return;

      debugPrint('NORMAL EXPENSE SAVED: $response');

      _showMessage('Normal Expense saved successfully');

      clearNormalForm();
    } catch (error) {
      if (!mounted) return;

      debugPrint('NORMAL EXPENSE ERROR: $error');

      _showMessage(
        'Could not save normal expense: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingExpense = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE AGRO EXPENSE
  // POST /api/farm_expense
  // ============================================================

  Future<void> addAgroExpense() async {
    if (isSavingExpense) return;

    if (!_checkCropCycleReady()) return;

    final productName = agroProductNameController.text.trim();
    final quantity = _number(agroQuantityController);
    final productAmount = _number(agroTotalAmountController);
    final labourNumber = _number(agroLabourNumberController);
    final labourAmount = _number(agroLabourAmountController);
    final extraAmount = _number(agroExtraAmountController);

    if (productName.isEmpty) {
      _showMessage(
        'Please enter Agro Product Name',
        isError: true,
      );
      return;
    }

    if (quantity <= 0) {
      _showMessage(
        'Quantity must be greater than zero',
        isError: true,
      );
      return;
    }

    if (_hasNegativeValues([
      productAmount,
      labourNumber,
      labourAmount,
      extraAmount,
    ])) {
      _showMessage(
        'Amounts cannot be negative',
        isError: true,
      );
      return;
    }

    final labourTotal = labourNumber * labourAmount;

    final totalCost =
        productAmount + labourTotal + extraAmount;

    final Map<String, dynamic> requestBody = {
      'farmId': widget.farmId,

      // Active crop cycle is loaded automatically.
      'cropCycleId': cropCycleId,

      'expenseType': 'AGRO',
      'expenseName': productName,
      'agroQuantity': quantity,
      'totalAgroExpense': productAmount,
      'numberOfWorkers': labourNumber,
      'pricePerWorker': labourAmount,
      'totalExpenseOfWorkers': labourTotal,
      'extraCost': extraAmount,
      'expenseDate': apiDate,
      'totalCost': totalCost,
    };

    setState(() {
      agroProductTotal = productAmount;
      agroLabourTotal = labourTotal;
      agroExtraTotal = extraAmount;
      agroTotalExpense = totalCost;
      isSavingExpense = true;
    });

    try {
      final response = await ApiService.addFarmExpense(
        body: requestBody,
      );

      if (!mounted) return;

      debugPrint('AGRO EXPENSE SAVED: $response');

      _showMessage('Agro Expense saved successfully');

      clearAgroForm();
    } catch (error) {
      if (!mounted) return;

      debugPrint('AGRO EXPENSE ERROR: $error');

      _showMessage(
        'Could not save agro expense: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingExpense = false;
        });
      }
    }
  }

  void clearNormalForm() {
    expenseNameController.clear();
    normalLabourNumberController.clear();
    normalLabourAmountController.clear();
    normalExtraAmountController.clear();

    setState(() {
      normalLabourTotal = 0;
      normalExtraTotal = 0;
      normalTotalExpense = 0;
    });
  }

  void clearAgroForm() {
    agroProductNameController.clear();
    agroQuantityController.clear();
    agroTotalAmountController.clear();
    agroLabourNumberController.clear();
    agroLabourAmountController.clear();
    agroExtraAmountController.clear();

    setState(() {
      agroProductTotal = 0;
      agroLabourTotal = 0;
      agroExtraTotal = 0;
      agroTotalExpense = 0;
    });
  }

  // ============================================================
  // FARM INFORMATION
  // ============================================================

  Widget _buildFarmInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Region: ${widget.regionName}'),
          const SizedBox(height: 5),
          Text('Farm: ${widget.farmName}'),
          const SizedBox(height: 5),
          Text(
            'Crop: ${isLoadingCropCycle ? 'Loading...' : (activeCropName ?? 'Not available')}',
          ),
          const SizedBox(height: 5),
          Text('Farm ID: ${widget.farmId}'),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isSavingExpense ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.green.shade50
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.green.shade400
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selected
                    ? Colors.green.shade800
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildImportantAgroField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildCalculationRow({
    required String title,
    required double amount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Date',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isSavingExpense ? null : selectDate,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalCard({
    required String title,
    required double amount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSavingExpense ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isSavingExpense
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildProductAmountCheck() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Product Amount',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '₹${agroProductTotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL EXPENSE FORM
  // ============================================================

  Widget _buildNormalExpenseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Normal Expense',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        _buildTextField(
          controller: expenseNameController,
          label: 'Expense Name',
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: normalLabourNumberController,
                label: 'Labour Number',
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => calculateNormalExpense(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: normalLabourAmountController,
                label: 'Each Labour Amount',
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => calculateNormalExpense(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCalculationRow(
          title: 'Total Labour Amount',
          amount: normalLabourTotal,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: normalExtraAmountController,
          label: 'Extra Amount',
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) => calculateNormalExpense(),
        ),
        const SizedBox(height: 18),
        _buildDateCard(),
        const SizedBox(height: 12),
        _buildGrandTotalCard(
          title: 'Total Expense',
          amount: normalTotalExpense,
        ),
        const SizedBox(height: 16),
        _buildAddButton(
          title: 'Add Expense',
          onPressed: addNormalExpense,
        ),
      ],
    );
  }

  // ============================================================
  // AGRO EXPENSE FORM
  // ============================================================

  Widget _buildAgroExpenseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agro Expense',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        _buildImportantAgroField(
          controller: agroProductNameController,
          label: 'Agro Product Name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _buildImportantAgroField(
          controller: agroQuantityController,
          label: 'Quantity',
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _buildImportantAgroField(
          controller: agroTotalAmountController,
          label: 'Total Amount',
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) => calculateAgroExpense(),
        ),
        const SizedBox(height: 12),
        _buildProductAmountCheck(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: agroLabourNumberController,
                label: 'Labour Number',
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => calculateAgroExpense(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: agroLabourAmountController,
                label: 'Each Labour Amount',
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => calculateAgroExpense(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCalculationRow(
          title: 'Total Labour Amount',
          amount: agroLabourTotal,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: agroExtraAmountController,
          label: 'Extra Expense Amount',
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) => calculateAgroExpense(),
        ),
        const SizedBox(height: 18),
        _buildDateCard(),
        const SizedBox(height: 12),
        _buildGrandTotalCard(
          title: 'Total Expense',
          amount: agroTotalExpense,
        ),
        const SizedBox(height: 16),
        _buildAddButton(
          title: 'Add Expense',
          onPressed: addAgroExpense,
        ),
      ],
    );
  }

  @override
  void dispose() {
    expenseNameController.dispose();
    normalLabourNumberController.dispose();
    normalLabourAmountController.dispose();
    normalExtraAmountController.dispose();

    agroProductNameController.dispose();
    agroQuantityController.dispose();
    agroTotalAmountController.dispose();
    agroLabourNumberController.dispose();
    agroLabourAmountController.dispose();
    agroExtraAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFarmInformation(),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildTypeButton(
                    title: 'Normal Expense',
                    selected:
                        selectedExpenseType == 'Normal Expense',
                    onTap: () {
                      setState(() {
                        selectedExpenseType = 'Normal Expense';
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildTypeButton(
                    title: 'Agro Expense',
                    selected:
                        selectedExpenseType == 'Agro Expense',
                    onTap: () {
                      setState(() {
                        selectedExpenseType = 'Agro Expense';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (selectedExpenseType == 'Normal Expense')
                _buildNormalExpenseForm()
              else
                _buildAgroExpenseForm(),
            ],
          ),
        ),
      ),
    );
  }
}