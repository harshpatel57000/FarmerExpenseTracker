import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/pages/add_region/region_page.dart';

import 'Agro_product_purches_page/agro_expense_page.dart';
import 'total_expense_page.dart';
import 'farm_expense/select_farm_page.dart';
import 'profile_page.dart';
import 'expense_view_page.dart';
import 'services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver {
  Timer? _timer;

  String _background = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _updateBackground();

    // Update the background every minute.
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateBackground(),
    );
  }

  void _updateBackground() {
    final hour = DateTime.now().hour;

    final String nextBackground;

    if (hour >= 5 && hour < 11) {
      nextBackground = 'assets/images/farm_morning.jpg';
    } else if (hour >= 11 && hour < 16) {
      nextBackground = 'assets/images/Singup_background_image.jpg';
    } else if (hour >= 16 && hour < 19) {
      nextBackground = 'assets/images/farm_evening_image.jpg';
    } else {
      nextBackground = 'assets/images/farm_night.jpg';
    }

    if (mounted && nextBackground != _background) {
      setState(() {
        _background = nextBackground;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateBackground();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'ખેતી ખર્ચ ટ્રેકર',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.green.shade900.withValues(alpha: 0.92),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'પ્રોફાઇલ',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background changes according to the time of day.
          Image.asset(
            _background,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade100,
                      Colors.white,
                      Colors.lightGreen.shade50,
                    ],
                  ),
                ),
              );
            },
          ),

          // Make the background lighter so the content is readable.
          Container(
            color: Colors.white.withValues(alpha: 0.78),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome card.
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.shade100,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 42,
                          color: Colors.green.shade800,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'સ્વાગત છે',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF164D36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'તમારા ખેતીના ખર્ચનું સંચાલન કરો',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 1. Add farm expense.
                  _buildMenuCard(
                    icon: Icons.agriculture_outlined,
                    title: 'ખેતરનો ખર્ચ ઉમેરો',
                    subtitle: 'ખેતરમાં થયેલો ખર્ચ નોંધો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelectFarmPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 2. Add agricultural product expense.
                  _buildMenuCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'કૃષિ ઉત્પાદનનો ખર્ચ ઉમેરો',
                    subtitle: 'ખાતર, દવા અને અન્ય વસ્તુની ખરીદી નોંધો',
                    onTap: () async {
                      final userId = await ApiService.getUserId();

                      if (!context.mounted) return;

                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'User ID not found. Please log in again.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgroExpensePage(
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 3. Add a new village, region, or farm.
                  _buildMenuCard(
                    icon: Icons.add_business_outlined,
                    title: 'નવું ખેતર / વિસ્તાર ઉમેરો',
                    subtitle: 'નવો વિસ્તાર અથવા ખેતર ઉમેરો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddRegionPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 4. Existing total expense page.
                  _buildMenuCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'કુલ ખેતી ખર્ચ જુઓ',
                    subtitle: 'વિસ્તાર અને ખેતર પ્રમાણે ખર્ચ જુઓ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TotalExpensePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 5. New Expense View page.
                  _buildMenuCard(
                    icon: Icons.pie_chart_outline,
                    title: 'ખર્ચ જુઓ',
                    subtitle:
                        'ચાર્ટ અને વિગતવાર ખર્ચનું વિશ્લેષણ જુઓ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpenseViewPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withValues(alpha: 0.96),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.shade100,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 31,
                  color: Colors.green.shade800,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}