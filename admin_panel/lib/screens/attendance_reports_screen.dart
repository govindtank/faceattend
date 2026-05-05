import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceService>().loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'From: ${_startDate != null ? DateFormat('MMM dd').format(_startDate!) : 'Any'} '
                    'To: ${_endDate != null ? DateFormat('MMM dd').format(_endDate!) : 'Any'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      attendanceService.loadAttendance();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: attendanceService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceService.records.isEmpty
                    ? const Center(child: Text('No attendance records found'))
                    : RefreshIndicator(
                        onRefresh: () => attendanceService.loadAttendance(),
                        child: ListView.builder(
                          itemCount: attendanceService.records.length,
                          itemBuilder: (context, index) {
                            final record = attendanceService.records[index];
                            final isCheckIn = record.type == 'check_in';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCheckIn
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  child: Icon(
                                    isCheckIn
                                        ? Icons.login
                                        : Icons.logout,
                                    color: isCheckIn
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text('Employee: ${record.employeeId}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dateFormat.format(record.timestamp)),
                                    if (record.location.isNotEmpty)
                                      Text('Location: ${record.location}',
                                          style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCheckIn
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isCheckIn ? 'Check In' : 'Check Out',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isCheckIn
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() async {
    _startDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );

    if (!mounted) return;

    _endDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );

    if (!mounted) return;

    if (_startDate != null || _endDate != null) {
      context.read<AttendanceService>().loadAttendance();
    }
  }
}
