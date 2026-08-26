import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'region_page.dart';

class VillagePage extends StatefulWidget {
  const VillagePage({super.key});

  @override
  State<VillagePage> createState() => _VillagePageState();
}

class _VillagePageState extends State<VillagePage> {
  final TextEditingController villageController = TextEditingController();

  bool loading = false;

  Future<void> addVillage() async {
    final name = villageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ગામનું નામ દાખલ કરો')));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.addVillage(name: name);

      final int villageId = result['id'];

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ગામ સફળતાપૂર્વક ઉમેરાયું')));

      villageController.clear();

      // Go to Region page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRegionPage(villageId: villageId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
    villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ગામ ઉમેરો')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: villageController,
              decoration: const InputDecoration(
                labelText: 'ગામનું નામ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addVillage,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('ગામ ઉમેરો'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
