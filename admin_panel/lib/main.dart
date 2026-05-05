import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_panel/services/auth_service.dart';
import 'package:admin_panel/services/employee_service.dart';
import 'package:admin_panel/services/attendance_service.dart';
import 'package:admin_panel/screens/login_screen.dart';
import 'package:admin_panel/screens/dashboard_screen.dart';
import 'package:admin_panel/screens/employee_management_screen.dart';
import 'package:admin_panel/screens/attendance_reports_screen.dart';
import 'package:admin_panel/screens/settings_screen.dart';

void main() {
  runApp(const FaceAttendAdminApp());
}

class FaceAttendAdminApp extends StatelessWidget {
  const FaceAttendAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EmployeeService()),
        ChangeNotifierProvider(create: (_) => AttendanceService()),
      ],
      child: MaterialApp(
        title: 'FaceAttend Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/employees': (context) => const EmployeeManagementScreen(),
          '/attendance': (context) => const AttendanceReportsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
