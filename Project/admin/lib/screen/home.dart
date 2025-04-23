import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin/main.dart'; // Assuming this contains supabase setup

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int userCount = 0;
  int decoratorCount = 0;
  int cateringCount = 0;
  double totalBookingAmount = 0;
  List<double> monthlyAmounts = List.filled(12, 0);
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    fetchDashboardStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboardStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final userResponse = await supabase.from('tbl_user').select().count();
      final decoratorResponse = await supabase.from('tbl_decorators').select().count();
      final cateringResponse = await supabase.from('tbl_catering').select().count();

      final decoBookingResponse = await supabase
          .from('tbl_decorationbooking')
          .select('decbook_totalamnt')
          .inFilter('decbook_status', [3, 5]);
      final caterBookingResponse = await supabase
          .from('tbl_cateringbooking')
          .select('booking_total')
          .inFilter('booking_status', [3, 5]);

      double decoTotal = decoBookingResponse
          .map<double>((row) => (row['decbook_totalamnt'] as num?)?.toDouble() ?? 0)
          .fold(0, (sum, val) => sum + val);
      double caterTotal = caterBookingResponse
          .map<double>((row) => (row['booking_total'] as num?)?.toDouble() ?? 0)
          .fold(0, (sum, val) => sum + val);

      final decoMonthlyResponse = await supabase
          .from('tbl_decorationbooking')
          .select('decbook_totalamnt, decbook_fordate')
          .inFilter('decbook_status', [3, 5])
          .gte('decbook_fordate', '2025-01-01')
          .lte('decbook_fordate', '2025-12-31');
      final caterMonthlyResponse = await supabase
          .from('tbl_cateringbooking')
          .select('booking_total, booking_fordate')
          .inFilter('booking_status', [3, 5])
          .gte('booking_fordate', '2025-01-01')
          .lte('booking_fordate', '2025-12-31');

      List<double> monthly = List.filled(12, 0);
      for (var row in decoMonthlyResponse) {
        final date = DateTime.parse(row['decbook_fordate']);
        final month = date.month - 1;
        monthly[month] += (row['decbook_totalamnt'] as num?)?.toDouble() ?? 0;
      }
      for (var row in caterMonthlyResponse) {
        final date = DateTime.parse(row['booking_fordate']);
        final month = date.month - 1;
        monthly[month] += (row['booking_total'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        userCount = userResponse.count;
        decoratorCount = decoratorResponse.count;
        cateringCount = cateringResponse.count;
        totalBookingAmount = decoTotal + caterTotal;
        monthlyAmounts = monthly;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching dashboard stats: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B263B)))
          : errorMessage != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: fetchDashboardStats,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF065a60),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchDashboardStats,
                  color: const Color(0xFF065a60),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.dashboard,
                                color: Color(0xFF065a60),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B263B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Overview of key metrics and performance',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Statistics Grid
                        GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width > 1200
                              ? 4
                              : MediaQuery.of(context).size.width > 600
                                  ? 2
                                  : 1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.0,
                          children: [
                            _buildStatCard(
                              'Users',
                              userCount.toString(),
                              Icons.person,
                              const Color(0xFF415A77),
                            ),
                            _buildStatCard(
                              'Decorators',
                              decoratorCount.toString(),
                              Icons.brush,
                              const Color(0xFF778DA9),
                            ),
                            _buildStatCard(
                              'Catering',
                              cateringCount.toString(),
                              Icons.restaurant,
                              const Color(0xFFE0E1DD),
                              textColor: const Color(0xFF1B263B),
                            ),
                            _buildStatCard(
                              'Total Revenue',
                              '₹${NumberFormat.compact().format(totalBookingAmount)}',
                              Icons.account_balance,
                              const Color(0xFF0D1B2A),
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Monthly Graph
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF8FAFC),
                                Color(0xFFEFF7FF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Revenue (2025)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1B263B),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 350,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: monthlyAmounts.isNotEmpty
                                            ? (monthlyAmounts.reduce((a, b) => a > b ? a : b) * 0.2)
                                            : 1000,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: const Color(0xFFE5E7EB),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 50,
                                            interval: monthlyAmounts.isNotEmpty
                                                ? (monthlyAmounts.reduce((a, b) => a > b ? a : b) * 0.2)
                                                : 1000,
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: Text(
                                                  '₹${(value / 1000).toStringAsFixed(0)}k',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const months = [
                                                'Jan',
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'May',
                                                'Jun',
                                                'Jul',
                                                'Aug',
                                                'Sep',
                                                'Oct',
                                                'Nov',
                                                'Dec'
                                              ];
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  months[value.toInt()],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(
                                            12,
                                            (index) => FlSpot(index.toDouble(), monthlyAmounts[index]),
                                          ),
                                          isCurved: true,
                                          color: const Color(0xFF065a60),
                                          barWidth: 4,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFF065a60).withOpacity(0.15),
                                          ),
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                              radius: 5,
                                              color: const Color(0xFF1B263B),
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          getTooltipItems: (touchedSpots) {
                                            return touchedSpots.map((spot) {
                                              return LineTooltipItem(
                                                '₹${NumberFormat.compact().format(spot.y)}',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            }).toList();
                                          },
                                          getTooltipColor: (LineBarSpot spot) => const Color(0xFF065a60),
                                        ),
                                        handleBuiltInTouches: true,
                                      ),
                                      minY: 0,
                                      maxY: monthlyAmounts.isNotEmpty
                                          ? (monthlyAmounts.reduce((a, b) => a > b ? a : b) * 1.2)
                                          : 1000,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, {Color? textColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withOpacity(0.9),
            bgColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 28, color: textColor ?? Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor ?? Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}