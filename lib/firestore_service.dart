import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_absensi_sederhana/student_model.dart';
import 'package:aplikasi_absensi_sederhana/subject_model.dart';
import 'package:aplikasi_absensi_sederhana/attendance_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId; // ID pengguna yang sedang login

  FirestoreService({required this.userId});

  // Path koleksi untuk data pribadi pengguna
  // Mengikuti aturan keamanan Firestore: /artifacts/{appId}/users/{userId}/{collectionName}
  CollectionReference<Map<String, dynamic>> _getCollection(String collectionName) {
    // FIX: Mengatasi peringatan '!= null' dan menyederhanakan logika appId.
    // 'String.fromEnvironment' tidak pernah mengembalikan null.
    // Jika 'APP_ID' tidak diatur sebagai environment variable saat kompilasi,
    // ia akan mengembalikan string kosong ('').
    final String appIdFromEnv = const String.fromEnvironment('APP_ID', defaultValue: '');
    final String appId = appIdFromEnv.isNotEmpty ? appIdFromEnv : 'default-app-id';

    return _db.collection('artifacts').doc(appId).collection('users').doc(userId).collection(collectionName);
  }

  // --- Operasi Siswa ---
  Future<List<Student>> getStudents() async {
    try {
      QuerySnapshot snapshot = await _getCollection('students').get();
      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      await _getCollection('students').add(student.toFirestore());
    } catch (e) {
      print('Error adding student: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      if (student.id == null) {
        throw Exception('Student ID cannot be null for update.');
      }
      await _getCollection('students').doc(student.id).update(student.toFirestore());
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _getCollection('students').doc(studentId).delete();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  // --- Operasi Mata Pelajaran ---
  Future<List<Subject>> getSubjects() async {
    try {
      QuerySnapshot snapshot = await _getCollection('subjects').get();
      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting subjects: $e');
      return [];
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _getCollection('subjects').add(subject.toFirestore());
    } catch (e) {
      print('Error adding subject: $e');
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      if (subject.id == null) {
        throw Exception('Subject ID cannot be null for update.');
      }
      await _getCollection('subjects').doc(subject.id).update(subject.toFirestore());
    } catch (e) {
      print('Error updating subject: $e');
      rethrow;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _getCollection('subjects').doc(subjectId).delete();
    } catch (e) {
      print('Error deleting subject: $e');
      rethrow;
    }
  }

  // --- Operasi Absensi ---
  Future<void> addAttendance(Attendance attendance) async {
    try {
      await _getCollection('attendance').add(attendance.toFirestore());
    } catch (e) {
      print('Error adding attendance: $e');
      rethrow;
    }
  }

  // Metode baru untuk memperbarui absensi (termasuk status dan catatan)
  Future<void> updateAttendance(Attendance attendance) async {
    try {
      if (attendance.id == null) {
        throw Exception('Attendance ID cannot be null for update.');
      }
      await _getCollection('attendance').doc(attendance.id).update(attendance.toFirestore());
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }

  // Mendapatkan absensi untuk mata pelajaran dan tanggal tertentu
  Future<List<Attendance>> getAttendanceForSubjectAndDate(String subjectId, DateTime date) async {
    try {
      // Untuk query berdasarkan tanggal, kita perlu rentang waktu dari awal hingga akhir hari
      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _getCollection('attendance')
          .where('subjectId', isEqualTo: subjectId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();
      return snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting attendance: $e');
      return [];
    }
  }

  // Mendapatkan semua riwayat absensi untuk tampilan (opsional, bisa difilter di UI)
  Future<List<Attendance>> getAllAttendance() async {
    try {
      QuerySnapshot snapshot = await _getCollection('attendance').get();
      return snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all attendance: $e');
      return [];
    }
  }
}
