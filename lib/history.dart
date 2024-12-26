import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final Map<String, dynamic> employee;  // Change to Map

  const AttendanceHistoryPage({super.key, required this.employee});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  bool isLoading = false;
  List<Map<String, String>> attendanceHistory = [];
  TextEditingController _dateController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      // Format date as YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      _dateController.text = formattedDate;
    }
  }

  // Clear date function
  void _clearDate() {
    setState(() {
      _dateController.clear();
      _monthController.clear();
      _yearController.clear();
    });
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      isLoading = true;
    });

    // Get the employee ID from the map
    String employeeId = widget.employee['Employee_ID'].toString(); // Adjust to access the employee ID

    // Construct the URL with filters
    String url = 'http://10.0.2.2:5000/attendance/$employeeId';
    String dateFilter = _dateController.text;
    String monthFilter = _monthController.text;
    String yearFilter = _yearController.text;

    if (dateFilter.isNotEmpty) {
      url += '?date=$dateFilter';
    }
    if (monthFilter.isNotEmpty) {
      url += (url.contains('?') ? '&' : '?') + 'month=$monthFilter';
    }
    if (yearFilter.isNotEmpty) {
      url += (url.contains('?') ? '&' : '?') + 'year=$yearFilter';
    }

    try {
      final response = await http.get(Uri.parse(url));
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          attendanceHistory = List<Map<String, String>>.from(
            data.map<Map<String, String>>((item) {
              return {
                'Date': item['Date'].toString(),
                'Status': item['Status'].toString(),
                'Check-In': item['Check_In']?.toString() ?? 'N/A',
                'Check-Out': item['Check_Out']?.toString() ?? 'N/A',
              };
            }),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch filtered attendance history')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
        title: const Text('Attendance History'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Select Date (YYYY-MM-DD)',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _monthController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Month (MM)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Year (YYYY)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _fetchAttendanceHistory,
                        child: const Text('Fetch Attendance History'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _clearDate,
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: attendanceHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(attendanceHistory[index]['Date']!,
                          style: const TextStyle(color: Colors.blueAccent,fontSize: 18),
                          ),
                          subtitle: Text(
                            '${attendanceHistory[index]['Status']} - Check-In: ${attendanceHistory[index]['Check-In']} - Check-Out: ${attendanceHistory[index]['Check-Out']}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
