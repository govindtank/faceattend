class Employee {
  final String id;
  final String name;
  final String department;
  final String position;
  final String email;
  final String phone;
  List<double>? faceTemplate; // Face embedding for recognition
  final DateTime createdAt;
  bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    this.email = '',
    this.phone = '',
    this.faceTemplate,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        department: json['department'] ?? '',
        position: json['position'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        faceTemplate: json['faceTemplate'] != null
            ? List<double>.from((json['faceTemplate'] as List).map((e) => (e as num).toDouble()))
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'position': position,
        'email': email,
        'phone': phone,
        'faceTemplate': faceTemplate,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };
}

class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime timestamp;
  final String type; // 'check_in' or 'check_out'
  final double confidence; // Recognition confidence
  final String location; // Optional: GPS or beacon info
  final String deviceId; // Device used for recognition

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.timestamp,
    required this.type,
    this.confidence = 0.0,
    this.location = '',
    this.deviceId = '',
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] ?? '',
        employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        type: json['type'] ?? 'check_in',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        location: json['location'] ?? '',
        deviceId: json['deviceId'] ?? json['device_id'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'confidence': confidence,
        'location': location,
        'deviceId': deviceId,
      };
}
