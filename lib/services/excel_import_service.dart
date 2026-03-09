import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';

Future<void> importExcelDeposits() async {

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) return;

  File file = File(result.files.single.path!);

  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  var sheet = excel.tables.values.first;

  for (int i = 1; i < sheet!.rows.length; i++) {

    var row = sheet.rows[i];

    String bankName = row[0]?.value.toString() ?? "";
    String depositor = row[1]?.value.toString() ?? "";
    String startDate = row[2]?.value.toString() ?? "";
    double amount = double.tryParse(row[3]?.value.toString() ?? "0") ?? 0;
    double interest = double.tryParse(row[4]?.value.toString() ?? "0") ?? 0;
    String maturityDate = row[5]?.value.toString() ?? "";

    double yearlyInterest = amount * interest / 100;

    await DatabaseHelper.instance.insertDeposit({
      'bankName': bankName,
      'depositor': depositor,
      'depositType': 'FD',
      'amount': amount,
      'interestRate': interest,
      'yearlyInterest': yearlyInterest,
      'startDate': startDate,
      'maturityDate': maturityDate,
    });
  }
}