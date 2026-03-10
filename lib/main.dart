import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/add_deposit_screen.dart';
import 'screens/view_deposits_screen.dart';
import 'services/excel_import_service.dart';

void main() {
  runApp(const DepositTrackerApp());
}

class DepositTrackerApp extends StatelessWidget {
  const DepositTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "Deposit Tracker", home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalFD = 0;
  double totalRD = 0;
  double totalPrincipal = 0;

  List<Map<String, dynamic>> bankTotals = [];
  List<Map<String, dynamic>> userTotals = [];

  @override
  void initState() {
    super.initState();
    loadTotals();
  }

  Future<void> loadTotals() async {
    final fd = await DatabaseHelper.instance.getTotalByType("FD");
    final rd = await DatabaseHelper.instance.getTotalByType("RD");
    final total = await DatabaseHelper.instance.getTotalPrincipal();

    final banks = await DatabaseHelper.instance.getTotalByBank();
    final users = await DatabaseHelper.instance.getTotalByUser();

    setState(() {
      totalFD = fd;
      totalRD = rd;
      totalPrincipal = total;
      bankTotals = banks;
      userTotals = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dashboardCards = [];
    List<Widget> dashboardUserCards = [];

    if (bankTotals.isNotEmpty) {
      for (var bank in bankTotals) {
        dashboardCards.add(
          dashboardCard(
            title: "Bank: ${bank['bankName']}",
            amount: "₹${bank['total']}",
            icon: Icons.account_balance,
            gradient: [
              const Color.fromARGB(255, 164, 76, 180),
              const Color.fromARGB(255, 82, 51, 168),
            ],
          ),
        );
      }
    }

    if (userTotals.isNotEmpty) {
      for (var user in userTotals) {
        dashboardUserCards.add(
          dashboardCard(
            title: "User: ${user['depositor']}",
            amount: "₹${user['total']}",
            icon: Icons.person,
            gradient: [Colors.indigo, Colors.indigoAccent],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Deposit Tracker")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: PageView(
                controller: PageController(viewportFraction: 0.9),
                padEnds: false,
                children: [
                  dashboardCard(
                    title: "Total Principal",
                    amount: "₹$totalPrincipal",
                    icon: Icons.account_balance_wallet,
                    gradient: [Colors.blue, Colors.blueAccent],
                  ),
                  dashboardCard(
                    title: "Total FD",
                    amount: "₹$totalFD",
                    icon: Icons.savings,
                    gradient: [Colors.green, Colors.teal],
                  ),
                  dashboardCard(
                    title: "Total RD",
                    amount: "₹$totalRD",
                    icon: Icons.trending_up,
                    gradient: [Colors.orange, Colors.deepOrange],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                padEnds: false,
                itemCount: dashboardCards.length,
                itemBuilder: (context, index) {
                  return dashboardCards[index];
                },
              ),
            ),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                padEnds: false,
                itemCount: dashboardUserCards.length,
                itemBuilder: (context, index) {
                  return dashboardUserCards[index];
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewDepositsScreen()),
                );
              },
              child: const Text("View Deposits"),
            ),

            ElevatedButton(
              onPressed: () async {
                await importExcelDeposits();
                loadTotals();
              },
              child: const Text("Import Excel Deposits"),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDepositScreen()),
          );

          loadTotals();
        },
      ),
    );
  }
}

Widget dashboardCard({
  required String title,
  required String amount,
  required IconData icon,
  required List<Color> gradient,
}) {
  return Container(
    // width: 150,
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Icon(icon, size: 40, color: Colors.white70),
        ],
      ),
    ),
  );
}
