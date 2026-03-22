import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ViewDepositsScreen extends StatefulWidget {
  const ViewDepositsScreen({super.key});

  @override
  State<ViewDepositsScreen> createState() => _ViewDepositsScreenState();
}

class _ViewDepositsScreenState extends State<ViewDepositsScreen> {
  List<Map<String, dynamic>> deposits = [];

  @override
  void initState() {
    super.initState();
    loadDeposits();
  }

  Future<void> loadDeposits() async {
    final data = await DatabaseHelper.instance.getDeposits();
    setState(() {
      deposits = data;
    });
  }

  Future<void> deleteDeposit(int id) async {
    await DatabaseHelper.instance.deleteDeposit(id);
    loadDeposits();
  }

  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Deposit"),
          content: const Text("Are you sure you want to delete this deposit?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteDeposit(id);

                if (!mounted) return;

                Navigator.pop(context);

                loadDeposits();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Deposits")),

      body: deposits.isEmpty
          ? const Center(child: Text("No deposits found"))
          : ListView.builder(
              itemCount: deposits.length,
              itemBuilder: (context, index) {
                final deposit = deposits[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(
                    title: Text(
                      "${deposit['bankName']} - ${deposit['depositType']}",
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Depositor: ${deposit['depositor']}"),
                        Text("Amount: ₹${deposit['amount']}"),
                        Text("Interest Rate: ${deposit['interestRate']}%"),
                        Text("Interest / Year: ₹${deposit['yearlyInterest']}"),
                        Text("Start: ${deposit['startDate'] ?? ''}"),
                        Text("Maturity: ${deposit['maturityDate'] ?? ''}"),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddDepositScreen(deposit: deposit),
                              ),
                            );

                            loadDeposits();
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteDeposit(deposit['id']);
                            loadDeposits();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
