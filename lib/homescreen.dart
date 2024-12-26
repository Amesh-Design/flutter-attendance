import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_attendence/addemployee.dart';
import 'package:flutter_attendence/editemployee.dart';
import 'package:flutter_attendence/history.dart';
import 'package:http/http.dart' as http;


class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<dynamic> employees = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/read'));

      if (response.statusCode == 200) {
        setState(() {
          employees = json.decode(response.body);
          isLoading = false;
          employees.sort((a, b) => a['Employee_ID'].compareTo(b['Employee_ID']));
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load employees';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

Future<void> _checkIn(String employeeId, int index) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/attendance/checkin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Employee_ID': employeeId,
        'status': 'Present',
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Update the employee's check-in status in the list
      setState(() {
        employees[index]['checkedIn'] = true;
      });
      _showSuccessPopup('Checked in successfully for $employeeId');
    } else {
      _showMessage('Already checked in Today!');
    }
  } catch (e) {
    _showMessage('Error during check-in: $e');
  }
}



  Future<void> _checkOut(String employeeId) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/attendance/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Employee_ID': employeeId, 'time': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        _showMessage('Check-out successful for $employeeId');
      } else {
        _showMessage('Already check out marked Today! ');
      }
    } catch (e) {
      _showMessage('Error during check-out: $e');
    }
  }

  Future<void> _markAsLeave(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/attendance/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Employee_ID': employeeId,
          'status': 'Absent',
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('Marked as absent for $employeeId');
      } else {
        _showMessage('Failed to mark as absent');
      }
    } catch (e) {
      _showMessage('Error marking as absent: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
    void _editEmployee(Map<String, dynamic> employee) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditEmployeePage(employee: employee),
    ),
  );

  if (result == true) {
    _fetchEmployees(); // Refresh the employee list on successful update
  }
}


  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'images/right anime.gif', // Replace with your Lottie file path
                height: 100,
                width: 100,
                
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                 /*Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Homescreen()),
                  );*/
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            const Text(
              "Employees",
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEmployeePage()),
                );
              },
              color: Colors.white,
              iconSize: 30,
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pengwin Tech Solutions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Attendance System',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : 'No employees found.'))
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
  margin: const EdgeInsets.all(8.0),
  child: Stack(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    employee['Employee_Name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  employee['Employee_Name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Employee ID: ${employee['Employee_ID'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              'Date of Birth: ${employee['DOB'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${employee['Email'] ?? 'No Email Available'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
             Text(
              'Designation: ${employee['Designation'] ?? 'No Designation Available'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10,),
           /* Text(
              'Salary: \$${employee['Salary'] ?? '0'}',
              style: const TextStyle(fontSize: 16),
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
          ElevatedButton(
         onPressed: () => _checkIn(employee['Employee_ID'], index),
         child: const Text('Check In'),
          style: ButtonStyle(
           backgroundColor: WidgetStateProperty.all(
              employee['checkedIn'] ?? false ? Colors.green : Colors.blue,
    ),
  ),
),


                ElevatedButton(
                  onPressed: () => _checkOut(employee['Employee_ID']),
                  child: const Text('Check Out'),
                ),
                ElevatedButton(
                  onPressed: () => _markAsLeave(employee['Employee_ID']),
                  child: const Text('Leave'),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            _editEmployee(employee);
          },
        ),
      ),
      Positioned(
        top: 8,
        right: 55,
        child: IconButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => AttendanceHistoryPage( employee: employee,),));
        },
       icon: const Icon(Icons.history,color: Colors.redAccent,),
      
       ))
    ],
  ),
);

                  },
                ),
    );
  }
}
