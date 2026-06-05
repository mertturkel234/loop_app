import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// Siparişler sekmesi — filtreli sipariş listesi.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = ['Aktif', 'Beklemede', 'Tamamlanan'];

  static const _activeOrders = [
    _Order(id: '#ORD-1842', customer: 'Zeynep Aydın',
        address: 'Bağcılar, Meydan Sk. 14', status: 'Yolda',
        courier: 'Ahmet K.', time: '14:32', items: 3,
        amount: '₺148,00', statusColor: Color(0xFF4DBFB0)),
    _Order(id: '#ORD-1841', customer: 'Kemal Şahin',
        address: 'Güngören, Atatürk Cd. 88', status: 'Teslimatta',
        courier: 'Mehmet S.', time: '14:18', items: 1,
        amount: '₺67,50', statusColor: Color(0xFFFFAA00)),
    _Order(id: '#ORD-1839', customer: 'Selin Çelik',
        address: 'Esenler, Barbaros Bl. 7', status: 'Yolda',
        courier: 'Fatma N.', time: '13:55', items: 2,
        amount: '₺210,00', statusColor: Color(0xFF4DBFB0)),
  ];

  static const _pendingOrders = [
    _Order(id: '#ORD-1845', customer: 'Murat Kaya',
        address: 'Şişli, Cumhuriyet Cd. 40', status: 'Beklemede',
        courier: '—', time: '15:01', items: 4,
        amount: '₺320,00', statusColor: Color(0xFF9B7FFF)),
    _Order(id: '#ORD-1844', customer: 'Hatice Yıldız',
        address: 'Beşiktaş, Ihlamur Sk. 22', status: 'Beklemede',
        courier: '—', time: '14:58', items: 1,
        amount: '₺85,00', statusColor: Color(0xFF9B7FFF)),
  ];

  static const _completedOrders = [
    _Order(id: '#ORD-1838', customer: 'Ömer Demir',
        address: 'Kadıköy, Moda Cd. 5', status: 'Teslim Edildi',
        courier: 'Ali R.', time: '13:40', items: 2,
        amount: '₺175,00', statusColor: Color(0xFF4DBFB0)),
    _Order(id: '#ORD-1836', customer: 'Ayşe Korkmaz',
        address: 'Üsküdar, Bağlarbaşı Sk. 9', status: 'Teslim Edildi',
        courier: 'Ahmet K.', time: '13:12', items: 3,
        amount: '₺230,00', statusColor: Color(0xFF4DBFB0)),
    _Order(id: '#ORD-1834', customer: 'İbrahim Arslan',
        address: 'Maltepe, Bağdat Cd. 118', status: 'Teslim Edildi',
        courier: 'Fatma N.', time: '12:50', items: 1,
        amount: '₺92,00', statusColor: Color(0xFF4DBFB0)),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_Order> get _currentOrders {
    switch (_tabCtrl.index) {
      case 0: return _activeOrders;
      case 1: return _pendingOrders;
      default: return _completedOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Siparişler',
                          style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -0.3)),
                      Text('Bugün 34 sipariş',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withAlpha(130))),
                    ],
                  ),
                  const Spacer(),
                  // Arama butonu
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outline, width: 1),
                    ),
                    child: Icon(Icons.search_rounded,
                        color: cs.onSurface.withAlpha(150), size: 18),
                  ),
                  const SizedBox(width: 8),
                  // Filtre butonu
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outline, width: 1),
                    ),
                    child: Icon(Icons.filter_list_rounded,
                        color: cs.onSurface.withAlpha(150), size: 18),
                  ),
                ],
              ),
            ),

            // ── Özet metrikler ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  _MetricBox(value: '6', label: 'Aktif',
                      color: AppColors.textAccent),
                  const SizedBox(width: 8),
                  _MetricBox(value: '2', label: 'Beklemede',
                      color: const Color(0xFF9B7FFF)),
                  const SizedBox(width: 8),
                  _MetricBox(value: '26', label: 'Tamamlanan',
                      color: const Color(0xFFFFAA00)),
                  const SizedBox(width: 8),
                  _MetricBox(value: '₺4.280', label: 'Günlük Ciro',
                      color: AppColors.textAccent),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _LoopTabBar(
                tabs: _tabs,
                controller: _tabCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 10),

            // ── Sipariş listesi ──────────────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: _tabCtrl,
                builder: (context, child) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: _currentOrders.length,
                    separatorBuilder: (context, idx) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _OrderCard(order: _currentOrders[i]),
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

// ─────────────────────────────────────────────────────────────────────────────
// Özel Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class _LoopTabBar extends StatelessWidget {
  const _LoopTabBar({
    required this.tabs,
    required this.controller,
    required this.onChanged,
  });
  final List<String> tabs;
  final TabController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline, width: 1),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                controller.animateTo(i);
                onChanged(i);
              },
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final sel = controller.index == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: sel
                          ? cs.primary.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: sel
                          ? Border.all(
                              color: cs.primary.withAlpha(60),
                              width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(tabs[i],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: sel
                                ? AppColors.textAccent
                                : AppColors.textSecondary,
                          )),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metrik kutusu
// ─────────────────────────────────────────────────────────────────────────────

class _MetricBox extends StatelessWidget {
  const _MetricBox(
      {required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline, width: 1),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurface.withAlpha(130))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sipariş kartı
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline, width: 1),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(40)
                  : const Color(0xFF102A43).withAlpha(12),
              blurRadius: isDark ? 12 : 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.statusColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: order.statusColor.withAlpha(60), width: 1),
                ),
                child: Text(order.id,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.statusColor)),
              ),
              const Spacer(),
              Text(order.time,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: cs.onSurface.withAlpha(120))),
            ],
          ),
          const SizedBox(height: 10),
          Text(order.customer,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 12, color: cs.onSurface.withAlpha(100)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(order.address,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: cs.onSurface.withAlpha(150))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.directions_bike_rounded,
                  size: 12, color: cs.onSurface.withAlpha(100)),
              const SizedBox(width: 4),
              Text(order.courier,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withAlpha(150))),
              const SizedBox(width: 8),
              Icon(Icons.shopping_bag_outlined,
                  size: 12, color: cs.onSurface.withAlpha(100)),
              const SizedBox(width: 4),
              Text('${order.items} ürün',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withAlpha(150))),
              const Spacer(),
              Text(order.amount,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: order.statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sipariş modeli
// ─────────────────────────────────────────────────────────────────────────────

class _Order {
  const _Order({
    required this.id,
    required this.customer,
    required this.address,
    required this.status,
    required this.courier,
    required this.time,
    required this.items,
    required this.amount,
    required this.statusColor,
  });
  final String id;
  final String customer;
  final String address;
  final String status;
  final String courier;
  final String time;
  final int items;
  final String amount;
  final Color statusColor;
}
