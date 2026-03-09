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

  List<String> banks = ["TGGVB", "BOB", "Cherukuri"];

  String? selectedBank;

  List<String> names = [
    "Narayana & Sowmya",
    "Narayana & Sunitha",
    "Narayana & Saiteja",
    "Narayana",
    "Saiteja",
    "Neha",
  ];

  String? selectedName;
  final interestController = TextEditingController();
  double yearlyInterest = 0;
  DateTime? startDate;
  DateTime? maturityDate;

  String depositType = "FD";

  Future<void> pickDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
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

  void calculateInterest() {
    double principal = double.tryParse(amountController.text) ?? 0;

    double rate = double.tryParse(interestController.text) ?? 0;

    setState(() {
      yearlyInterest = (principal * rate) / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Deposit")),

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
                      DropdownButtonFormField<String>(
                        initialValue: selectedBank,
                        decoration: const InputDecoration(
                          labelText: "Bank Name",
                          border: OutlineInputBorder(),
                        ),
                        items: banks.map((bank) {
                          return DropdownMenuItem(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBank = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select bank";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: selectedName,
                        decoration: const InputDecoration(
                          labelText: "Depositor Name",
                          border: OutlineInputBorder(),
                        ),
                        items: names.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select name";
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
                        controller: interestController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Interest % per year",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          calculateInterest();
                        },
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Interest per year: ₹${yearlyInterest.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Amount"),
                        onChanged: (value) {
                          calculateInterest();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter amount";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      ListTile(
                        title: const Text("Start Date *"),
                        subtitle: Text(
                          startDate == null
                              ? "Select date"
                              : startDate.toString().split(" ")[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, true),
                      ),

                      ListTile(
                        title: const Text("Maturity Date *"),
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
                              if (selectedBank == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a bank"),
                                  ),
                                );
                                return;
                              }

                              if (selectedName == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a name"),
                                  ),
                                );
                                return;
                              }
                              double? amount = double.tryParse(
                                amountController.text,
                              );

                              if (amount == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid amount"),
                                  ),
                                );
                                return;
                              }

                              if (startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select start date"),
                                  ),
                                );
                                return;
                              }

                              if (maturityDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select maturity date",
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                await DatabaseHelper.instance.insertDeposit({
                                  'bankName': selectedBank,
                                  'depositor': selectedName,
                                  'depositType': depositType,
                                  'amount': amount,
                                  'startDate': startDate?.toString(),
                                  'interestRate': interestController.text,
                                  'yearlyInterest': yearlyInterest,
                                  'maturityDate': maturityDate?.toString(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Deposit Saved"),
                                  ),
                                );

                                Navigator.pop(context);
                              } catch (e, stackTrace) {
                                if (e.toString().contains("UNIQUE")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Duplicate deposit not allowed",
                                      ),
                                    ),
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
}
