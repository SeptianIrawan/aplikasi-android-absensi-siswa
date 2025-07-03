import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String? id; // ID dokumen Firestore
  String name;
  String studentId; // Nomor Induk Siswa
  String className; // Kelas siswa
  String? imageUrl; // Opsional: URL gambar profil siswa

  Student({
    this.id,
    required this.name,
    required this.studentId,
    required this.className,
    this.imageUrl,
  });

  // Factory constructor untuk membuat objek Student dari Firestore DocumentSnapshot
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      className: data['className'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  // Metode untuk mengkonversi objek Student ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'studentId': studentId,
      'className': className,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(), // Untuk sorting atau tracking waktu
    };
  }
}
