
import 'package:flutter/material.dart';
import 'package:frontend/pages/services/api_service.dart';

class FarmCropExpenseListPage extends StatefulWidget {
  final int farmId;
  final String farmName;
  final String regionName;
  final int cropCycleId;
  final String cropName;

  const FarmCropExpenseListPage({
    super.key,
    required this.farmId,
    required this.farmName,
    required this.regionName,
    required this.cropCycleId,
    required this.cropName,
  });

  @override
  State<FarmCropExpenseListPage> createState() =>
      _FarmCropExpenseListPageState();
}

class _FarmCropExpenseListPageState
    extends State<FarmCropExpenseListPage> {
  bool isLoading = true;
  String? loadError;
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value, [String fallback = '']) {
    return value?.toString() ?? fallback;
  }

  int? _expenseId(Map<String, dynamic> expense) {
    return _toInt(
      expense['id'] ??
          expense['farmExpenseId'] ??
          expense['expenseId'],
    );
  }

  int? _expenseFarmId(Map<String, dynamic> expense) {
    final value = expense['farmId'] ?? expense['farm']?['id'];
    if (value is Map) return _toInt(value['id']);
    return _toInt(value);
  }

  int? _expenseCropCycleId(Map<String, dynamic> expense) {
    final value =
        expense['cropCycleId'] ?? expense['cropCycle']?['id'];
    if (value is Map) return _toInt(value['id']);
    return _toInt(value);
  }

  Future<void> loadExpenses() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        loadError = null;
      });
    }

    try {
      final response = await ApiService.getFarmExpenses();

      final allExpenses = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final filtered = allExpenses.where((expense) {
        return _expenseFarmId(expense) == widget.farmId &&
            _expenseCropCycleId(expense) == widget.cropCycleId;
      }).toList();

      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(
              _text(a['expenseDate'], '2000-01-01'),
            ) ??
            DateTime(2000);

        final dateB = DateTime.tryParse(
              _text(b['expenseDate'], '2000-01-01'),
            ) ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        expenses = filtered;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadError = error.toString();
        isLoading = false;
      });
    }
  }

  double get totalExpenses {
    return expenses.fold<double>(
      0,
      (sum, expense) => sum + _toDouble(expense['totalCost']),
    );
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  IconData _expenseIcon(Map<String, dynamic> expense) {
    final type = _text(expense['expenseType']).toUpperCase();

    if (type == 'AGRO') {
      return Icons.grass_rounded;
    }

    final name = _text(expense['expenseName']).toLowerCase();

    if (name.contains('labour') || name.contains('worker')) {
      return Icons.groups_rounded;
    }
    if (name.contains('tractor') || name.contains('machine')) {
      return Icons.agriculture_rounded;
    }
    if (name.contains('transport') || name.contains('vehicle')) {
      return Icons.local_shipping_rounded;
    }
    if (name.contains('water') || name.contains('irrigation')) {
      return Icons.water_drop_rounded;
    }
    if (name.contains('seed')) {
      return Icons.eco_rounded;
    }

    return Icons.receipt_long_rounded;
  }

  Color _expenseColor(Map<String, dynamic> expense) {
    return _text(expense['expenseType']).toUpperCase() == 'AGRO'
        ? const Color(0xFF467B35)
        : const Color(0xFF94652C);
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(_text(value));
    if (date == null) return _text(value, 'Date unavailable');

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _confirmDelete(Map<String, dynamic> expense) async {
    final id = _expenseId(expense);

    if (id == null) {
      _message('Expense ID is missing; cannot delete.', error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 36,
        ),
        title: const Text('Delete expense?'),
        content: Text(
          'Delete "${_text(expense['expenseName'], 'this expense')}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteFarmExpense(id);
      if (!mounted) return;

      setState(() {
        expenses.removeWhere((item) => _expenseId(item) == id);
      });

      _message('Expense deleted successfully.');
    } catch (error) {
      if (!mounted) return;
      _message('Could not delete expense: $error', error: true);
    }
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    final id = _expenseId(expense);

    if (id == null) {
      _message('Expense ID is missing; cannot update.', error: true);
      return;
    }

    final nameController = TextEditingController(
      text: _text(expense['expenseName']),
    );
    final quantityController = TextEditingController(
      text: _text(expense['agroQuantity']),
    );
    final productAmountController = TextEditingController(
      text: _text(expense['totalAgroExpense']),
    );
    final workersController = TextEditingController(
      text: _text(expense['numberOfWorkers']),
    );
    final workerPriceController = TextEditingController(
      text: _text(expense['pricePerWorker']),
    );
    final extraController = TextEditingController(
      text: _text(expense['extraCost']),
    );

    final originalType = _text(
      expense['expenseType'],
      'NORMAL',
    ).toUpperCase();

    final isAgro = originalType == 'AGRO';

    DateTime chosenDate = DateTime.tryParse(
          _text(expense['expenseDate']),
        ) ??
        DateTime.now();

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              double number(TextEditingController controller) =>
                  double.tryParse(controller.text.trim()) ?? 0;

              final labourTotal =
                  number(workersController) * number(workerPriceController);

              final total = (isAgro
                      ? number(productAmountController)
                      : 0) +
                  labourTotal +
                  number(extraController);

              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF26733D),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Update Expense')),
                  ],
                ),
                content: SizedBox(
                  width: 440,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Expense Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter expense name';
                              }
                              return null;
                            },
                          ),
                          if (isAgro) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final quantity =
                                    double.tryParse(value?.trim() ?? '');
                                if (quantity == null || quantity <= 0) {
                                  return 'Quantity must be greater than zero';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: productAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Total Product Amount',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final amount =
                                    double.tryParse(value?.trim() ?? '');
                                if (amount == null || amount < 0) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: workersController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Workers',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final n =
                                        double.tryParse(value?.trim() ?? '');
                                    if (n == null || n < 0) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: workerPriceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Each Worker ₹',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final n =
                                        double.tryParse(value?.trim() ?? '');
                                    if (n == null || n < 0) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: extraController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Extra Amount ₹',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final n =
                                  double.tryParse(value?.trim() ?? '');
                              if (n == null || n < 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4F4D8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Calculated Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF26733D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_month),
                            title: const Text('Expense Date'),
                            subtitle: Text(_formatDate(
                              '${chosenDate.year.toString().padLeft(4, '0')}-'
                              '${chosenDate.month.toString().padLeft(2, '0')}-'
                              '${chosenDate.day.toString().padLeft(2, '0')}',
                            )),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: saving
                                  ? null
                                  : () async {
                                      final picked = await showDatePicker(
                                        context: dialogContext,
                                        initialDate: chosenDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );

                                      if (picked != null) {
                                        setDialogState(() {
                                          chosenDate = picked;
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            final name = nameController.text.trim();
                            final quantity = isAgro
                                ? number(quantityController)
                                : 0.0;
                            final productAmount = isAgro
                                ? number(productAmountController)
                                : 0.0;
                            final workers = number(workersController);
                            final workerPrice = number(workerPriceController);
                            final extra = number(extraController);
                            final labour = workers * workerPrice;
                            final grandTotal =
                                productAmount + labour + extra;

                            final date =
                                '${chosenDate.year.toString().padLeft(4, '0')}-'
                                '${chosenDate.month.toString().padLeft(2, '0')}-'
                                '${chosenDate.day.toString().padLeft(2, '0')}';

                            final body = <String, dynamic>{
                              'farmId': widget.farmId,
                              'cropCycleId': widget.cropCycleId,
                              'expenseType': originalType,
                              'expenseName': name,
                              'agroQuantity': isAgro ? quantity : null,
                              'totalAgroExpense':
                                  isAgro ? productAmount : null,
                              'numberOfWorkers': workers,
                              'pricePerWorker': workerPrice,
                              'totalExpenseOfWorkers': labour,
                              'extraCost': extra,
                              'expenseDate': date,
                              'totalCost': grandTotal,
                            };

                            setDialogState(() => saving = true);

                            try {
                              await ApiService.updateFarmExpense(
                                id,
                                body: body,
                              );

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);

                              if (!mounted) return;
                              _message('Expense updated successfully.');
                              await loadExpenses();
                            } catch (error) {
                              if (!dialogContext.mounted) return;
                              setDialogState(() => saving = false);

                              _message(
                                'Could not update expense: $error',
                                error: true,
                              );
                            }
                          },
                    icon: saving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(saving ? 'Saving...' : 'Save Changes'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF26733D),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      quantityController.dispose();
      productAmountController.dispose();
      workersController.dispose();
      workerPriceController.dispose();
      extraController.dispose();
    }
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF347D43), Color(0xFF1D5931)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Current Crop Expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${expenses.length} expense record(s)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseCard(Map<String, dynamic> expense) {
    final type = _text(expense['expenseType'], 'NORMAL').toUpperCase();
    final isAgro = type == 'AGRO';
    final color = _expenseColor(expense);
    final amount = _toDouble(expense['totalCost']);
    final labour = _toDouble(expense['totalExpenseOfWorkers']);
    final extra = _toDouble(expense['extraCost']);
    final product = _toDouble(expense['totalAgroExpense']);
    final quantity = _text(expense['agroQuantity'], '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _expenseIcon(expense),
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(expense['expenseName'], 'Unnamed Expense'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isAgro ? 'Agro Expense' : 'Normal Expense',
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(expense['expenseDate']),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF236637),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            const Divider(height: 1),
            const SizedBox(height: 10),
            if (isAgro)
              _detailLine(
                Icons.inventory_2_outlined,
                'Product amount',
                '₹${product.toStringAsFixed(2)}',
              ),
            if (isAgro)
              _detailLine(
                Icons.scale_outlined,
                'Quantity',
                quantity,
              ),
            _detailLine(
              Icons.groups_outlined,
              'Labour amount',
              '₹${labour.toStringAsFixed(2)}',
            ),
            _detailLine(
              Icons.add_card_outlined,
              'Extra amount',
              '₹${extra.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editExpense(expense),
                    icon: const Icon(Icons.edit_outlined, size: 19),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF286A3A),
                      side: const BorderSide(color: Color(0xFF286A3A)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(expense),
                    icon: const Icon(Icons.delete_outline, size: 19),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 13),
          const Text(
            'No Expenses Yet',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Expenses saved for this farm and current crop will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF26733D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF28683A),
        foregroundColor: Colors.white,
        title: const Text(
          'Crop Expenses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh expenses',
            onPressed: isLoading ? null : loadExpenses,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadExpenses,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.agriculture_rounded,
                        color: Colors.green.shade800,
                        size: 26,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          '${widget.farmName} - ${widget.regionName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        size: 21,
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current crop: ${widget.cropName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (loadError != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      color: Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Could not load expenses',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: loadExpenses,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else ...[
              _summaryCard(),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF28683A),
                    size: 25,
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Expense History',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${expenses.length} records',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              if (expenses.isEmpty)
                _emptyState()
              else
                ...expenses.map(_expenseCard),
            ],
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}
