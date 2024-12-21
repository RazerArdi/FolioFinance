import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'AsynchronousComputingHome/AsynchronousComputingHome.dart';

class Porto extends StatelessWidget {
  const Porto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const PortfolioScreen(),
    );
  }
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConnectivityController connectivityController = ConnectivityController();

  final List<Widget> _pages = [
    StocksPage(),
    OrdersPage(),
    HistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!connectivityController.isConnected.value) {
      return AsynchronousComputingHome();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.show_chart),
              text: 'STOCKS',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'ORDERS',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'HISTORY',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
    );
  }
}

class StocksPage extends StatefulWidget {
  const StocksPage({Key? key}) : super(key: key);

  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final CollectionReference stocksCollection = FirebaseFirestore.instance.collection('stocks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: stocksCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Stocks Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final stock = doc.data() as Map<String, dynamic>;
              final name = stock['name'] ?? 'Unknown';
              final invested = _toDouble(stock['invested']);
              final pnl = _toDouble(stock['pnl']);
              final loss = _toDouble(stock['loss']);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: const Icon(Icons.edit, color: Colors.blue),
                                    title: const Text('Edit'),
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () {
                                      Navigator.pop(context);
                                      showStockDialog(id: doc.id, stock: stock);
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.red),
                                    title: const Text('Delete'),
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () {
                                      Navigator.pop(context);
                                      deleteStock(doc.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Invested: \$${invested.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildIndicatorLabel('P&L', pnl),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 12,
                          percent: pnl.abs().clamp(0.0, 1.0),
                          progressColor: pnl >= 0 ? Colors.green : Colors.red,
                          backgroundColor: Colors.grey[200],
                          barRadius: const Radius.circular(6),
                          animation: true,
                          center: Text(
                            '${(pnl * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildIndicatorLabel('Loss', loss),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 12,
                          percent: loss.abs().clamp(0.0, 1.0),
                          progressColor: Colors.red,
                          backgroundColor: Colors.grey[200],
                          barRadius: const Radius.circular(6),
                          animation: true,
                          center: Text(
                            '${(loss * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStockDialog(),
        label: const Text('Add Stock'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildIndicatorLabel(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: value >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> addStock(Map<String, dynamic> stock) async {
    await stocksCollection.add(stock);
  }

  Future<void> updateStock(String id, Map<String, dynamic> updatedStock) async {
    await stocksCollection.doc(id).update(updatedStock);
  }

  Future<void> deleteStock(String id) async {
    await stocksCollection.doc(id).delete();
  }

  Future<void> showStockDialog({String? id, Map<String, dynamic>? stock}) async {
    final isUpdate = id != null;
    final nameController = TextEditingController(
        text: isUpdate ? stock!['name'] : '');
    final investedController = TextEditingController(
        text: isUpdate ? stock!['invested']?.toString() ?? '0.0' : '');
    final pnlController = TextEditingController(
        text: isUpdate ? ((stock!['pnl'] ?? 0.0) * 100).toString() : '');
    final lossController = TextEditingController(
        text: isUpdate ? ((stock!['loss'] ?? 0.0) * 100).toString() : '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'Update Stock' : 'Add Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Stock Name'),
            ),
            TextField(
              controller: investedController,
              decoration: const InputDecoration(labelText: 'Invested'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pnlController,
              decoration: const InputDecoration(labelText: 'P&L (%)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lossController,
              decoration: const InputDecoration(labelText: 'Loss (%)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final stockData = {
                "name": nameController.text,
                "invested": double.tryParse(investedController.text) ?? 0.0,
                "pnl": (double.tryParse(pnlController.text) ?? 0.0) / 100,
                "loss": (double.tryParse(lossController.text) ?? 0.0) / 100,
              };
              if (isUpdate) {
                updateStock(id!, stockData);
              } else {
                addStock(stockData);
              }
              Navigator.of(context).pop();
            },
            child: Text(isUpdate ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  // Helper method to safely parse values as double
  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class OrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {"action": "SELL", "stock": "TLKM", "amount": 3162075, "price": 3170, "status": "OPEN"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order['action'] == 'SELL' ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order['action'],
                    style: TextStyle(
                      color: order['action'] == 'SELL' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order['stock'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildOrderDetail('Amount', '\$${order['amount']}'),
                _buildOrderDetail('Price', '\$${order['price']}'),
                _buildOrderDetail('Status', order['status']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [
    {"action": "BUY", "stock": "TLKM", "amount": 2944410, "price": 2940, "date": "23 Oct 2024"},
    {"action": "SELL", "stock": "PGAS", "amount": 3112200, "price": 1560, "date": "23 Oct 2024"},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredHistory = history
        .where((record) =>
        record['stock'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search History',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final record = filteredHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: record['action'] == 'SELL' ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record['action'],
                          style: TextStyle(
                            color: record['action'] == 'SELL' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record['stock'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHistoryDetail('Amount', '\$${record['amount']}'),
                      _buildHistoryDetail('Price', '\$${record['price']}'),
                      _buildHistoryDetail('Date', record['date']),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Add some animations and transitions for better user experience
class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

// Custom card widget for reusability
class StockCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  const StockCard({
    Key? key,
    required this.title,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// Custom theme data
final ThemeData modernTheme = ThemeData(
  primarySwatch: Colors.green,
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: Colors.grey[100],
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.green),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

// Constants for styling
class AppStyles {
  static const cardPadding = EdgeInsets.all(16.0);
  static const spacingSmall = 8.0;
  static const spacingMedium = 16.0;
  static const spacingLarge = 24.0;

  static const textHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const textSubheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const textBody = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static final textCaption = TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
  );
}

// Extension methods for number formatting
extension NumberFormatting on num {
  String toCurrency() {
    return '\$${toStringAsFixed(2)}';
  }

  String toPercentage() {
    return '${toStringAsFixed(1)}%';
  }
}