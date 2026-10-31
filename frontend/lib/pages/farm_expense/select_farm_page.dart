
import 'package:flutter/material.dart';
import 'package:frontend/pages/farm_expense/farm_expense_page.dart';

import '../services/api_service.dart';
import '../crop_cycle_page.dart';

const Color darkGreen = Color(0xFF14532D);
const Color mediumGreen = Color(0xFF16803C);
const Color lightGreen = Color(0xFFE6F5E9);
const Color pageBackground = Color(0xFFF7FAF7);

class SelectFarmPage extends StatefulWidget {
  const SelectFarmPage({super.key});

  @override
  State<SelectFarmPage> createState() => _SelectFarmPageState();
}

class _SelectFarmPageState extends State<SelectFarmPage> {
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> regions = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadFarmData();
  }

  dynamic getValue(
    Map<String, dynamic> data,
    List<String> possibleKeys,
  ) {
    for (final key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key];
      }
    }
    return null;
  }

  int? getId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return getId(getValue(map, ['id', 'regionId', 'farmId']));
    }

    return null;
  }

  String getText(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return getText(
        getValue(
          map,
          ['name', 'regionName', 'farmName', 'villageName'],
        ),
        fallback: fallback,
      );
    }

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Future<String> getActiveCropName(int farmId) async {
    try {
      final response = await ApiService.getCropCyclesByFarm(farmId);

      for (final item in response.whereType<Map>()) {
        final crop = Map<String, dynamic>.from(item);
        final status =
            (crop['status'] ?? 'ACTIVE').toString().toUpperCase();

        if (status == 'ACTIVE') {
          return getText(
            crop['cropName'],
            fallback: 'પાક પસંદ કરો',
          );
        }
      }
    } catch (e) {
      debugPrint('Could not load active crop for farm $farmId: $e');
    }

    return 'પાક પસંદ કરો';
  }

  Future<void> loadFarmData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getFarms(),
        ApiService.getRegions(),
      ]);

      final farmResponse = results[0];
      final regionResponse = results[1];

      final loadedRegions = regionResponse
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final loadedFarms = <Map<String, dynamic>>[];

      for (final item in farmResponse.whereType<Map>()) {
        final farm = Map<String, dynamic>.from(item);

        final farmId = getId(getValue(farm, ['id', 'farmId']));
        if (farmId == null) continue;

        final rawRegion = getValue(farm, ['region', 'regionDTO']);

        final regionId = getId(
          getValue(farm, ['regionId']) ?? rawRegion,
        );

        String regionName = '';

        if (rawRegion is Map) {
          regionName = getText(
            Map<String, dynamic>.from(rawRegion),
          );
        }

        if (regionName.isEmpty && regionId != null) {
          for (final region in loadedRegions) {
            final id = getId(getValue(region, ['id', 'regionId']));

            if (id == regionId) {
              regionName = getText(
                getValue(region, ['name', 'regionName']),
                fallback: 'વિસ્તાર #$regionId',
              );
              break;
            }
          }
        }

        final farmName = getText(
          getValue(farm, ['name', 'farmName']),
          fallback: 'ખેતર #$farmId',
        );

        final areaValue = getValue(farm, ['area', 'farmArea']);

        loadedFarms.add({
          'id': farmId,
          'farmName': farmName,
          'regionId': regionId,
          'regionName': regionName.isEmpty
              ? 'વિસ્તાર ઉપલબ્ધ નથી'
              : regionName,
          'area': areaValue == null ? 'ઉપલબ્ધ નથી' : '$areaValue એકર',
          'currentCrop': 'પાક પસંદ કરો',
        });
      }

      await Future.wait(
        loadedFarms.map((farm) async {
          farm['currentCrop'] =
              await getActiveCropName(farm['id'] as int);
        }),
      );

      if (!mounted) return;

      setState(() {
        farms = loadedFarms;
        regions = loadedRegions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'ખેતરની માહિતી લાવવામાં ભૂલ આવી.\n$e';
      });
    }
  }

  Future<void> openCropCycle(Map<String, dynamic> farm) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CropCyclePage(
          regionName: farm['regionName'].toString(),
          farmName: farm['farmName'].toString(),
          farmId: farm['id'] as int,
        ),
      ),
    );

    if (!mounted) return;

    final updatedCrop = await getActiveCropName(farm['id'] as int);

    if (!mounted) return;

    setState(() {
      farm['currentCrop'] =
          result != null && result.trim().isNotEmpty
              ? result
              : updatedCrop;
    });
  }

  void openFarmExpense(Map<String, dynamic> farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmExpensePage(
          regionName: farm['regionName'].toString(),
          farmName: farm['farmName'].toString(),
          farmId: farm['id'] as int,
          cropType: farm['currentCrop'].toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCEBE1),
        foregroundColor: darkGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ખેતર પસંદ કરો',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'ફરીથી લોડ કરો',
            onPressed: isLoading ? null : loadFarmData,
            icon: const Icon(Icons.refresh, size: 28),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: darkGreen),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadFarmData,
                icon: const Icon(Icons.refresh),
                label: const Text('ફરી પ્રયાસ કરો'),
                style: _darkButtonStyle(),
              ),
            ],
          ),
        ),
      );
    }

    if (farms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.agriculture_outlined,
                size: 65,
                color: mediumGreen,
              ),
              const SizedBox(height: 12),
              const Text(
                'કોઈ ખેતર મળ્યું નથી',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'પહેલા વિસ્તાર પસંદ કરીને ખેતર ઉમેરો.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadFarmData,
                style: _darkButtonStyle(),
                child: const Text('ફરીથી લોડ કરો'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: darkGreen,
      onRefresh: loadFarmData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          _buildRegionHeader(),
          const SizedBox(height: 25),
          const Text(
            'તમારા ખેતર',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${farms.length} ખેતર ઉપલબ્ધ છે',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF526357),
            ),
          ),
          const SizedBox(height: 18),
          ...farms.map(
            (farm) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _buildFarmCard(farm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionHeader() {
    final uniqueRegionNames =
        farms.map((farm) => farm['regionName'].toString()).toSet();

    final regionText = uniqueRegionNames.length == 1
        ? uniqueRegionNames.first
        : '${uniqueRegionNames.length} વિસ્તાર';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDF4E3), Color(0xFFF0F9F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF9BD3A7),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: mediumGreen,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'વિસ્તાર',
                  style: TextStyle(
                    fontSize: 15,
                    color: darkGreen.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  regionText,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'તમારા નોંધાયેલા ખેતર',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF526357),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmCard(Map<String, dynamic> farm) {
    final cropName = farm['currentCrop'].toString();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFE0EBE2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.09),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: mediumGreen,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm['farmName'].toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18251C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'વિસ્તાર: ${farm['regionName']}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF34483A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'જમીન: ${farm['area']}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF34483A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        const Text(
                          'ચાલુ પાક: ',
                          style: TextStyle(
                            fontSize: 15,
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cropName,
                          style: const TextStyle(
                            fontSize: 15,
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => openCropCycle(farm),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 66,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF9BCDA5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CropSymbol(
                        cropName: cropName,
                        size: 27,
                        color: darkGreen,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'પાક પસંદ કરો',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),

          // Exactly one expense button per farm card.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => openFarmExpense(farm),
              icon: const Icon(Icons.add_card_rounded, size: 24),
              label: const Text(
                'ખેતરનો ખર્ચ ઉમેરો',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _darkButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: darkGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Crop-specific icon. Paddy is drawn using Flutter Canvas, not an image.
class CropSymbol extends StatelessWidget {
  final String cropName;
  final double size;
  final Color color;

  const CropSymbol({
    super.key,
    required this.cropName,
    this.size = 26,
    this.color = darkGreen,
  });

  @override
  Widget build(BuildContext context) {
    final crop = cropName.trim().toLowerCase();

    if (crop.contains('ડાંગર') ||
        crop.contains('paddy') ||
        crop.contains('rice')) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: PaddyIconPainter(color: color),
        ),
      );
    }

    if (crop.contains('કપાસ') || crop.contains('cotton')) {
      return Icon(
        Icons.filter_vintage_rounded,
        size: size,
        color: color,
      );
    }

    if (crop.contains('મગફળી') || crop.contains('peanut')) {
      return Icon(Icons.spa_rounded, size: size, color: color);
    }

    if (crop.contains('મકાઈ') ||
        crop.contains('maize') ||
        crop.contains('corn')) {
      return Icon(Icons.grain_rounded, size: size, color: color);
    }

    if (crop.contains('ઘઉં') || crop.contains('wheat')) {
      return Icon(Icons.grass_rounded, size: size, color: color);
    }

    if (crop.contains('બાજરી') || crop.contains('millet')) {
      return Icon(Icons.grass, size: size, color: color);
    }

    if (crop.contains('તુવેર') ||
        crop.contains('મગ') ||
        crop.contains('ચણા')) {
      return Icon(Icons.eco_rounded, size: size, color: color);
    }

    if (crop == 'પાક પસંદ કરો') {
      return Icon(
        Icons.agriculture_rounded,
        size: size,
        color: color,
      );
    }

    return Icon(Icons.grass_rounded, size: size, color: color);
  }
}

class PaddyIconPainter extends CustomPainter {
  final Color color;

  PaddyIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final center = Path()
      ..moveTo(w * 0.50, h * 0.91)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.53, h * 0.15);

    final left = Path()
      ..moveTo(w * 0.48, h * 0.91)
      ..quadraticBezierTo(w * 0.38, h * 0.52, w * 0.20, h * 0.27);

    final right = Path()
      ..moveTo(w * 0.53, h * 0.91)
      ..quadraticBezierTo(w * 0.68, h * 0.52, w * 0.81, h * 0.30);

    canvas.drawPath(center, paint);
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);

    final leaves = [
      Path()
        ..moveTo(w * 0.48, h * 0.69)
        ..quadraticBezierTo(w * 0.20, h * 0.63, w * 0.12, h * 0.43),
      Path()
        ..moveTo(w * 0.51, h * 0.78)
        ..quadraticBezierTo(w * 0.78, h * 0.72, w * 0.91, h * 0.55),
      Path()
        ..moveTo(w * 0.50, h * 0.84)
        ..quadraticBezierTo(w * 0.30, h * 0.83, w * 0.20, h * 0.73),
    ];

    for (final leaf in leaves) {
      canvas.drawPath(leaf, paint);
    }

    final grains = <Offset>[
      Offset(w * 0.43, h * 0.19),
      Offset(w * 0.54, h * 0.10),
      Offset(w * 0.64, h * 0.17),
      Offset(w * 0.36, h * 0.26),
      Offset(w * 0.47, h * 0.29),
      Offset(w * 0.58, h * 0.25),
      Offset(w * 0.24, h * 0.31),
      Offset(w * 0.17, h * 0.38),
      Offset(w * 0.29, h * 0.39),
      Offset(w * 0.75, h * 0.32),
      Offset(w * 0.85, h * 0.38),
      Offset(w * 0.72, h * 0.42),
    ];

    for (final grain in grains) {
      canvas.save();
      canvas.translate(grain.dx, grain.dy);
      canvas.rotate(-0.45);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: w * 0.12,
          height: h * 0.065,
        ),
        fillPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PaddyIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
