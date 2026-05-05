import 'package:flutter/material.dart';
import 'package:faceattend/services/face_recognition_service.dart';
import 'package:faceattend/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DatabaseHelper().database; // Initialize database
  
  // Load face recognition model (in production, bundle with app)
  // await FaceRecognitionService().initialize('assets/models/mobilefacenet.tflite', 'assets/models/labels.txt');
  
  runApp(const FaceAttendApp());
}

class FaceAttendApp extends StatelessWidget {
  const FaceAttendApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceAttend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FaceAttend Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Welcome to FaceAttend',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement login navigation
              },
              child: const Text('Login as Employee'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement admin login navigation
              },
              child: const Text('Login as Admin'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}