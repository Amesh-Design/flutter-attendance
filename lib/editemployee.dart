import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditEmployeePage extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EditEmployeePage({super.key, required this.employee});

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;
  late TextEditingController _salaryController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee['Employee_Name']);
    _dobController = TextEditingController(text: widget.employee['DOB']);
    _emailController = TextEditingController(text: widget.employee['Email']);
    _salaryController = TextEditingController(text: widget.employee['Salary'].toString());
  }

 Future<void> _updateEmployee() async {
  setState(() {
    isLoading = true;
  });

  String employeeId = widget.employee['Employee_ID'].toString();

  try {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/update/Employee_ID/$employeeId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Employee_Name': _nameController.text,
        'DOB': _dobController.text,
        'Email': _emailController.text,
        'Salary': double.parse(_salaryController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee updated successfully')),
      );
      Navigator.pop(context, true); // Return success to the previous screen
    } else if (response.statusCode == 400) {
      // Handle the specific "email already exists" error
      final responseBody = jsonDecode(response.body);
      if (responseBody['error'] == 'Email already exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The email is already in use by another employee.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update employee: ${response.body}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating employee: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employee'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(labelText: 'Date of Birth'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _salaryController,
                      decoration: const InputDecoration(labelText: 'Salary'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateEmployee,
                        child: const Text('Update Employee'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
