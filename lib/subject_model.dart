import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  String? id; // ID dokumen Firestore
  String name;
  String code; // Kode mata pelajaran (misal: MTK-001)
  String description;

  Subject({
    this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  // Factory constructor untuk membuat objek Subject dari Firestore DocumentSnapshot
  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Metode untuk mengkonversi objek Subject ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(), // Untuk sorting atau tracking waktu
    };
  }
}
