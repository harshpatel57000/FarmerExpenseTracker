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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _backgroundTimer;
  Timer? _slideTimer;

  late String _background;

  final PageController _slideController = PageController();

  int _currentSlide = 0;

  // Dashboard expense totals.
  String activeCropExpenseTotal = '—';
  String totalAgroExpense = '—';

  bool _isLoadingTotals = true;
  String? _dashboardError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _background = _getBackground();

    // Load expense totals from backend.
    _loadDashboardTotals();

    // Update background every minute.
    _backgroundTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateBackground(),
    );

    // Automatically change slides every 4 seconds.
    _slideTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _nextSlide(),
    );
  }

  // --------------------------------------------------
  // TIME-BASED BACKGROUND
  // --------------------------------------------------

  String _getBackground() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'assets/images/farm_morning.png';
    } else if (hour >= 11 && hour < 16) {
      return 'assets/images/Singup_background_image.png';
    } else if (hour >= 16 && hour < 19) {
      return 'assets/images/farm_evening_image.png';
    } else {
      return 'assets/images/farm_night.png';
    }
  }

  void _updateBackground() {
    final nextBackground = _getBackground();

    if (mounted && nextBackground != _background) {
      setState(() {
        _background = nextBackground;
      });
    }
  }

  // --------------------------------------------------
  // EXPENSE SLIDESHOW
  // --------------------------------------------------

  void _nextSlide() {
    if (!mounted || !_slideController.hasClients) return;

    final nextPage = (_currentSlide + 1) % 2;

    _slideController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // --------------------------------------------------
  // API RESPONSE HELPERS
  // --------------------------------------------------

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return {};
  }

  int? _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  // --------------------------------------------------
  // LOAD DASHBOARD EXPENSE TOTALS
  // --------------------------------------------------

  Future<void> _loadDashboardTotals() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTotals = true;
      _dashboardError = null;
    });

    try {
      // STEP 1: Get all farms of the logged-in user.
      final farms = await ApiService.getFarms();

      // STEP 2: Get crop cycles for every farm.
      final Set<int> activeCropCycleIds = {};

      final cycleResults = await Future.wait(
        farms.map((farmData) async {
          final farm = _toMap(farmData);

          final farmId = _toInt(
            farm['id'] ?? farm['farmId'],
          );

          if (farmId == null) {
            return <dynamic>[];
          }

          return await ApiService.getCropCyclesByFarm(farmId);
        }),
      );

      // STEP 3: Collect IDs of ACTIVE crop cycles.
      for (final cycles in cycleResults) {
        for (final cycleData in cycles) {
          final cycle = _toMap(cycleData);

          final status = cycle['status']?.toString().trim().toUpperCase();

          final cycleId = _toInt(cycle['id']);

          if (status == 'ACTIVE' && cycleId != null) {
            activeCropCycleIds.add(cycleId);
          }
        }
      }

      // STEP 4: Get all farm expenses for this user.
      final farmExpenses = await ApiService.getFarmExpenses();

      double activeCropTotal = 0.0;

      // STEP 5: Sum expenses belonging to ACTIVE cycles only.
      for (final expenseData in farmExpenses) {
        final expense = _toMap(expenseData);

        final cropCycleId = _toInt(
          expense['cropCycleId'],
        );

        if (cropCycleId != null && activeCropCycleIds.contains(cropCycleId)) {
          activeCropTotal += _toDouble(
            expense['totalCost'],
          );
        }
      }

      // STEP 6: Get logged-in user's agro expenses.
      final agroExpenses = await ApiService.getAgroExpenses();

      double agroTotal = 0.0;

      // STEP 7: Add totalAmount of every agro expense.
      for (final agroData in agroExpenses) {
        final agro = _toMap(agroData);

        agroTotal += _toDouble(
          agro['totalAmount'],
        );
      }

      // STEP 8: Update dashboard.
      if (!mounted) return;

      setState(() {
        activeCropExpenseTotal = _formatAmount(activeCropTotal);

        totalAgroExpense = _formatAmount(agroTotal);

        _isLoadingTotals = false;
        _dashboardError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        activeCropExpenseTotal = '—';
        totalAgroExpense = '—';

        _isLoadingTotals = false;
        _dashboardError = 'ખર્ચની માહિતી લોડ થઈ શકી નથી';
      });

      debugPrint('Dashboard expense loading error: $e');
    }
  }

  // --------------------------------------------------
  // APP LIFECYCLE
  // --------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateBackground();
      _loadDashboardTotals();
    }
  }

  @override
  void dispose() {
    _backgroundTimer?.cancel();
    _slideTimer?.cancel();

    _slideController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // --------------------------------------------------
  // NAVIGATION
  // --------------------------------------------------

  void _navigate(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // --------------------------------------------------
  // MAIN UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green.shade900.withValues(
          alpha: 0.82,
        ),
        foregroundColor: Colors.white,
        title: const Text(
          'ખેતી ખર્ચ ટ્રેકર',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'પ્રોફાઇલ',
            icon: const Icon(
              Icons.person_outline,
              size: 27,
            ),
            onPressed: () {
              _navigate(const ProfilePage());
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photograph.
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
                      Colors.green.shade200,
                      Colors.lightGreen.shade50,
                    ],
                  ),
                ),
              );
            },
          ),

          // Transparent white overlay.
          Container(
            color: Colors.white.withValues(alpha: 0.30),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Welcome header.
                  _buildWelcome(),

                  const SizedBox(height: 18),

                  // 2. Expense slideshow heading.
                  _buildSectionTitle(
                    'ખેતી ખર્ચની ઝલક',
                    'તમારા બધા ખેતરોના ખર્ચ',
                    Icons.analytics_outlined,
                  ),

                  const SizedBox(height: 12),

                  // 3. Expense slideshow.
                  SizedBox(
                    height: 145,
                    child: PageView(
                      controller: _slideController,
                      onPageChanged: (index) {
                        if (!mounted) return;

                        setState(() {
                          _currentSlide = index;
                        });
                      },
                      children: [
                        // Slide 1: Active crop expense.
                        _buildExpenseSlide(
                          title: 'ચાલુ પાકનો કુલ ખર્ચ',
                          subtitle: 'તમામ ખેતરોના ચાલુ પાકનો ખર્ચ',
                          amount: _isLoadingTotals
                              ? 'લોડ થઈ રહ્યું છે...'
                              : activeCropExpenseTotal,
                          imagePath: 'assets/images/crop_expense_slide_icon.png',
                          fallbackIcon: Icons.grass,
                          color: Colors.green,
                          slideNumber: '01 / 02',
                        ),

                        // Slide 2: Total agro expense.
                        _buildExpenseSlide(
                          title: 'કુલ કૃષિ ખરીદી ખર્ચ',
                          subtitle: 'તમારી તમામ કૃષિ ખરીદીનો ખર્ચ',
                          amount: _isLoadingTotals
                              ? 'લોડ થઈ રહ્યું છે...'
                              : totalAgroExpense,
                          imagePath: 'assets/images/agro_expense_slide_icon.png',
                          fallbackIcon: Icons.inventory_2_outlined,
                          color: Colors.orange,
                          slideNumber: '02 / 02',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Slideshow indicators.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) {
                        final selected = _currentSlide == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          height: 7,
                          width: selected ? 23 : 7,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.green.shade800
                                : Colors.green.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ),

                  // API error and retry button.
                  if (_dashboardError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _dashboardError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadDashboardTotals,
                          child: const Text('ફરી પ્રયાસ કરો'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 4. Quick actions heading.
                  _buildSectionTitle(
                    'ઝડપી કામગીરી',
                    'તમારા ખેતીના કામ પસંદ કરો',
                    Icons.dashboard_outlined,
                  ),

                  const SizedBox(height: 12),

                  // 5. Navigation grid.
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.38,
                    children: [
                      // Farm expense.
                      _buildMenuCard(
                        icon: Icons.agriculture_outlined,
                        imagePath: 'assets/images/farmExpense_icon.png',
                        title: 'ખેતરનો ખર્ચ',
                        subtitle: 'ખેતરમાં થયેલો ખર્ચ નોંધો',
                        color: Colors.green,
                        onTap: () {
                          _navigate(const SelectFarmPage());
                        },
                      ),

                      // Agro expense.
                      _buildMenuCard(
                        icon: Icons.inventory_2_outlined,
                        imagePath: 'assets/images/agroExpense_icon.png',
                        title: 'ખરીદીનો ખર્ચ',
                        subtitle: 'ખાતર, દવા અને અન્ય વસ્તુઓ',
                        color: Colors.orange,
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

                          _navigate(
                            AgroExpensePage(userId: userId),
                          );
                        },
                      ),

                      // Add farm.
                      _buildMenuCard(
                        icon: Icons.add_business_outlined,
                        imagePath: 'assets/images/addFarm_icon.png',
                        title: 'ખેતર ઉમેરો',
                        subtitle: 'નવો વિસ્તાર અથવા ખેતર ઉમેરો',
                        color: Colors.blue,
                        onTap: () {
                          _navigate(const AddRegionPage());
                        },
                      ),

                      // Total expense.
                      _buildMenuCard(
                        icon: Icons.bar_chart_outlined,
                        imagePath: 'assets/images/total_expense_icon.png',
                        title: 'કુલ ખર્ચ',
                        subtitle: 'વિસ્તાર અને ખેતર પ્રમાણે',
                        color: Colors.purple,
                        onTap: () {
                          _navigate(const TotalExpensePage());
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Expense analysis.
                  _buildWideMenuCard(
                    icon: Icons.pie_chart_outline,
                    imagePath: 'assets/images/expense_view_icon.png',
                    title: 'ખર્ચનું વિશ્લેષણ',
                    subtitle: 'ચાર્ટ અને વિગતવાર ખર્ચ જુઓ',
                    onTap: () {
                      _navigate(const ExpenseViewPage());
                    },
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'તમારી ખેતી, તમારો હિસાબ 🌱',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // WELCOME HEADER
  // --------------------------------------------------

  Widget _buildWelcome() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.waving_hand_outlined,
            color: Colors.green,
            size: 27,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'સ્વાગત છે 👋',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF164D36),
                  ),
                ),
                Text(
                  'તમારા ખેતીના ખર્ચનું સંચાલન કરો',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION HEADING
  // --------------------------------------------------

  Widget _buildSectionTitle(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green.shade900,
          size: 23,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164D36),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EXPENSE SLIDESHOW CARD (USES ASSET IMAGES)
  // --------------------------------------------------

  Widget _buildExpenseSlide({
    required String title,
    required String subtitle,
    required String amount,
    required String imagePath,
    required IconData fallbackIcon,
    required MaterialColor color,
    required String slideNumber,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.shade800,
            color.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                      size: 21,
                    ),
                    Flexible(
                      child: Text(
                        amount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Slide Icon Box displaying the custom assets with fallback
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Center(
                    child: Icon(
                      fallbackIcon,
                      color: color.shade800,
                      size: 34,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CATEGORY GRID CARD
  // --------------------------------------------------

  Widget _buildMenuCard({
    required IconData icon,
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryIcon(
                icon: icon,
                imagePath: imagePath,
                color: color,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382C),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CATEGORY IMAGE WIDGET
  // --------------------------------------------------

  Widget _buildCategoryIcon({
    required IconData icon,
    required String imagePath,
    required Color color,
  }) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Center(
              child: Icon(
                icon,
                size: 27,
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // WIDE EXPENSE ANALYSIS CARD
  // --------------------------------------------------

  Widget _buildWideMenuCard({
    required IconData icon,
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              _buildCategoryIcon(
                icon: icon,
                imagePath: imagePath,
                color: Colors.green,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                color: Colors.green.shade800,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}