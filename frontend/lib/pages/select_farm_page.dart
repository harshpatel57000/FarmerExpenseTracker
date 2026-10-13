import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'crop_cycle_page.dart';
import 'farm_expense_page.dart';

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

  // Safely read a value when the backend uses different field names.
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
        getValue(map, ['name', 'regionName', 'farmName', 'villageName']),
        fallback: fallback,
      );
    }

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  // Fetch actual farms and regions from Spring Boot.
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

        // Some APIs return the region object inside each farm.
        if (rawRegion is Map) {
          regionName = getText(
            Map<String, dynamic>.from(rawRegion),
            fallback: '',
          );
        }

        // Other APIs return only regionId, so match it to the region list.
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
          'regionName':
              regionName.isEmpty ? 'વિસ્તાર ઉપલબ્ધ નથી' : regionName,
          'area': areaValue == null ? 'ઉપલબ્ધ નથી' : '$areaValue એકર',
          'currentCrop': 'પાક પસંદ કરો',
        });
      }

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

  void openCropCycle(Map<String, dynamic> farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropCyclePage(
          regionName: farm['regionName'].toString(),
          farmName: farm['farmName'].toString(),
          farmId: farm['id'] as int,
        ),
      ),
    );
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
      appBar: AppBar(
        title: const Text('ખેતર પસંદ કરો'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'ફરીથી લોડ કરો',
            onPressed: isLoading ? null : loadFarmData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadFarmData,
                icon: const Icon(Icons.refresh),
                label: const Text('ફરી પ્રયાસ કરો'),
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
              Icon(
                Icons.agriculture_outlined,
                size: 65,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 12),
              const Text(
                'કોઈ ખેતર મળ્યું નથી',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'પહેલા વિસ્તાર પસંદ કરીને ખેતર ઉમેરો.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: loadFarmData,
                child: const Text('ફરીથી લોડ કરો'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadFarmData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRegionHeader(),
          const SizedBox(height: 25),
          const Text(
            'તમારા ખેતર',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${farms.length} ખેતર ઉપલબ્ધ છે',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          ...farms.map(
            (farm) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildFarmCard(farm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionHeader() {
    final uniqueRegionNames = farms
        .map((farm) => farm['regionName'].toString())
        .toSet();

    final regionText = uniqueRegionNames.length == 1
        ? uniqueRegionNames.first
        : '${uniqueRegionNames.length} વિસ્તાર';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.green.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'વિસ્તાર',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  regionText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'તમારા નોંધાયેલા ખેતર',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.agriculture_outlined,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm['farmName'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'વિસ્તાર: ${farm['regionName']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'જમીન: ${farm['area']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.grass_outlined,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'ચાલુ પાક: ${farm['currentCrop']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Farm ID: ${farm['id']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildCropCycleButton(farm),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => openFarmExpense(farm),
                icon: const Icon(Icons.add_card_outlined),
                label: const Text(
                  'ખેતરનો ખર્ચ ઉમેરો',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropCycleButton(Map<String, dynamic> farm) {
    return InkWell(
      onTap: () => openCropCycle(farm),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grass,
              size: 22,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 3),
            Text(
              'પાક સાયકલ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
