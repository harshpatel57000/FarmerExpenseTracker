import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'services/api_service.dart';

/// Expense analytics page:
/// - Overview: donut chart + category legend
/// - Detailed: category totals + percentage bars
/// - Expense List: individual expense records
///
/// Keeps the existing ApiService methods and backend field-name fallbacks.
/// Background asset used by this screen: assets/images/farm_day.jpg
class ExpenseViewPage extends StatefulWidget {
  const ExpenseViewPage({super.key});

  @override
  State<ExpenseViewPage> createState() => _ExpenseViewPageState();
}

enum _ExpenseTab { overview, detailed, list }

enum _CropPeriod { current, history }

class _ExpenseViewPageState extends State<ExpenseViewPage> {
  static const Color _green = Color(0xFF086747);
  static const Color _deepGreen = Color(0xFF064E38);
  static const Color _pageBg = Color(0xFFF4F7F5);
  static const Color _muted = Color(0xFF718078);

  static const List<Color> _categoryColors = [
    Color.fromARGB(255, 3, 103, 70),
    Color.fromARGB(255, 221, 76, 9),
    Color.fromARGB(255, 41, 106, 218),
    Color.fromARGB(255, 134, 74, 224),
    Color.fromARGB(255, 10, 152, 154),
    Color.fromARGB(255, 237, 163, 26),
    Color.fromARGB(255, 190, 18, 98),

  ];

  static const List<IconData> _categoryIcons = [
    Icons.agriculture_rounded,
    Icons.groups_rounded,
    Icons.grass_rounded,
    Icons.water_drop_rounded,
    Icons.local_shipping_rounded,
    Icons.more_horiz_rounded,
  ];

  static const List<String> _categoryNames = [
    'ખેતર ખર્ચ',
    'મજૂરી',
    'બીજ / ખાતર',
    'પાણી / સિંચાઈ',
    'મશીનરી',
    'અન્ય ખર્ચ',
  ];

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _allExpenses = [];
  final Map<int, List<Map<String, dynamic>>> _cropCyclesByFarm = {};

