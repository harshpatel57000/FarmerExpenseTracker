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
  final TextEditingController regionController =
      TextEditingController();

  bool loading = false;

  Future<void> addRegion() async {
    final name = regionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('વિસ્તારનું નામ દાખલ કરો'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.addRegion(
        name: name,
        villageId: widget.villageId,
      );

      final int regionId = result['id'];

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('વિસ્તાર સફળતાપૂર્વક ઉમેરાયો'),
        ),
      );

      regionController.clear();

      // Go to Farm page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFarmPage(
            regionId: regionId,
          ),
        ),
      );
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
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('વિસ્તાર ઉમેરો'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: regionController,
              decoration: const InputDecoration(
                labelText: 'વિસ્તારનું નામ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addRegion,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('વિસ્તાર ઉમેરો'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}