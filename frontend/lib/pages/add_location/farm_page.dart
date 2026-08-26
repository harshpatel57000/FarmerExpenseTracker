import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddFarmPage extends StatefulWidget {
  final int regionId;

  const AddFarmPage({
    super.key,
    required this.regionId,
  });

  @override
  State<AddFarmPage> createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final TextEditingController farmController =
      TextEditingController();

  bool loading = false;

  Future<void> addFarm() async {
    final name = farmController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ખેતરનું નામ દાખલ કરો'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.addFarm(
        name: name,
        regionId: widget.regionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ખેતર સફળતાપૂર્વક ઉમેરાયું'),
        ),
      );

      farmController.clear();

      // Go back
      Navigator.pop(context);
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
    farmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ખેતર ઉમેરો'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: farmController,
              decoration: const InputDecoration(
                labelText: 'ખેતરનું નામ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addFarm,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('ખેતર ઉમેરો'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}