
import 'package:flutter/material.dart';
import 'package:frontend/pages/Agro_product_purches_page/AgroExpenseAnalyticsPage.dart';

import '../services/api_service.dart';

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

  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _measurementController = TextEditingController();
  final _priceController = TextEditingController();

  final List<String> _units = [
    'BAG',
    'KG',
    'LITER',
    'BOTTLE',
    'PACKET',
    'DRUM',
    'PIECE',
  ];

  String _quantityUnit = 'BAG';
  String _measurementUnit = 'KG';

  DateTime _purchaseDate = DateTime.now();

  bool _isLoading = false;
  bool _isSaving = false;

  int? _editingId;

  List<Map<String, dynamic>> _expenses = [];

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _nestedValue(dynamic value) {
    if (value is Map) return _number(value['value']);
    return _number(value);
  }

  String _nestedUnit(dynamic value, [String fallback = '']) {
    if (value is Map) return value['unit']?.toString() ?? fallback;
    return fallback;
  }

  double get _currentQuantity =>
      _number(_quantityController.text);

  double get _currentMeasurement =>
      _number(_measurementController.text);

  double get _currentPrice =>
      _number(_priceController.text);

  double get _currentWeight =>
      _currentQuantity * _currentMeasurement;

  // This follows the current form's price-per-quantity calculation.
  double get _currentAmount =>
      _currentQuantity * _currentPrice;

  double get _savedTotal {
    return _expenses.fold<double>(
      0,
      (sum, item) => sum + _number(item['totalAmount']),
    );
  }

  String _dateString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return 'તારીખ ઉપલબ્ધ નથી';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _measurementController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> loadExpenses() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await ApiService.getAgroExpenses();

      final items = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where(
            (item) =>
                item['userId']?.toString() == widget.userId.toString(),
          )
          .toList();

      items.sort((a, b) {
        final dateA = DateTime.tryParse(
              a['purchaseDate']?.toString() ?? '',
            ) ??
            DateTime(2000);

        final dateB = DateTime.tryParse(
              b['purchaseDate']?.toString() ?? '',
            ) ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() => _expenses = items);
    } catch (e) {
      _message('ખર્ચ લોડ થઈ શક્યો નથી');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null && mounted) {
      setState(() => _purchaseDate = selected);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _productController.clear();
    _quantityController.clear();
    _measurementController.clear();
    _priceController.clear();

    setState(() {
      _editingId = null;
      _quantityUnit = 'BAG';
      _measurementUnit = 'KG';
      _purchaseDate = DateTime.now();
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = _currentQuantity;
    final measurement = _currentMeasurement;
    final price = _currentPrice;

    final body = <String, dynamic>{
      'userId': widget.userId,
      'productName': _productController.text.trim(),
      'quantity': {
        'value': quantity,
        'unit': _quantityUnit,
      },
      'measurement': {
        'value': measurement,
        'unit': _measurementUnit,
      },
      'totalWeight': {
        'value': quantity * measurement,
        'unit': _measurementUnit,
      },
      'pricePerUnit': price,
      'totalAmount': quantity * price,
      'purchaseDate': _dateString(_purchaseDate),
    };

    setState(() => _isSaving = true);

    try {
      if (_editingId == null) {
        await ApiService.addAgroExpense(body: body);
        _message('ખર્ચ સફળતાપૂર્વક ઉમેરાયો');
      } else {
        await ApiService.updateAgroExpense(
          _editingId!,
          body: body,
        );
        _message('ખર્ચ અપડેટ થયો');
      }

      _resetForm();
      await loadExpenses();
    } catch (e) {
      _message('ખર્ચ સેવ થઈ શક્યો નથી: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> editExpense(Map<String, dynamic> item) async {
    final id = int.tryParse(item['id']?.toString() ?? '');

    if (id == null) {
      _message('ખર્ચની ID ઉપલબ્ધ નથી');
      return;
    }

    setState(() {
      _editingId = id;

      _productController.text =
          item['productName']?.toString() ?? '';

      _quantityController.text =
          _nestedValue(item['quantity']).toString();

      _quantityUnit =
          _nestedUnit(item['quantity'], 'BAG');

      _measurementController.text =
          _nestedValue(item['measurement']).toString();

      _measurementUnit =
          _nestedUnit(item['measurement'], 'KG');

      _priceController.text =
          _number(item['pricePerUnit']).toString();

      _purchaseDate = DateTime.tryParse(
            item['purchaseDate']?.toString() ?? '',
          ) ??
          DateTime.now();
    });

    _message('હવે ફોર્મમાં ફેરફાર કરીને અપડેટ કરો');

    if (mounted) {
      await Scrollable.ensureVisible(
        _formKey.currentContext ?? context,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> deleteExpense(Map<String, dynamic> item) async {
    final id = int.tryParse(item['id']?.toString() ?? '');

    if (id == null) {
      _message('ખર્ચની ID ઉપલબ્ધ નથી');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ખર્ચ કાઢી નાખવો છે?'),
        content: Text(
          '${item['productName'] ?? 'આ ખર્ચ'} કાઢી નાખવામાં આવશે.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('રદ કરો'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('કાઢી નાખો'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteAgroExpense(id);
      _message('ખર્ચ કાઢી નાખ્યો');
      await loadExpenses();
    } catch (e) {
      _message('ખર્ચ કાઢી શકાયો નથી');
    }
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool requiredText = false,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      keyboardType: requiredText
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return requiredText
              ? 'વસ્તુનું નામ દાખલ કરો'
              : 'આ માહિતી જરૂરી છે';
        }

        if (!requiredText) {
          final number = double.tryParse(value.trim());
          if (number == null || number <= 0) {
            return 'શૂન્ય કરતાં મોટી સંખ્યા દાખલ કરો';
          }
        }

        return null;
      },
    );
  }

  Widget _unitDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      items: _units.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _currentTotal({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade800, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
Widget _expenseCard(Map<String, dynamic> item) {
  return Card(
    color: Colors.white.withValues(alpha: 0.75),
    elevation: 1,
    margin: const EdgeInsets.symmetric(vertical: 5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
  width: 48,
  height: 48,
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: Colors.green.withValues(alpha: 0.15),
    shape: BoxShape.circle,
  ),
  child: Transform.scale(
    scale: 1.3, // Zooms past the outer white margin
    child: Image.asset(
      'assets/images/bag_agro_expense_icon_image.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.grass,
        color: Colors.green,
      ),
    ),
  ),
),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName']?.toString() ?? 'ખર્ચ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('તારીખ: ${_formatDate(item['purchaseDate'])}'),
                Text(
                  'જથ્થો: ${_nestedValue(item['quantity'])} '
                  '${_nestedUnit(item['quantity'])}',
                ),
                Text(
                  'કુલ: ₹${_number(item['totalAmount']).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'ફેરફાર કરો',
                onPressed: () => editExpense(item),
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                tooltip: 'કાઢી નાખો',
                onPressed: () => deleteExpense(item),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
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
        title: const Text('ખેતી દવા ખર્ચ'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'ખર્ચનો ચાર્ટ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AgroExpenseAnalyticsPage(
                    userId: widget.userId,
                    onEdit: editExpense,
                    onDelete: deleteExpense,
                  ),
                ),
              );
            },
            icon: Image.asset(
              'assets/images/Agro_expense_icon_image.png',
              width: 29,
              height: 29,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pie_chart_outline),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Agro_expense_page_image.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.green.shade50),
          ),
          Container(
            color: Colors.white.withValues(alpha: 0.55),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadExpenses,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingId == null
                                ? 'નવો ખર્ચ ઉમેરો'
                                : 'ખર્ચમાં ફેરફાર કરો',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _input(
                            label: 'દવા / વસ્તુનું નામ',
                            controller: _productController,
                            hint: 'ઉદાહરણ: ખાતર',
                            requiredText: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _input(
                                  label: 'જથ્થો',
                                  controller: _quantityController,
                                  hint: 'ઉદાહરણ: 2',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _unitDropdown(
                                  label: 'એકમ',
                                  value: _quantityUnit,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _quantityUnit = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _input(
                                  label: 'એક જથ્થાનું માપ',
                                  controller: _measurementController,
                                  hint: 'ઉદાહરણ: 5',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _unitDropdown(
                                  label: 'માપનો એકમ',
                                  value: _measurementUnit,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(
                                        () => _measurementUnit = value,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _input(
                            label: 'એક જથ્થાની કિંમત (₹)',
                            controller: _priceController,
                            hint: 'ઉદાહરણ: 450',
                          ),
                          const SizedBox(height: 12),
                          _currentTotal(
                            icon: Icons.scale_outlined,
                            label: 'કુલ વજન',
                            value: '${_currentWeight.toStringAsFixed(2)} '
                                '$_measurementUnit',
                          ),
                          const SizedBox(height: 9),
                          _currentTotal(
                            icon: Icons.currency_rupee,
                            label: 'આ ખરીદીનો ખર્ચ',
                            value: '₹${_currentAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_month),
                            title: const Text('ખરીદીની તારીખ'),
                            subtitle: Text(_formatDate(_dateString(_purchaseDate))),
                            trailing: TextButton(
                              onPressed: _selectDate,
                              child: const Text('બદલો'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveExpense,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _editingId == null
                                          ? Icons.add
                                          : Icons.save,
                                    ),
                              label: Text(
                                _editingId == null
                                    ? 'ખર્ચ ઉમેરો'
                                    : 'ખર્ચ અપડેટ કરો',
                              ),
                            ),
                          ),
                          if (_editingId != null)
                            Center(
                              child: TextButton(
                                onPressed: _resetForm,
                                child: const Text('ફેરફાર રદ કરો'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.green),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'જૂના ખર્ચ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '₹${_savedTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('હજુ કોઈ ખર્ચ નોંધાયો નથી')),
                    )
                  else
                    ..._expenses.map(_expenseCard),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
