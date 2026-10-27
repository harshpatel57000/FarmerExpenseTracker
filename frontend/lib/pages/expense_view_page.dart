
import 'package:flutter/material.dart';

import 'services/api_service.dart';

const Color _green = Color(0xFF086747);
const Color _darkGreen = Color(0xFF064D39);
const Color _cream = Color(0xFFF5F8F0);
const Color _muted = Color(0xFF718078);

const List<Color> _chartColors = [
  Color(0xFF16865B),
  Color(0xFFFF7945),
  Color(0xFF4385F5),
  Color(0xFF9567DB),
  Color(0xFF20A6A9),
  Color(0xFFFFBD45),
  Color(0xFF78909C),
];

class ExpenseViewPage extends StatefulWidget {
  const ExpenseViewPage({super.key});

  @override
  State<ExpenseViewPage> createState() => _ExpenseViewPageState();
}

class _ExpenseViewPageState extends State<ExpenseViewPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> _cycles = [];
  List<Map<String, dynamic>> _expenses = [];

  int? _selectedFarmId;
  int? _selectedCropCycleId;

  // CURRENT = active crop cycles; HISTORY = all crop cycles.
  String _period = 'CURRENT';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;

    return double.tryParse(
      value.toString().replaceAll(',', '').replaceAll('₹', '').trim(),
    );
  }

  String _string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int? _farmId(Map<String, dynamic> item) {
    return _toInt(item['farmId'] ?? item['farm_id']);
  }

  int? _cycleId(Map<String, dynamic> item) {
    return _toInt(
      item['cropCycleId'] ??
          item['cropcycleId'] ??
          item['crop_cycle_id'],
    );
  }

  String _cycleStatus(Map<String, dynamic> cycle) {
    return _string(cycle['status']).toUpperCase();
  }

  bool _isActive(Map<String, dynamic> cycle) {
    return _cycleStatus(cycle) == 'ACTIVE';
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        ApiService.getFarms(),
        ApiService.getFarmExpenses(),
      ]);

      final farms = (results[0] as List)
          .map((item) => _asMap(item))
          .toList();

      final expenses = (results[1] as List)
          .map((item) => _asMap(item))
          .toList();

      final cycles = <Map<String, dynamic>>[];

      // Load cycles farm by farm so each cycle can be associated
      // with its farm even if the API response omits farmId.
      for (final farm in farms) {
        final id = _toInt(farm['id'] ?? farm['farmId']);

        if (id == null) continue;

        final farmCycles = await ApiService.getCropCyclesByFarm(id);

        for (final rawCycle in farmCycles) {
          final cycle = _asMap(rawCycle);
          cycle['_farmId'] = id;
          cycles.add(cycle);
        }
      }

      if (!mounted) return;

      setState(() {
        _farms = farms;
        _cycles = cycles;
        _expenses = expenses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _farmName(int? id) {
    if (id == null) return 'Unknown farm';

    for (final farm in _farms) {
      if (_toInt(farm['id'] ?? farm['farmId']) == id) {
        return _string(farm['name'] ?? farm['farmName'], 'Farm $id');
      }
    }

    return 'Farm $id';
  }

  String _cropName(Map<String, dynamic>? cycle) {
    if (cycle == null) return 'No crop selected';

    return _string(
      cycle['cropName'] ?? cycle['name'],
      'Crop ${cycle['id'] ?? ''}',
    );
  }

  Map<String, dynamic>? _cycleForId(int? id) {
    if (id == null) return null;

    for (final cycle in _cycles) {
      if (_toInt(cycle['id'] ?? cycle['cropCycleId']) == id) {
        return cycle;
      }
    }

    return null;
  }

  int? _expenseFarmId(Map<String, dynamic> expense) {
    final directId = _farmId(expense);
    if (directId != null) return directId;

    final cycle = _cycleForId(_cycleId(expense));
    return cycle == null ? null : _toInt(cycle['_farmId']);
  }

  List<Map<String, dynamic>> get _availableCycles {
    return _cycles.where((cycle) {
      final cycleFarmId = _toInt(cycle['_farmId'] ?? cycle['farmId']);

      if (_selectedFarmId != null &&
          cycleFarmId != _selectedFarmId) {
        return false;
      }

      if (_period == 'CURRENT' && !_isActive(cycle)) {
        return false;
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredExpenses {
    final allowedCycleIds = _availableCycles
        .map((cycle) => _toInt(cycle['id'] ?? cycle['cropCycleId']))
        .whereType<int>()
        .toSet();

    return _expenses.where((expense) {
      if (_selectedFarmId != null &&
          _expenseFarmId(expense) != _selectedFarmId) {
        return false;
      }

      final cycleId = _cycleId(expense);

      // Exclude expenses that do not belong to the selected crop period.
      if (cycleId != null && !allowedCycleIds.contains(cycleId)) {
        return false;
      }

      // If a crop is selected, show expenses for that crop only.
      if (_selectedCropCycleId != null &&
          cycleId != _selectedCropCycleId) {
        return false;
      }

      // Under Current Crop, exclude expenses with no associated cycle,
      // because we cannot verify that they belong to an active crop.
      if (_period == 'CURRENT' && cycleId == null) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(_string(a['expenseDate']));
        final dateB = DateTime.tryParse(_string(b['expenseDate']));

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });
  }

  // totalCost is authoritative. Only use component fields as a fallback
  // when totalCost is absent, to avoid adding the same expense twice.
  double _expenseAmount(Map<String, dynamic> expense) {
    final total = _toDouble(expense['totalCost']);

    if (total != null) return total;

    final agro = _toDouble(expense['totalAgroExpense']);
    if (agro != null) return agro;

    final workers = _toDouble(expense['totalExpenseOfWorkers']);
    final extra = _toDouble(expense['extraCost']);

    return (workers ?? 0) + (extra ?? 0);
  }

  double get _totalExpense {
    return _filteredExpenses.fold<double>(
      0,
      (total, expense) => total + _expenseAmount(expense),
    );
  }

  String _categoryName(Map<String, dynamic> expense) {
    final name = _string(expense['expenseName']);

    if (name.isNotEmpty) return name;

    final type = _string(expense['expenseType']).toUpperCase();

    if (type == 'AGRO') return 'Agro expenses';
    if (type == 'NORMAL') return 'Farm expenses';

    return 'Other expenses';
  }

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};

    for (final expense in _filteredExpenses) {
      final category = _categoryName(expense);
      totals[category] =
          (totals[category] ?? 0) + _expenseAmount(expense);
    }

    return totals;
  }

  String _money(num value) {
    final whole = value.round();
    final digits = whole.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }

    return '₹ ${whole < 0 ? '-' : ''}$buffer';
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(_string(value));

    if (parsed == null) return _string(value, 'Date unavailable');

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${months[parsed.month - 1]} ${parsed.year}';
  }

  void _changePeriod(String value) {
    setState(() {
      _period = value;
      _selectedCropCycleId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 164, 64),
      appBar: AppBar(
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ખર્ચ જુઓ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Expense View',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh expenses',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _green),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: _green,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 16),
                      _buildTotalCard(),
                      const SizedBox(height: 16),
                      _buildOverview(),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 16),
                      _buildExpenseList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: _green,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EDE5)),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFilters() {
    final cycles = _availableCycles;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'પસંદગી કરો',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _selectedFarmId,
            isExpanded: true,
            decoration: _inputDecoration('ખેતર પસંદ કરો'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('તમામ ખેતરો (All Farms)'),
              ),
              ..._farms.map((farm) {
                final id = _toInt(farm['id'] ?? farm['farmId']);

                return DropdownMenuItem<int?>(
                  value: id,
                  child: Text(
                    _string(farm['name'] ?? farm['farmName'], 'Farm'),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFarmId = value;
                _selectedCropCycleId = null;
              });
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'પાકનો સમયગાળો',
            style: TextStyle(
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _periodButton(
                  label: 'ચાલુ પાક',
                  subtitle: 'Current Crop',
                  value: 'CURRENT',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _periodButton(
                  label: 'પૂર્ણ ઇતિહાસ',
                  subtitle: 'Complete History',
                  value: 'HISTORY',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int?>(
            initialValue: _selectedCropCycleId,
            isExpanded: true,
            decoration: _inputDecoration('પાક પસંદ કરો'),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  _period == 'CURRENT'
                      ? 'બધા ચાલુ પાક'
                      : 'બધા પાકનો ઇતિહાસ',
                ),
              ),
              ...cycles.map((cycle) {
                final id = _toInt(cycle['id'] ?? cycle['cropCycleId']);

                return DropdownMenuItem<int?>(
                  value: id,
                  child: Text(
                    '${_cropName(cycle)} · ${_farmName(_toInt(cycle['_farmId']))}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedCropCycleId = value);
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.agriculture, color: _green),
      filled: true,
      fillColor: const Color(0xFFF8FAF6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE8DE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE8DE)),
      ),
    );
  }

  Widget _periodButton({
    required String label,
    required String subtitle,
    required String value,
  }) {
    final selected = _period == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _changePeriod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? _green : const Color(0xFFF5F8F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _green : const Color(0xFFDDE8DE),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, _darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'કુલ ખર્ચ',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _money(_totalExpense),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredExpenses.length} expenses · '
            '${_selectedFarmId == null ? 'All Farms' : _farmName(_selectedFarmId)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final categories = _categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ખર્ચનું વિભાજન',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Expense Overview',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          if (_totalExpense <= 0 || categories.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text('આ પસંદગી માટે કોઈ ખર્ચ મળ્યો નથી.'),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 145,
                  height: 145,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      values: categories.map((e) => e.value).toList(),
                      colors: List.generate(
                        categories.length,
                        (i) => _chartColors[i % _chartColors.length],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'કુલ ખર્ચ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                              Text(
                                _money(_totalExpense),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      categories.length > 5 ? 5 : categories.length,
                      (i) {
                        final entry = categories[i];
                        final percent = entry.value / _totalExpense * 100;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _chartColors[
                                      i % _chartColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              Text(
                                '${percent.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final entries = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'વિગતવાર ખર્ચ વિભાજન',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const Text('કોઈ ખર્ચ ઉપલબ્ધ નથી.')
          else
            ...List.generate(entries.length, (i) {
              final entry = entries[i];
              final fraction = _totalExpense > 0
                  ? (entry.value / _totalExpense).clamp(0.0, 1.0)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _chartColors[
                                    i % _chartColors.length]
                                .withValues(alpha: 0.13),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.spa_outlined,
                            color: _chartColors[
                                i % _chartColors.length],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _money(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFEAF0E9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _chartColors[i % _chartColors.length],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(fraction * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'કુલ ખર્ચ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                _money(_totalExpense),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _green,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    final expenses = _filteredExpenses;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ખર્ચની યાદી',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ),
              Text(
                '${expenses.length} records',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('આ પસંદગી માટે કોઈ ખર્ચ મળ્યો નથી.'),
              ),
            )
          else
            ...expenses.map((expense) {
              final category = _categoryName(expense);
              final amount = _expenseAmount(expense);
              final farmId = _expenseFarmId(expense);
              final cycle = _cycleForId(_cycleId(expense));

              final cycleFarmId = _toInt(cycle?['_farmId']);
              final farmLabel = _farmName(farmId ?? cycleFarmId);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8EEE7),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: _green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$farmLabel · ${_cropName(cycle)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _date(expense['expenseDate']),
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _money(amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final stroke = size.shortestSide * 0.18;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double startAngle = -1.57079632679;

    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 6.28318530718;

      paint.color = colors[i % colors.length];

      canvas.drawArc(
        rect.deflate(stroke / 2),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
