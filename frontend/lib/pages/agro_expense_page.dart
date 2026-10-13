
import 'package:flutter/material.dart';
import 'services/api_service.dart'; // Adjust this path for your project.

class AgroExpensePage extends StatefulWidget {
  final int userId;

  const AgroExpensePage({
    super.key,
    required this.userId,
  });

  @override
  State<AgroExpensePage> createState() => _AgroExpensePageState();
}

class _AgroExpensePageState extends State<AgroExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final productNameController = TextEditingController();
  final quantityController = TextEditingController();
  final measurementController = TextEditingController();
  final priceController = TextEditingController();

  final List<String> units = const [
    'BAG',
    'KG',
    'LITER',
    'BOTTLE',
    'PACKET',
    'DRUM',
    'PIECE',
  ];

  String quantityUnit = 'BAG';
  String measurementUnit = 'KG';
  DateTime selectedDate = DateTime.now();

  double totalWeight = 0;
  double totalAmount = 0;

  bool isSaving = false;
  bool isLoading = false;

  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  @override
  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    measurementController.dispose();
    priceController.dispose();
    super.dispose();
  }

  double get quantity =>
      double.tryParse(quantityController.text.trim()) ?? 0;

  double get measurement =>
      double.tryParse(measurementController.text.trim()) ?? 0;

  double get price =>
      double.tryParse(priceController.text.trim()) ?? 0;

  void calculateTotals() {
    setState(() {
      totalWeight = quantity * measurement;
      totalAmount = quantity * price;
    });
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  // GET /api/agro
  Future<void> loadExpenses() async {
    setState(() => isLoading = true);

    try {
      final result = await ApiService.getAgroExpenses();

      if (!mounted) return;

      setState(() {
        // Filter locally because the current GET endpoint returns all records.
        expenses = result
            .where((item) =>
                item is Map &&
                item['userId']?.toString() == widget.userId.toString())
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    } catch (e) {
      showMessage('ખર્ચ લોડ કરવામાં ભૂલ: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // POST /api/agro
  Future<void> addAgroExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final body = <String, dynamic>{
      'userId': widget.userId,
      'productName': productNameController.text.trim(),
      'quantity': {
        'value': quantity,
        'unit': quantityUnit,
      },
      'measurement': {
        'value': measurement,
        'unit': measurementUnit,
      },
      'pricePerUnit': price,
      'totalWeight': {
        'value': totalWeight,
        'unit': measurementUnit,
      },
      'totalAmount': totalAmount,
      'purchaseDate':
          '${selectedDate.year.toString().padLeft(4, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}',
    };

    try {
      await ApiService.addAgroExpense(body: body);

      if (!mounted) return;

      productNameController.clear();
      quantityController.clear();
      measurementController.clear();
      priceController.clear();

      setState(() {
        totalWeight = 0;
        totalAmount = 0;
        quantityUnit = 'BAG';
        measurementUnit = 'KG';
        selectedDate = DateTime.now();
      });

      showMessage('કૃષિ ઉત્પાદનનો ખર્ચ સફળતાપૂર્વક ઉમેરાયો');
      await loadExpenses();
    } catch (e) {
      showMessage('ખર્ચ ઉમેરવામાં ભૂલ: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // PUT /api/agro/{id}
  Future<void> editExpense(Map<String, dynamic> expense) async {
    final id = int.tryParse('${expense['id']}');

    if (id == null) {
      showMessage('ખર્ચની ID મળી નથી. AgroMapper તપાસો.');
      return;
    }

    final nameController = TextEditingController(
      text: '${expense['productName'] ?? ''}',
    );
    final qtyController = TextEditingController(
      text: '${expense['quantity']?['value'] ?? ''}',
    );
    final measurementValueController = TextEditingController(
      text: '${expense['measurement']?['value'] ?? ''}',
    );
    final priceValueController = TextEditingController(
      text: '${expense['pricePerUnit'] ?? ''}',
    );

    String editQuantityUnit =
        '${expense['quantity']?['unit'] ?? 'BAG'}';
    String editMeasurementUnit =
        '${expense['measurement']?['unit'] ?? 'KG'}';

    DateTime editDate = DateTime.tryParse(
          '${expense['purchaseDate'] ?? ''}',
        ) ??
        DateTime.now();

    final editFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('ખર્ચમાં ફેરફાર કરો'),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'ઉત્પાદનનું નામ',
                        ),
                        validator: requiredText,
                      ),
                      TextFormField(
                        controller: qtyController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'જથ્થો',
                        ),
                        validator: positiveNumber,
                      ),
                      DropdownButtonFormField<String>(
                        value: editQuantityUnit,
                        decoration: const InputDecoration(
                          labelText: 'જથ્થાનો એકમ',
                        ),
                        items: units
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(
                                () => editQuantityUnit = value);
                          }
                        },
                      ),
                      TextFormField(
                        controller: measurementValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'એક બેગ/વસ્તુનું માપ',
                        ),
                        validator: positiveNumber,
                      ),
                      DropdownButtonFormField<String>(
                        value: editMeasurementUnit,
                        decoration: const InputDecoration(
                          labelText: 'માપનો એકમ',
                        ),
                        items: units
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(
                                () => editMeasurementUnit = value);
                          }
                        },
                      ),
                      TextFormField(
                        controller: priceValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'એકમનો ભાવ (₹)',
                        ),
                        validator: positiveNumber,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: editDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => editDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(formatDate(editDate)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('રદ કરો'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!editFormKey.currentState!.validate()) return;

                    final qty = double.parse(qtyController.text.trim());
                    final measure = double.parse(
                        measurementValueController.text.trim());
                    final unitPrice =
                        double.parse(priceValueController.text.trim());

                    final body = <String, dynamic>{
                      'userId': widget.userId,
                      'productName': nameController.text.trim(),
                      'quantity': {
                        'value': qty,
                        'unit': editQuantityUnit,
                      },
                      'measurement': {
                        'value': measure,
                        'unit': editMeasurementUnit,
                      },
                      'pricePerUnit': unitPrice,
                      'totalWeight': {
                        'value': qty * measure,
                        'unit': editMeasurementUnit,
                      },
                      'totalAmount': qty * unitPrice,
                      'purchaseDate':
                          '${editDate.year.toString().padLeft(4, '0')}-'
                          '${editDate.month.toString().padLeft(2, '0')}-'
                          '${editDate.day.toString().padLeft(2, '0')}',
                    };

                    Navigator.pop(dialogContext);

                    try {
                      await ApiService.updateAgroExpense(
                        id,
                        body: body,
                      );

                      showMessage('ખર્ચ અપડેટ થયો');
                      await loadExpenses();
                    } catch (e) {
                      showMessage('અપડેટ કરવામાં ભૂલ: $e');
                    }
                  },
                  child: const Text('સેવ કરો'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    qtyController.dispose();
    measurementValueController.dispose();
    priceValueController.dispose();
  }

  // DELETE /api/agro/{id}
  Future<void> deleteExpense(Map<String, dynamic> expense) async {
    final id = int.tryParse('${expense['id']}');

    if (id == null) {
      showMessage('ખર્ચની ID મળી નથી. AgroMapper તપાસો.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ખર્ચ કાઢી નાખવો છે?'),
        content: Text('${expense['productName'] ?? ''} કાઢી નાખશો?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ના'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('હા, કાઢી નાખો'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteAgroExpense(id);
      showMessage('ખર્ચ કાઢી નાખ્યો');
      await loadExpenses();
    } catch (e) {
      showMessage('ખર્ચ કાઢી નાખવામાં ભૂલ: $e');
    }
  }

  String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'આ માહિતી દાખલ કરો';
    }
    return null;
  }

  String? positiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'શૂન્ય કરતાં વધુ સંખ્યા દાખલ કરો';
    }

    return null;
  }

  Widget buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onChanged: (_) => calculateTotals(),
      validator: positiveNumber,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildExpenseCard(Map<String, dynamic> expense) {
    final id = expense['id'];
    final quantity = expense['quantity'];
    final measurement = expense['measurement'];
    final weight = expense['totalWeight'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${expense['productName'] ?? 'ઉત્પાદન'}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'ફેરફાર કરો',
                  onPressed: () => editExpense(expense),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'કાઢી નાખો',
                  onPressed: () => deleteExpense(expense),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Text(
              'જથ્થો: ${quantity?['value'] ?? '-'} '
              '${quantity?['unit'] ?? ''}',
            ),
            Text(
              'માપ: ${measurement?['value'] ?? '-'} '
              '${measurement?['unit'] ?? ''}',
            ),
            Text(
              'કુલ વજન: ${weight?['value'] ?? '-'} '
              '${weight?['unit'] ?? ''}',
            ),
            Text(
              'તારીખ: ${expense['purchaseDate'] ?? '-'}',
            ),
            const Divider(),
            Text(
              'કુલ ખર્ચ: ₹${expense['totalAmount'] ?? 0}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (id != null)
              Text(
                'ID: $id',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કૃષિ ઉત્પાદન ખર્ચ'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadExpenses,
            tooltip: 'રીફ્રેશ',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadExpenses,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'કૃષિ ઉત્પાદન ખરીદી',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'ખાતર, દવા અને અન્ય કૃષિ વસ્તુઓની ખરીદીનો ખર્ચ ઉમેરો.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: productNameController,
                      validator: requiredText,
                      decoration: InputDecoration(
                        labelText: 'કૃષિ ઉત્પાદનનું નામ',
                        hintText: 'ઉદાહરણ: યુરિયા',
                        prefixIcon:
                            const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    buildNumberField(
                      controller: quantityController,
                      label: 'કેટલો જથ્થો ખરીદ્યો?',
                      icon: Icons.shopping_bag_outlined,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: quantityUnit,
                      decoration: const InputDecoration(
                        labelText: 'જથ્થાનો એકમ',
                        border: OutlineInputBorder(),
                      ),
                      items: units
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => quantityUnit = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    buildNumberField(
                      controller: measurementController,
                      label: 'એક બેગ/વસ્તુનું માપ',
                      icon: Icons.scale_outlined,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: measurementUnit,
                      decoration: const InputDecoration(
                        labelText: 'માપનો એકમ',
                        border: OutlineInputBorder(),
                      ),
                      items: units
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => measurementUnit = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    buildNumberField(
                      controller: priceController,
                      label: 'એકમનો ભાવ (₹)',
                      icon: Icons.currency_rupee,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _summaryCard(
                'કુલ વજન',
                '${totalWeight.toStringAsFixed(2)} $measurementUnit',
                Icons.scale_outlined,
              ),
              const SizedBox(height: 12),
              _summaryCard(
                'કુલ ખરીદી ખર્ચ',
                '₹${totalAmount.toStringAsFixed(2)}',
                Icons.currency_rupee,
              ),

              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('ખરીદીની તારીખ'),
                subtitle: Text(formatDate(selectedDate)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: selectPurchaseDate,
              ),

              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : addAgroExpense,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    isSaving ? 'સેવ થઈ રહ્યું છે...' : 'ખર્ચ ઉમેરો',
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'સેવ કરેલા ખર્ચ',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text('${expenses.length}'),
                ],
              ),
              const SizedBox(height: 12),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'હજુ કોઈ ખર્ચ ઉમેર્યો નથી.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...expenses.map(buildExpenseCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
