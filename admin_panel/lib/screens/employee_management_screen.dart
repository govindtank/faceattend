import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/employee_service.dart';
import '../models/employee_model.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeService>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeService = Provider.of<EmployeeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: employeeService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : employeeService.employees.isEmpty
              ? const Center(child: Text('No employees found'))
              : ListView.builder(
                  itemCount: employeeService.employees.length,
                  itemBuilder: (context, index) {
                    final employee = employeeService.employees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            employee.name.isNotEmpty
                                ? employee.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(employee.name),
                        subtitle: Text(
                            '${employee.department} — ${employee.position}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showEditDialog(context, employee),
                            ),
                            Switch(
                              value: employee.isActive,
                              onChanged: (value) async {
                                employee.isActive = value;
                                await employeeService.addEmployee(employee);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final deptController = TextEditingController();
    final posController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department')),
              const SizedBox(height: 8),
              TextField(
                  controller: posController,
                  decoration: const InputDecoration(labelText: 'Position')),
              const SizedBox(height: 8),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final employee = Employee(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                department: deptController.text,
                position: posController.text,
                email: emailController.text,
                phone: phoneController.text,
                createdAt: DateTime.now(),
              );
              await context.read<EmployeeService>().addEmployee(employee);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final deptController = TextEditingController(text: employee.department);
    final posController = TextEditingController(text: employee.position);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department')),
              const SizedBox(height: 8),
              TextField(
                  controller: posController,
                  decoration: const InputDecoration(labelText: 'Position')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = Employee(
                id: employee.id,
                name: nameController.text,
                department: deptController.text,
                position: posController.text,
                email: employee.email,
                phone: employee.phone,
                createdAt: employee.createdAt,
                isActive: employee.isActive,
              );
              await context.read<EmployeeService>().addEmployee(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
