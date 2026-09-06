import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FarmPage extends StatefulWidget {
  final int regionId;
  final String regionName;

  const FarmPage({
    super.key,
    required this.regionId,
    required this.regionName,
  });

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  final TextEditingController farmNameController =
      TextEditingController();

  final TextEditingController areaController =
      TextEditingController();

  List<dynamic> farms = [];

  bool isLoading = false;
  bool loadingFarms = true;

  @override
  void initState() {
    super.initState();
    loadFarms();
  }

  // ============================================================
  // GET FARMS
  // ============================================================

  Future<void> loadFarms() async {
    try {
      final allFarms = await ApiService.getFarms();

      if (!mounted) return;

      final regionFarms = allFarms.where((farm) {
        return int.parse(farm['regionId'].toString()) ==
            widget.regionId;
      }).toList();

      setState(() {
        farms = regionFarms;
        loadingFarms = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingFarms = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // ADD FARM
  // ============================================================

  Future<void> addFarm() async {
    final farmName = farmNameController.text.trim();
    final areaText = areaController.text.trim();

    if (farmName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm name is required'),
        ),
      );
      return;
    }

    if (areaText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm area is required'),
        ),
      );
      return;
    }

    final double? area = double.tryParse(areaText);

    if (area == null || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid farm area'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.addFarm(
        name: farmName,
        area: area,
        regionId: widget.regionId,
      );

      if (!mounted) return;

      farmNameController.clear();
      areaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm added successfully'),
        ),
      );

      await loadFarms();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    farmNameController.dispose();
    areaController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Farm'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====================================================
            // REGION
            // ====================================================

            const Text(
              'Region',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                widget.regionName,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // FARM NAME
            // ====================================================

            const Text(
              'Farm Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: farmNameController,

              decoration: const InputDecoration(
                hintText: 'Enter farm name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ====================================================
            // FARM AREA
            // ====================================================

            const Text(
              'Farm Area',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: areaController,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                hintText: 'Enter area',
                border: OutlineInputBorder(),
                suffixText: 'acre',
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // ADD FARM
            // ====================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isLoading ? null : addFarm,

                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Add Farm',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // FARM LIST
            // ====================================================

            const Text(
              'Farm List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: loadingFarms

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : farms.isEmpty

                      ? const Center(
                          child: Text(
                            'No farms found',
                          ),
                        )

                      : ListView.builder(
                          itemCount: farms.length,

                          itemBuilder: (context, index) {
                            final farm = farms[index];

                            return Card(
                              child: ListTile(

                                title: Text(
                                  farm['name'].toString(),
                                ),

                                subtitle: Text(
                                  'Area: ${farm['area']} acre',
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}