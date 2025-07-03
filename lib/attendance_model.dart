import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { hadir, izin, sakit, alfa }

class Attendance {
  String? id; // ID dokumen Firestore
  String studentId; // ID siswa dari Firestore
  String studentName; // Nama siswa (untuk kemudahan tampilan)
  String subjectId; // ID mata pelajaran dari Firestore
  String subjectName; // Nama mata pelajaran (untuk kemudahan tampilan)
  DateTime date; // Tanggal absensi
  AttendanceStatus status; // Status absensi (hadir, izin, sakit, alfa)
  String? notes; // Catatan tambahan

  Attendance({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.status,
    this.notes,
  });

  // Factory constructor untuk membuat objek Attendance dari Firestore DocumentSnapshot
  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => AttendanceStatus.alfa, // Default jika tidak ditemukan
      ),
      notes: data['notes'],
    );
  }

  // Metode untuk mengkonversi objek Attendance ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'date': Timestamp.fromDate(date),
      'status': status.toString().split('.').last, // Simpan sebagai string
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(), // Untuk sorting atau tracking waktu
    };
  }
}
