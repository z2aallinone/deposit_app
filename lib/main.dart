import 'package:flutter/material.dart';
import 'screens/add_deposit_screen.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DepositTrackerApp());
}

class DepositTrackerApp extends StatelessWidget {
  const DepositTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deposit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deposit Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Total FD: ₹0",
              style: TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 10),

            const Text(
              "Total RD: ₹0",
              style: TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {},
              child: const Text("View Deposits"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDepositScreen(),
                  ),
                );
              },
              child: const Text("Add Deposit"),
            )
          ],
        ),
      ),
    );
  }
}