import 'package:flutter/material.dart';
import '../database/database_helper.dart';
class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({super.key});

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {

  final _formKey = GlobalKey<FormState>();

  final bankController = TextEditingController();
  final accountController = TextEditingController();
  final amountController = TextEditingController();

  DateTime? startDate;
  DateTime? maturityDate;

  String depositType = "FD";

  Future<void> pickDate(BuildContext context, bool isStartDate) async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          maturityDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Deposit"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [

                      TextFormField(
                        controller: bankController,
                        decoration: const InputDecoration(
                          labelText: "Bank Name",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter bank name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: accountController,
                        decoration: const InputDecoration(
                          labelText: "Account Number",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter account number";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: depositType,
                        items: const [
                          DropdownMenuItem(value: "FD", child: Text("FD")),
                          DropdownMenuItem(value: "RD", child: Text("RD")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            depositType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Deposit Type",
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter amount";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      ListTile(
                        title: const Text("Start Date"),
                        subtitle: Text(
                          startDate == null
                              ? "Select date"
                              : startDate.toString().split(" ")[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, true),
                      ),

                      ListTile(
                        title: const Text("Maturity Date"),
                        subtitle: Text(
                          maturityDate == null
                              ? "Select date"
                              : maturityDate.toString().split(" ")[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, false),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {

                              double? amount = double.tryParse(amountController.text);

                              if (amount == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid amount")),
                                );
                                return;
                              }

                              try {

                                await DatabaseHelper.instance.insertDeposit({
                                  'bankName': bankController.text,
                                  'username': accountController.text,
                                  'depositType': depositType,
                                  'amount': amount,
                                  'startDate': startDate?.toString(),
                                  'maturityDate': maturityDate?.toString(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Deposit Saved")),
                                );

                                Navigator.pop(context);

                              } catch (e, stackTrace) {

                                if (e.toString().contains("UNIQUE")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Duplicate deposit not allowed")),
                                  );
                                } else {
                                  print(e);
                                  print(stackTrace);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }

                              }

                            }

                          },
                          child: const Text("Save Deposit"),
                        ),
                      )

                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}