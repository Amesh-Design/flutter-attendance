import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_attendence/homescreen.dart';
import 'package:intl/intl.dart';

class CreateEmployeePage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  CreateEmployeePage({Key? key}) : super(key: key);

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000'));

  Future<void> _createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await _dio.post('/create', data: employeeData);
      debugPrint('Employee created successfully: ${response.data}');
    } catch (e) {
      debugPrint('Error creating employee: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      // Format date as DD-MM-YYYY
      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
      _dobController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Employee'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Employee Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration:  InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration:  InputDecoration(
                labelText: 'Date of Birth (DD-MM-YYYY)',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration:  InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 10),
               TextField(
              controller: _designationController,
              decoration:  InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _salaryController,
              decoration: InputDecoration(
                labelText: 'Salary',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final data = {
                    'Employee_ID': _idController.text,
                    'Employee_Name': _nameController.text,
                    'DOB': _dobController.text,
                    'Email': _emailController.text,
                    'Designation': _designationController.text,
                    'Salary': int.tryParse(_salaryController.text) ?? 0,
                  };
                  await _createEmployee(data);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Homescreen()),
                  );
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
