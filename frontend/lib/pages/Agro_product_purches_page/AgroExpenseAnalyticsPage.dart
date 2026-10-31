
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AgroExpenseAnalyticsPage extends StatefulWidget {
  final int userId;
  final Future<void> Function(Map<String, dynamic>) onEdit;
  final Future<void> Function(Map<String, dynamic>) onDelete;

  const AgroExpenseAnalyticsPage({
    super.key,
    required this.userId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AgroExpenseAnalyticsPage> createState() =>
      _AgroExpenseAnalyticsPageState();
}

class _AgroExpenseAnalyticsPageState
    extends State<AgroExpenseAnalyticsPage> {
  bool _isLoading = false;
  int? _selectedYear;

  List<Map<String, dynamic>> _expenses = [];

  static const List<Color> _colors = [
    Color(0xFF2E7D32),
    Color(0xFFFF9800),
    Color(0xFF1976D2),
    Color(0xFF8E24AA),
    Color(0xFFD32F2F),
    Color(0xFF00897B),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFFC0CA33),
    Color(0xFF3949AB),
    Color(0xFFEC407A),
    Color(0xFF5C6BC0),
    Color(0xFF9C27B0),
    Color(0xFF795548),
  ];

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _amount(Map<String, dynamic> item) =>
      _number(item['totalAmount']);

  String _productName(Map<String, dynamic> item) {
    final name = item['productName']?.toString().trim() ?? '';
    return name.isEmpty ? 'અન્ય ખર્ચ' : name;
  }

  DateTime? _date(Map<String, dynamic> item) {
    return DateTime.tryParse(item['purchaseDate']?.toString() ?? '');
  }

  double _quantityValue(dynamic value) {
    if (value is Map) return _number(value['value']);
    return _number(value);
  }

  String _quantityUnit(dynamic value) {
    if (value is Map) return value['unit']?.toString() ?? '';
    return '';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'તારીખ ઉપલબ્ધ નથી';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
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
        final dateA = _date(a) ?? DateTime(2000);
        final dateB = _date(b) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        _expenses = items;

        if (_selectedYear != null &&
            !_availableYears.contains(_selectedYear)) {
          _selectedYear = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ખર્ચ લોડ થઈ શક્યો નથી')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<int> get _availableYears {
    final years = _expenses
        .map(_date)
        .whereType<DateTime>()
        .map((date) => date.year)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return years;
  }

  List<Map<String, dynamic>> get _visibleExpenses {
    if (_selectedYear == null) return _expenses;

    return _expenses.where((item) {
      return _date(item)?.year == _selectedYear;
    }).toList();
  }

  Map<String, double> get _productTotals {
    final totals = <String, double>{};

    for (final item in _visibleExpenses) {
      final product = _productName(item);
      totals.update(
        product,
        (old) => old + _amount(item),
        ifAbsent: () => _amount(item),
      );
    }

    return totals;
  }

  double get _grandTotal {
    return _visibleExpenses.fold<double>(
      0,
      (sum, item) => sum + _amount(item),
    );
  }

  Color _productColor(String product, List<String> products) {
    return _colors[products.indexOf(product) % _colors.length];
  }

  Widget _buildDonutChart(Map<String, double> totals) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty || _grandTotal <= 0) {
      return const SizedBox(
        height: 230,
        child: Center(
          child: Text(
            'આ વર્ષ માટે ખર્ચની માહિતી નથી',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final products = entries.map((entry) => entry.key).toList();

    return SizedBox(
      height: 245,
      child: CustomPaint(
        painter: _DonutPainter(
          values: entries.map((entry) => entry.value).toList(),
          colors: products.map((p) => _productColor(p, products)).toList(),
        ),
        child: Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'કુલ ખર્ચ',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FittedBox(
                    child: Text(
                      '₹${_grandTotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductLegend(Map<String, double> totals) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final products = entries.map((entry) => entry.key).toList();

    if (entries.isEmpty) {
      return const Text('ખર્ચની માહિતી ઉપલબ્ધ નથી');
    }

    return Column(
      children: [
        for (final entry in entries)
          Card(
            color: Colors.white.withValues(alpha: 0.60),
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 9,
                backgroundColor: _productColor(entry.key, products),
              ),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${(_grandTotal > 0 ? entry.value / _grandTotal * 100 : 0).toStringAsFixed(1)}% ખર્ચ',
              ),
              trailing: Text(
                '₹${entry.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.white.withValues(alpha: 0.60),
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
                    _productName(item),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('તારીખ: ${_formatDate(item['purchaseDate'])}'),
                  Text(
                    'જથ્થો: ${_quantityValue(item['quantity'])} '
                    '${_quantityUnit(item['quantity'])}',
                  ),
                  Text(
                    'કુલ: ₹${_amount(item).toStringAsFixed(2)}',
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
                  onPressed: () async {
                    await widget.onEdit(item);
                    if (mounted) await loadExpenses();
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  tooltip: 'કાઢી નાખો',
                  onPressed: () async {
                    await widget.onDelete(item);
                    if (mounted) await loadExpenses();
                  },
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
    final totals = _productTotals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ખર્ચનો ચાર્ટ'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'ફરીથી લોડ કરો',
            onPressed: loadExpenses,
            icon: const Icon(Icons.refresh),
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
            color: Colors.white.withValues(alpha: 0.12),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadExpenses,
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Card(
                          color: Colors.white.withValues(alpha: 0.58),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'કયું વર્ષ જોવા માંગો છો?',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int?>(
                                  value: _selectedYear,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        Colors.white.withValues(alpha: 0.45),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('બધા વર્ષ'),
                                    ),
                                    ..._availableYears.map(
                                      (year) => DropdownMenuItem<int?>(
                                        value: year,
                                        child: Text(year.toString()),
                                      ),
                                    ),
                                  ],
                                  onChanged: (year) {
                                    setState(() => _selectedYear = year);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          color: Colors.white.withValues(alpha: 0.48),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  _selectedYear == null
                                      ? 'બધા વર્ષના ઉત્પાદન પ્રમાણે ખર્ચ'
                                      : '$_selectedYear ના ઉત્પાદન પ્રમાણે ખર્ચ',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDonutChart(totals),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ઉત્પાદન પ્રમાણે ખર્ચ',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildProductLegend(totals),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.green.withValues(alpha: 0.76),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedYear == null
                                      ? 'બધા વર્ષનો કુલ ખર્ચ'
                                      : '$_selectedYear નો કુલ ખર્ચ',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${_grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'કુલ ખરીદી: ${_visibleExpenses.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _selectedYear == null
                              ? 'જૂના ખર્ચની યાદી'
                              : '$_selectedYear ના જૂના ખર્ચ',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 8),
                            ],
                          ),
                        ),
                        if (_visibleExpenses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('આ વર્ષમાં કોઈ ખર્ચ નોંધાયો નથી'),
                            ),
                          )
                        else
                          ..._visibleExpenses.map(_buildHistoryCard),
                      ],
                    ),
                  ),
          ),
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

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.34
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] / total * 2 * math.pi;

      paint.color = colors[i % colors.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
