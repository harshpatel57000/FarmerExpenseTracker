
import 'package:flutter/material.dart';
import 'package:frontend/pages/farm_expense/farm_crop_expense_list_page.dart';
import '../services/api_service.dart';

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
  static const String backgroundImage =
      'assets/images/Farm_expense_page_image.png';

  String selectedExpenseType = 'Normal Expense';
  bool isSavingExpense = false;

  int? cropCycleId;
  String? activeCropName;
  bool isLoadingCropCycle = true;

  final expenseNameController = TextEditingController();
  final normalLabourNumberController = TextEditingController();
  final normalLabourAmountController = TextEditingController();
  final normalExtraAmountController = TextEditingController();

  final agroProductNameController = TextEditingController();
  final agroQuantityController = TextEditingController();
  final agroTotalAmountController = TextEditingController();
  final agroLabourNumberController = TextEditingController();
  final agroLabourAmountController = TextEditingController();
  final agroExtraAmountController = TextEditingController();

  double normalLabourTotal = 0;
  double normalExtraTotal = 0;
  double normalTotalExpense = 0;

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

  Future<void> loadFarmCropCycle() async {
    try {
      final cycles =
          await ApiService.getCropCyclesByFarm(widget.farmId);

      final activeCycles = cycles.where((item) {
        if (item is! Map) return false;
        return item['status']?.toString().trim().toUpperCase() ==
            'ACTIVE';
      }).toList();

      if (activeCycles.isEmpty) {
        throw Exception(
          'No active crop found. Please add or activate a crop cycle.',
        );
      }

      if (activeCycles.length > 1) {
        throw Exception(
          'Multiple active crop cycles found. Only one should be active.',
        );
      }

      final cycle =
          Map<String, dynamic>.from(activeCycles.first as Map);

      final rawId = cycle['id'] ?? cycle['cropCycleId'];
      final id = rawId is num
          ? rawId.toInt()
          : int.tryParse(rawId?.toString() ?? '');

      final cropName = cycle['cropName']?.toString().trim();

      if (id == null || cropName == null || cropName.isEmpty) {
        throw Exception('Crop cycle information is incomplete.');
      }

      if (!mounted) return;

      setState(() {
        cropCycleId = id;
        activeCropName = cropName;
        isLoadingCropCycle = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        cropCycleId = null;
        activeCropName = null;
        isLoadingCropCycle = false;
      });

      _showMessage(
        'Could not load crop cycle: $error',
        isError: true,
      );
    }
  }

  String get formattedDate =>
      '${selectedDate.day.toString().padLeft(2, '0')}/'
      '${selectedDate.month.toString().padLeft(2, '0')}/'
      '${selectedDate.year}';

  String get apiDate =>
      '${selectedDate.year.toString().padLeft(4, '0')}-'
      '${selectedDate.month.toString().padLeft(2, '0')}-'
      '${selectedDate.day.toString().padLeft(2, '0')}';

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

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
      setState(() => selectedDate = pickedDate);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  bool _hasNegativeValues(List<double> values) =>
      values.any((value) => value < 0);

  bool _checkCropCycleReady() {
    if (isLoadingCropCycle) {
      _showMessage('Please wait while the crop loads.', isError: true);
      return false;
    }

    if (cropCycleId == null) {
      _showMessage(
        'This farm has no active crop cycle.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<void> addNormalExpense() async {
    if (isSavingExpense || !_checkCropCycleReady()) return;

    final name = expenseNameController.text.trim();
    final workers = _number(normalLabourNumberController);
    final workerPrice = _number(normalLabourAmountController);
    final extra = _number(normalExtraAmountController);

    if (name.isEmpty) {
      _showMessage('Please enter expense name.', isError: true);
      return;
    }

    if (_hasNegativeValues([workers, workerPrice, extra])) {
      _showMessage('Amounts cannot be negative.', isError: true);
      return;
    }

    final labourTotal = workers * workerPrice;
    final total = labourTotal + extra;

    final body = <String, dynamic>{
      'farmId': widget.farmId,
      'cropCycleId': cropCycleId,
      'expenseType': 'NORMAL',
      'expenseName': name,
      'agroQuantity': null,
      'totalAgroExpense': null,
      'numberOfWorkers': workers,
      'pricePerWorker': workerPrice,
      'totalExpenseOfWorkers': labourTotal,
      'extraCost': extra,
      'expenseDate': apiDate,
      'totalCost': total,
    };

    setState(() => isSavingExpense = true);

    try {
      await ApiService.addFarmExpense(body: body);
      if (!mounted) return;

      _showMessage('Normal expense saved successfully.');
      expenseNameController.clear();
      normalLabourNumberController.clear();
      normalLabourAmountController.clear();
      normalExtraAmountController.clear();

      setState(() {
        normalLabourTotal = 0;
        normalExtraTotal = 0;
        normalTotalExpense = 0;
      });
    } catch (error) {
      if (mounted) {
        _showMessage('Could not save expense: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => isSavingExpense = false);
    }
  }

  Future<void> addAgroExpense() async {
    if (isSavingExpense || !_checkCropCycleReady()) return;

    final name = agroProductNameController.text.trim();
    final quantity = _number(agroQuantityController);
    final productAmount = _number(agroTotalAmountController);
    final workers = _number(agroLabourNumberController);
    final workerPrice = _number(agroLabourAmountController);
    final extra = _number(agroExtraAmountController);

    if (name.isEmpty) {
      _showMessage('Please enter agro product name.', isError: true);
      return;
    }

    if (quantity <= 0) {
      _showMessage('Quantity must be greater than zero.', isError: true);
      return;
    }

    if (_hasNegativeValues([
      productAmount,
      workers,
      workerPrice,
      extra,
    ])) {
      _showMessage('Amounts cannot be negative.', isError: true);
      return;
    }

    final labourTotal = workers * workerPrice;
    final total = productAmount + labourTotal + extra;

    final body = <String, dynamic>{
      'farmId': widget.farmId,
      'cropCycleId': cropCycleId,
      'expenseType': 'AGRO',
      'expenseName': name,
      'agroQuantity': quantity,
      'totalAgroExpense': productAmount,
      'numberOfWorkers': workers,
      'pricePerWorker': workerPrice,
      'totalExpenseOfWorkers': labourTotal,
      'extraCost': extra,
      'expenseDate': apiDate,
      'totalCost': total,
    };

    setState(() {
      agroProductTotal = productAmount;
      agroLabourTotal = labourTotal;
      agroExtraTotal = extra;
      agroTotalExpense = total;
      isSavingExpense = true;
    });

    try {
      await ApiService.addFarmExpense(body: body);
      if (!mounted) return;

      _showMessage('Agro expense saved successfully.');

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
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Could not save agro expense: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isSavingExpense = false);
    }
  }

  void _openCropExpenseList() {
    if (isLoadingCropCycle || cropCycleId == null) {
      _showMessage(
        'Please wait until the active crop has loaded.',
        isError: true,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmCropExpenseListPage(
          farmId: widget.farmId,
          farmName: widget.farmName,
          regionName: widget.regionName,
          cropCycleId: cropCycleId!,
          cropName: activeCropName ?? widget.cropType,
        ),
      ),
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

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade800, size: 25),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF214B2D),
          ),
        ),
      ],
    );
  }

  Widget _plainSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF214B2D),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool important = false,
    bool numeric = false,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(fontSize: 17, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        filled: true,
        fillColor: important ? const Color(0xFFF0F8E9) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
      ),
    );
  }

  Widget _amountRow(String title, double amount, {bool grand = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grand ? const Color(0xFFE4F4D8) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: grand ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: grand ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: grand ? 21 : 17,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.green.shade800, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expense Date', style: TextStyle(fontSize: 14)),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isSavingExpense ? null : selectDate,
            child: const Text('Change', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _addButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: isSavingExpense ? null : onPressed,
        icon: isSavingExpense
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_circle_outline, size: 26),
        label: Text(
          isSavingExpense ? 'Saving...' : 'Add Expense',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26733D),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _expenseTypeSelector() {
    return Row(
      children: [
        _typeButton('Normal Expense'),
        const SizedBox(width: 12),
        _typeButton('Agro Expense'),
      ],
    );
  }

  Widget _typeButton(String title) {
    final selected = selectedExpenseType == title;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isSavingExpense
            ? null
            : () => setState(() => selectedExpenseType = title),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE0F2D5)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.green.shade700
                  : Colors.grey.shade400,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Colors.green.shade900
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _farmInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Farm Information', Icons.agriculture),
          const SizedBox(height: 13),
          _infoLine('Region', widget.regionName, Icons.location_on_outlined),
          _infoLine('Farm', widget.farmName, Icons.grass),
          _infoLine(
            'Current Crop',
            isLoadingCropCycle
                ? 'Loading...'
                : activeCropName ?? 'Not available',
            Icons.spa_outlined,
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Icon(icon, size: 21, color: Colors.green.shade800),
          const SizedBox(width: 9),
          Text('$label: ', style: const TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _normalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        _field(expenseNameController, 'Expense Name'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _field(
                normalLabourNumberController,
                'Labour Number',
                numeric: true,
                onChanged: calculateNormalExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                normalLabourAmountController,
                'Each Labour Amount',
                numeric: true,
                onChanged: calculateNormalExpense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _amountRow('Total Labour Amount', normalLabourTotal),
        const SizedBox(height: 14),
        _field(
          normalExtraAmountController,
          'Extra Amount',
          numeric: true,
          onChanged: calculateNormalExpense,
        ),
        const SizedBox(height: 15),
        _dateCard(),
        const SizedBox(height: 12),
        _amountRow('Total Expense', normalTotalExpense, grand: true),
        const SizedBox(height: 18),
        _addButton(addNormalExpense),
      ],
    );
  }

  Widget _agroForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _plainSectionTitle('Agro Expense'),
        const SizedBox(height: 17),
        _field(
          agroProductNameController,
          'Agro Product Name',
          important: true,
        ),
        const SizedBox(height: 14),
        _field(
          agroQuantityController,
          'Quantity',
          important: true,
          numeric: true,
        ),
        const SizedBox(height: 14),
        _field(
          agroTotalAmountController,
          'Total Product Amount',
          important: true,
          numeric: true,
          onChanged: calculateAgroExpense,
        ),
        const SizedBox(height: 12),
        _amountRow('Total Product Amount', agroProductTotal),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _field(
                agroLabourNumberController,
                'Labour Number',
                numeric: true,
                onChanged: calculateAgroExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                agroLabourAmountController,
                'Each Labour Amount',
                numeric: true,
                onChanged: calculateAgroExpense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _amountRow('Total Labour Amount', agroLabourTotal),
        const SizedBox(height: 14),
        _field(
          agroExtraAmountController,
          'Extra Expense Amount',
          numeric: true,
          onChanged: calculateAgroExpense,
        ),
        const SizedBox(height: 15),
        _dateCard(),
        const SizedBox(height: 12),
        _amountRow('Total Expense', agroTotalExpense, grand: true),
        const SizedBox(height: 18),
        _addButton(addAgroExpense),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Farm Expense',
          style: TextStyle(
            color: Color(0xFF214B2D),
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'View current crop expenses',
                onPressed: _openCropExpenseList,
                icon: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFF0F4E9),
            ),
          ),
          ColoredBox(
            color: Colors.white.withValues(alpha: 0.76),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _farmInformation(),
                  const SizedBox(height: 20),
                  _expenseTypeSelector(),
                  const SizedBox(height: 23),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: selectedExpenseType == 'Normal Expense'
                        ? _normalForm()
                        : _agroForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
