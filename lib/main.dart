import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/add_deposit_screen.dart';
import 'screens/view_deposits_screen.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit Tracker")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Principal"),
                trailing: Text("₹$totalPrincipal"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Total per Bank",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...bankTotals.map((bank) {
              return ListTile(
                title: Text(bank['bankName']),
                trailing: Text("₹${bank['total']}"),
              );
            }),

            const SizedBox(height: 20),

            const Text(
              "Total per User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...userTotals.map((user) {
              return ListTile(
                title: Text(user['depositor']),
                trailing: Text("₹${user['total']}"),
              );
            }),

            Card(
              child: ListTile(
                title: const Text("Total FD"),
                trailing: Text("₹$totalFD"),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text("Total RD"),
                trailing: Text("₹$totalRD"),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDepositScreen()),
                );

                loadTotals();
              },
              child: const Text("Add Deposit"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewDepositsScreen()),
                );
              },
              child: const Text("View Deposits"),
            ),
          ],
        ),
      ),
    );
  }
}
