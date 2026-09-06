import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'farm_page.dart';

class AddRegionPage extends StatefulWidget {
  final int villageId;

  const AddRegionPage({
    super.key,
    required this.villageId,
  });

  @override
  State<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends State<AddRegionPage> {
  final TextEditingController regionNameController =
      TextEditingController();

  List<dynamic> regions = [];

  bool isLoading = false;
  bool loadingRegions = true;

  @override
  void initState() {
    super.initState();
    loadRegions();
  }

  // ============================================================
  // GET REGIONS
  // ============================================================

  Future<void> loadRegions() async {
    try {
      final allRegions = await ApiService.getRegions();

      if (!mounted) return;

      final villageRegions = allRegions.where((region) {
        return int.parse(region['villageId'].toString()) ==
            widget.villageId;
      }).toList();

      setState(() {
        regions = villageRegions;
        loadingRegions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingRegions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // ADD REGION
  // ============================================================

  Future<void> addRegion() async {
    final regionName = regionNameController.text.trim();

    if (regionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Region name is required'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.addRegion(
        name: regionName,
        villageId: widget.villageId,
      );

      if (!mounted) return;

      regionNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Region added successfully'),
        ),
      );

      await loadRegions();
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
  // SELECT REGION
  // ============================================================

  void selectRegion(
    int regionId,
    String regionName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmPage(
          regionId: regionId,
          regionName: regionName,
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    regionNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Region'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====================================================
            // VILLAGE ID
            // ====================================================

            const Text(
              'Village ID',
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
                widget.villageId.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // REGION NAME
            // ====================================================

            const Text(
              'Region Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: regionNameController,

              decoration: const InputDecoration(
                hintText: 'Enter region name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ====================================================
            // ADD REGION BUTTON
            // ====================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isLoading ? null : addRegion,

                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Add Region',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // REGION LIST TITLE
            // ====================================================

            const Text(
              'Region List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ====================================================
            // REGION LIST
            // ====================================================

            Expanded(
              child: loadingRegions

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : regions.isEmpty

                      ? const Center(
                          child: Text(
                            'No regions found',
                          ),
                        )

                      : ListView.builder(
                          itemCount: regions.length,

                          itemBuilder: (context, index) {
                            final region = regions[index];

                            final int regionId =
                                int.parse(
                              region['id'].toString(),
                            );

                            final String regionName =
                                region['name'].toString();

                            return Card(
                              child: ListTile(

                                title: Text(
                                  regionName,
                                ),

                                subtitle: Text(
                                  'Region ID: $regionId',
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                ),

                                onTap: () {
                                  selectRegion(
                                    regionId,
                                    regionName,
                                  );
                                },
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