  int? _selectedFarmId; // null means All Farms
  _CropPeriod _cropPeriod = _CropPeriod.current;
  int? _selectedCropCycleId;
  _ExpenseTab _selectedTab = _ExpenseTab.overview;
  bool _showFilterPage = true;
  String _searchText = '';
  String _selectedCategoryFilter = 'બધી કેટેગરી';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
  }

  String _string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty || result.toLowerCase() == 'null' ? fallback : result;
  }

  dynamic _first(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) return map[key];
    }
    return null;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getFarms(),
        ApiService.getFarmExpenses(),
        ApiService.getRegions(),    

      ]);

      final farms = results[0]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final expenses = results[1]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final regions = results[2]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final cyclesMap = <int, List<Map<String, dynamic>>>{};
      for (final farm in farms) {
        final farmId = _farmId(farm);
        if (farmId == null) continue;
        try {
          final cycles = await ApiService.getCropCyclesByFarm(farmId);
          cyclesMap[farmId] = cycles
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } catch (_) {
          // Keep the rest of the page usable if one farm's crop cycles fail.
          cyclesMap[farmId] = [];
        }
      }

      if (!mounted) return;
      setState(() {
        _farms = farms;
        _allExpenses = expenses;
        _regions = regions;
        _cropCyclesByFarm
          ..clear()
          ..addAll(cyclesMap);
        if (_selectedFarmId != null &&
            !_farms.any((farm) => _farmId(farm) == _selectedFarmId)) {
          _selectedFarmId = null;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  int? _farmId(Map<String, dynamic> farm) =>
      _toInt(_first(farm, ['id', 'farmId', 'farm_id']));

  int? _expenseFarmId(Map<String, dynamic> expense) =>
      _toInt(_first(expense, ['farmId', 'farm_id', 'farmID']));

  int? _cropCycleId(Map<String, dynamic> expense) => _toInt(
        _first(expense, [
          'cropCycleId',
          'cropcycleId',
          'crop_cycle_id',
          'cropcycle_id',
          'cropCycle',
        ]),
      );

  int? _cycleId(Map<String, dynamic> cycle) =>
      _toInt(_first(cycle, ['id', 'cropCycleId', 'crop_cycle_id']));

  String _farmNameById(int? id) {
    if (id == null) return 'ખેતર અજ્ઞાત';
    for (final farm in _farms) {
      if (_farmId(farm) == id) {
        return _string(_first(farm, ['name', 'farmName', 'farm_name']),
            'ખેતર $id');
      }
    }
    return 'ખેતર $id';
  }

  /// Reads the region name from common API response shapes.
  /// Supported examples:
  /// {"regionName": "North"}
  /// {"region": {"name": "North"}}
  /// {"regionDetails": {"regionName": "North"}}
  String _regionNameForFarm(Map<String, dynamic> farm) {
  // First, check whether the farm response already contains the region name.
  final directName = _string(
    _first(farm, [
      'regionName',
      'region_name',
      'region_name_text',
    ]),
  );

  if (directName.isNotEmpty) return directName;

  // Check nested region objects.
  for (final key in ['region', 'regionDetails', 'region_details']) {
    final nestedRegion = _map(farm[key]);

    final nestedName = _string(
      _first(nestedRegion, [
        'name',
        'regionName',
        'region_name',
      ]),
    );

    if (nestedName.isNotEmpty) return nestedName;
  }

  // Find the region by matching its ID with the farm's region ID.
  final regionId = _toInt(
    _first(farm, ['regionId', 'region_id']),
  );

  if (regionId == null) return 'વિસ્તાર અજ્ઞાત';

  for (final region in _regions) {
    final currentRegionId = _toInt(
      _first(region, ['id', 'regionId', 'region_id']),
    );

    if (currentRegionId == regionId) {
      final name = _string(
        _first(region, [
          'name',
          'regionName',
          'region_name',
          'regionNameGujarati',
        ]),
      );

      if (name.isNotEmpty) return name;
    }
  }

  return 'વિસ્તાર અજ્ઞાત';
}

  String _farmDropdownLabel(Map<String, dynamic> farm) {
    final farmId = _farmId(farm);
    final farmName = _string(
      _first(farm, ['name', 'farmName', 'farm_name']),
      farmId == null ? 'ખેતર અજ્ઞાત' : 'ખેતર $farmId',
    );
    final regionName = _regionNameForFarm(farm);
    return '$farmName - $regionName';
  }

  String _cropName(Map<String, dynamic> cycle) =>
      _string(_first(cycle, ['cropName', 'crop_name', 'name']), 'પાક');

  String _expenseName(Map<String, dynamic> expense) => _string(
        _first(expense, ['expenseName', 'expense_name', 'name', 'description']),
        'ખર્ચ',
      );

  DateTime? _expenseDate(Map<String, dynamic> expense) {
    final value = _first(expense, ['expenseDate', 'expense_date', 'date']);
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  double _expenseTotal(Map<String, dynamic> expense) {
    // totalCost is the backend's authoritative total when it is present.
    final total = _first(expense, ['totalCost', 'total_cost', 'totalAmount']);
    if (total != null) return _toDouble(total);

    // Fallback for older records or payloads without totalCost.
    return _toDouble(_first(expense, [
          'totalExpenseOfWorkers',
          'total_expense_of_workers',
        ])) +
        _toDouble(_first(expense, ['totalAgroExpense', 'total_agro_expense'])) +
        _toDouble(_first(expense, ['extraCost', 'extra_cost']));
  }

  List<Map<String, dynamic>> get _visibleExpenses {
    var result = _allExpenses.where((expense) {
      if (_selectedFarmId != null &&
          _expenseFarmId(expense) != _selectedFarmId) {
        return false;
      }

      final cycleId = _cropCycleId(expense);
      if (_cropPeriod == _CropPeriod.current) {
        // A current-crop expense must be linked to an ACTIVE crop cycle.
        if (cycleId == null) return false;
        final farmId = _expenseFarmId(expense);
        final cycles = farmId == null
            ? <Map<String, dynamic>>[]
            : (_cropCyclesByFarm[farmId] ?? []);
        final activeIds = cycles
            .where((cycle) =>
                _string(_first(cycle, ['status', 'cropStatus', 'crop_status']))
                    .toUpperCase() ==
                'ACTIVE')
            .map(_cycleId)
            .whereType<int>()
            .toSet();
        if (!activeIds.contains(cycleId)) return false;
      } else if (_selectedCropCycleId != null &&
          cycleId != _selectedCropCycleId) {
        return false;
      }
      return true;
    }).toList();

    if (_selectedCropCycleId != null) {
      result = result
          .where((expense) => _cropCycleId(expense) == _selectedCropCycleId)
          .toList();
    }

    final query = _searchText.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((expense) {
        final text = [
          _expenseName(expense),
          _farmNameById(_expenseFarmId(expense)),
          _cropNameForExpense(expense),
          _categoryForExpense(expense),
        ].join(' ').toLowerCase();
        return text.contains(query);
      }).toList();
    }

    if (_selectedCategoryFilter != 'બધી કેટેગરી') {
      result = result
          .where((expense) =>
              _categoryForExpense(expense) == _selectedCategoryFilter)
          .toList();
    }

    result.sort((a, b) {
      final dateA = _expenseDate(a) ?? DateTime(1970);
      final dateB = _expenseDate(b) ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });
    return result;
  }

  String _cropNameForExpense(Map<String, dynamic> expense) {
    final id = _cropCycleId(expense);
    if (id == null) return 'પાક પસંદ નથી';
    for (final cycles in _cropCyclesByFarm.values) {
      for (final cycle in cycles) {
        if (_cycleId(cycle) == id) return _cropName(cycle);
      }
    }
    return 'પાક $id';
  }

  int _categoryIndexForExpense(Map<String, dynamic> expense) {
    final type = _string(_first(expense, [
      'expenseType',
      'expense_type',
      'category',
      'expenseCategory',
      'expense_category',
    ])).toLowerCase();
    final name = _expenseName(expense).toLowerCase();
    final text = '$type $name';

    if (text.contains('labour') ||
        text.contains('labor') ||
        text.contains('worker') ||
        text.contains('મજૂર') ||
        text.contains('મજૂરી')) {
      return 1;
    }
    if (text.contains('seed') ||
        text.contains('fertil') ||
        text.contains('pesticide') ||
        text.contains('agro') ||
        text.contains('બીજ') ||
        text.contains('ખાતર')) {
      return 2;
    }
    if (text.contains('water') ||
        text.contains('irrigat') ||
        text.contains('પાણી') ||
        text.contains('સિંચાઈ')) {
      return 3;
    }
    if (text.contains('machine') ||
        text.contains('tractor') ||
        text.contains('transport') ||
        text.contains('મશીન') ||
        text.contains('ટ્રેક્ટર')) {
      return 4;
    }
    if (text.contains('other') ||
        text.contains('અન્ય') ||
        text.contains('misc')) {
      return 5;
    }
    return 0;
  }

  String _categoryForExpense(Map<String, dynamic> expense) =>
      _categoryNames[_categoryIndexForExpense(expense)];

  List<double> get _categoryTotals {
    final totals = List<double>.filled(_categoryNames.length, 0);
    for (final expense in _visibleExpenses) {
      totals[_categoryIndexForExpense(expense)] += _expenseTotal(expense);
    }
    return totals;
  }

  double get _grandTotal =>
      _visibleExpenses.fold(0, (sum, expense) => sum + _expenseTotal(expense));

  String _money(num amount) {
    final value = amount.round().toString();
    final chars = value.split('');
    final out = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      out.write(chars[i]);
      final remaining = chars.length - i - 1;
      if (remaining > 0 &&
          (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0))) {
        out.write(',');
      }
    }
    return '₹ ${out.toString()}';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'તારીખ ઉપલબ્ધ નથી';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, dynamic>> get _availableCycles {
    final farms = _selectedFarmId == null
        ? _cropCyclesByFarm.values.expand((items) => items).toList()
        : (_cropCyclesByFarm[_selectedFarmId] ?? []);
    if (_cropPeriod == _CropPeriod.current) {
      return farms
          .where((cycle) =>
              _string(_first(cycle, ['status', 'cropStatus', 'crop_status']))
                  .toUpperCase() ==
              'ACTIVE')
          .toList();
    }
    return farms;
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _showFilterPage
        ? 'ખર્ચ જુઓ'
        : _selectedTab == _ExpenseTab.overview
            ? 'ખર્ચ જુઓ'
            : _selectedTab == _ExpenseTab.detailed
                ? 'વિગતવાર ખર્ચ'
                : 'ખર્ચ યાદી';

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _showFilterPage
            ? null
            : IconButton(
                tooltip: 'પાછા જાઓ',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (_selectedTab == _ExpenseTab.detailed) {
                    setState(() => _selectedTab = _ExpenseTab.overview);
                  } else if (_selectedTab == _ExpenseTab.list) {
                    setState(() => _selectedTab = _ExpenseTab.detailed);
                  } else {
                    setState(() => _showFilterPage = true);
                  }
                },
              ),
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pageTitle,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Text('Expense View',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error != null
              ? _errorView()
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/farm_day.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.76),
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      color: _green,
                      child: _showFilterPage
                          ? ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 14, 24),
                              children: [
                                _filterCard(),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () => setState(() {
                                      _showFilterPage = false;
                                      _selectedTab = _ExpenseTab.overview;
                                    }),
                                    icon: const Icon(Icons.arrow_forward_rounded),
                                    label: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 13),
                                      child: Text('આગળ વધો  →',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 14, 24),
                              children: [
                                _selectionSummary(),
                                const SizedBox(height: 12),
                                _tabSelector(),
                                const SizedBox(height: 12),
                                if (_selectedTab == _ExpenseTab.overview)
                                  _overviewView()
                                else if (_selectedTab == _ExpenseTab.detailed)
                                  _detailedView()
                                else
                                  _expenseListView(),
                              ],
                            ),
                    ),
                  ),
                ),
    );
  }

  Widget _selectionSummary() {
    final farmLabel = _selectedFarmId == null
        ? 'બધાં ખેતરો (All Farms)'
        : _farmNameById(_selectedFarmId);
    final periodLabel = _cropPeriod == _CropPeriod.current
        ? 'ચાલુ પાક (Current Crop)'
        : 'પૂર્ણ પાક (Complete History)';
    return _card(
      child: Row(
        children: [
          const Icon(Icons.agriculture_rounded, color: _green, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farmLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(periodLabel,
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showFilterPage = true),
            child: const Text('બદલો'),
          ),
        ],
      ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: _muted),
              const SizedBox(height: 12),
              const Text('ખર્ચ લોડ થઈ શક્યા નથી',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('ફરી પ્રયાસ કરો'),
                style: FilledButton.styleFrom(backgroundColor: _green),
              ),
            ],
          ),
        ),
      );

  Widget _filterCard() {
    final cycles = _availableCycles;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. ખેતર પસંદ કરો (Select Farm)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            value: _selectedFarmId,
            isExpanded: true,
            decoration: _inputDecoration('ખેતર પસંદ કરો'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('બધાં ખેતરો (All Farms)'),
              ),
              ..._farms.map((farm) => DropdownMenuItem<int?>(
                    value: _farmId(farm),
                    child: Text(
                      _farmDropdownLabel(farm),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFarmId = value;
                _selectedCropCycleId = null;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('2. પાક સમયગાળો (Crop Period)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _periodButton(
                  'ચાલુ પાક',
                  'Current Crop',
                  _cropPeriod == _CropPeriod.current,
                  () => setState(() {
                    _cropPeriod = _CropPeriod.current;
                    _selectedCropCycleId = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _periodButton(
                  'પૂર્ણ પાક',
                  'Complete History',
                  _cropPeriod == _CropPeriod.history,
                  () => setState(() {
                    _cropPeriod = _CropPeriod.history;
                    _selectedCropCycleId = null;
                  }),
                ),
              ),
            ],
          ),
          if (cycles.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              value: _selectedCropCycleId,
              isExpanded: true,
              decoration: _inputDecoration('બધા પાક / Select crop'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('બધા પાક (All crops)'),
                ),
                ...cycles.map((cycle) => DropdownMenuItem<int?>(
                      value: _cycleId(cycle),
                      child: Text(_cropName(cycle),
                          overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (value) =>
                  setState(() => _selectedCropCycleId = value),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: _green, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('કુલ ખર્ચ (Total Expense)',
                          style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(_money(_grandTotal),
                          style: const TextStyle(
                              color: _deepGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('${_visibleExpenses.length}',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: _green)),
                      const Text('ખર્ચ', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7FAF8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE8E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE8E0))),
      );

  Widget _periodButton(
      String gujarati, String english, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? _green : const Color(0xFFF0F4F1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _green : const Color(0xFFE1E9E3)),
        ),
        child: Column(
          children: [
            Text(gujarati,
                style: TextStyle(
                    color: selected ? Colors.white : _deepGreen,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(english,
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white70 : _muted)),
          ],
        ),
      ),
    );
  }

  Widget _tabSelector() {
    final labels = [
      ('ખર્ચ દર્શન', Icons.donut_large_rounded, _ExpenseTab.overview),
      ('વિગતવાર ખર્ચ', Icons.bar_chart_rounded, _ExpenseTab.detailed),
      ('ખર્ચ યાદી', Icons.receipt_long_rounded, _ExpenseTab.list),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 9,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: labels.map((item) {
          final selected = _selectedTab == item.$3;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => setState(() => _selectedTab = item.$3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
                decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  children: [
                    Icon(item.$2,
                        size: 19,
                        color: selected ? Colors.white : _muted),
                    const SizedBox(height: 4),
                    Text(item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : _muted)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _overviewView() {
    final totals = _categoryTotals;
    final nonZero = List.generate(_categoryNames.length, (i) => i)
        .where((i) => totals[i] > 0)
        .toList();
    return Column(
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ખર્ચનું વિભાજન',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Expense Overview',
                  style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 12),
              if (_grandTotal <= 0)
                _emptyState('હજુ કોઈ ખર્ચ નથી', 'ખર્ચ ઉમેર્યા પછી ચાર્ટ દેખાશે.')
              else
                LayoutBuilder(builder: (context, constraints) {
                  final compact = constraints.maxWidth < 370;
                  if (compact) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 225,
                          child: _donutChart(totals, _grandTotal),
                        ),
                        const SizedBox(height: 10),
                        _categoryLegend(nonZero, totals),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 230,
                          child: _donutChart(totals, _grandTotal),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(flex: 5, child: _categoryLegend(nonZero, totals)),
                    ],
                  );
                }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: _green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'વિગતવાર જોવા માટે “વિગતવાર” પસંદ કરો.',
                        style: TextStyle(
                            fontSize: 12,
                            color: _deepGreen,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _donutChart(List<double> totals, double grandTotal) {
    return CustomPaint(
      painter: _DonutPainter(
        values: totals,
        colors: _categoryColors,
        backgroundColor: const Color(0xFFEAF0EC),
      ),
      child: Center(
        child: Container(
          width: 116,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('કુલ ખર્ચ',
                  style: TextStyle(fontSize: 11, color: _muted)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _money(grandTotal),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _deepGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryLegend(List<int> indices, List<double> totals) {
    if (indices.isEmpty) {
      return const Text('કોઈ કેટેગરી ખર્ચ નથી',
          style: TextStyle(color: _muted));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: indices.map((i) {
        final percentage =
            _grandTotal == 0 ? 0 : (totals[i] / _grandTotal * 100);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                    color: _categoryColors[i].withOpacity(.13),
                    shape: BoxShape.circle),
                child: Icon(_categoryIcons[i],
                    color: _categoryColors[i], size: 16),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_categoryNames[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(_money(totals[i]),
                        style: const TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Text('${percentage.round()}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _categoryColors[i])),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _detailedView() {
    final totals = _categoryTotals;
    final indices = List.generate(_categoryNames.length, (i) => i)
      ..sort((a, b) => totals[b].compareTo(totals[a]));
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('વિગતવાર ખર્ચ વિભાજન',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text('Detailed Breakdown',
              style: TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 14),
          if (_grandTotal <= 0)
            _emptyState('ખર્ચ ઉપલબ્ધ નથી', 'પસંદ કરેલા સમયગાળામાં ખર્ચ નથી.')
          else
            ...indices.where((i) => totals[i] > 0).map((i) {
              final percent = totals[i] / _grandTotal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _categoryColors[i].withOpacity(.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_categoryIcons[i],
                              color: _categoryColors[i], size: 23),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_categoryNames[i],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_money(totals[i]),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 13)),
                            Text('${(percent * 100).round()}%',
                                style: TextStyle(
                                    color: _categoryColors[i],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE9EFEB),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_categoryColors[i]),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const Divider(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('કુલ ખર્ચ',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              ),
              Text(_money(_grandTotal),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expenseListView() {
    return Column(
      children: [
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _searchText = value),
                      decoration: InputDecoration(
                        hintText: 'ખર્ચ, પાક, ખેતર શોધો...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF5F8F6),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      tooltip: 'Filter category',
                      icon: const Icon(Icons.filter_list_rounded, color: _green),
                      onSelected: (value) =>
                          setState(() => _selectedCategoryFilter = value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'બધી કેટેગરી',
                            child: Text('બધી કેટેગરી')),
                        ..._categoryNames.map((name) => PopupMenuItem(
                            value: name, child: Text(name))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _smallSummary(
                        'કુલ ખર્ચ', _money(_grandTotal), Icons.payments_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _smallSummary('કુલ નોંધ', '${_visibleExpenses.length}',
                        Icons.receipt_long_rounded),
                  ),
                ],
              ),
              if (_selectedCategoryFilter != 'બધી કેટેગરી') ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _selectedCategoryFilter = 'બધી કેટેગરી'),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text('ફિલ્ટર: $_selectedCategoryFilter દૂર કરો'),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _recentExpensesCard(),
      ],
    );
  }

  Widget _smallSummary(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 20),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 10, color: _muted)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentExpensesCard({int? limit}) {
    final expenses = limit == null
        ? _visibleExpenses
        : _visibleExpenses.take(limit).toList();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('ખર્ચ યાદી (Expense List)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              if (limit != null)
                TextButton(
                  onPressed: () => setState(() => _selectedTab = _ExpenseTab.list),
                  child: const Text('બધું જુઓ'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (expenses.isEmpty)
            _emptyState('ખર્ચ મળ્યો નથી', 'ફિલ્ટર બદલો અથવા નવો ખર્ચ ઉમેરો.')
          else
            ...expenses.map(_expenseTile),
        ],
      ),
    );
  }

  Widget _expenseTile(Map<String, dynamic> expense) {
    final categoryIndex = _categoryIndexForExpense(expense);
    final farmId = _expenseFarmId(expense);
    final date = _expenseDate(expense);
    final amount = _expenseTotal(expense);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEDF1EE)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _categoryColors[categoryIndex].withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcons[categoryIndex],
                color: _categoryColors[categoryIndex], size: 23),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_expenseName(expense),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_dateLabel(date),
                    style: const TextStyle(color: _muted, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  '${_farmNameById(farmId)} • ${_cropNameForExpense(expense)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF527264), fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(_categoryNames[categoryIndex],
                    style: TextStyle(
                        color: _categoryColors[categoryIndex],
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_money(amount),
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                    color: Color(0xFFEAF5EF), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded,
                    color: _green, size: 28),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE9EFEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.backgroundColor,
  });

  final List<double> values;
  final List<Color> colors;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final stroke = math.max(19.0, side * .105);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side * .78,
      height: side * .78,
    );
    final center = rect.center;
    final radius = rect.width / 2;
    final ringRect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, paint..color = backgroundColor);

    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(ringRect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.backgroundColor != backgroundColor;
}
