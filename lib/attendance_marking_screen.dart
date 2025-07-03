import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/student_model.dart';
import 'package:aplikasi_absensi_sederhana/subject_model.dart';
import 'package:aplikasi_absensi_sederhana/attendance_model.dart';
import 'package:aplikasi_absensi_sederhana/firestore_service.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class AttendanceMarkingScreen extends StatefulWidget {
  final Subject subject;

  const AttendanceMarkingScreen({super.key, required this.subject});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  late FirestoreService _firestoreService;
  List<Student> _students = [];
  Map<String, AttendanceStatus> _attendanceStatus = {}; // studentId -> status
  Map<String, String> _attendanceNotes = {}; // studentId -> notes
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = FirestoreService(userId: user.uid);
      _fetchStudentsAndAttendance();
    } else {
      setState(() {
        _errorMessage = 'Pengguna tidak terautentikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStudentsAndAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final students = await _firestoreService.getStudents();
      final existingAttendance = await _firestoreService.getAttendanceForSubjectAndDate(
        widget.subject.id!,
        _selectedDate,
      );

      // Inisialisasi status absensi default atau dari data yang sudah ada
      final Map<String, AttendanceStatus> initialStatus = {};
      final Map<String, String> initialNotes = {};
      for (var student in students) {
        final foundAttendance = existingAttendance.firstWhere(
          (att) => att.studentId == student.id,
          orElse: () => Attendance(
            studentId: student.id!,
            studentName: student.name,
            subjectId: widget.subject.id!,
            subjectName: widget.subject.name,
            date: _selectedDate,
            status: AttendanceStatus.alfa, // Default Alfa
          ),
        );
        initialStatus[student.id!] = foundAttendance.status;
        initialNotes[student.id!] = foundAttendance.notes ?? '';
      }

      setState(() {
        _students = students;
        _attendanceStatus = initialStatus;
        _attendanceNotes = initialNotes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchStudentsAndAttendance(); // Muat ulang data absensi untuk tanggal baru
    }
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      for (var student in _students) {
        final status = _attendanceStatus[student.id!] ?? AttendanceStatus.alfa;
        final notes = _attendanceNotes[student.id!] ?? '';

        final existingAttendanceList = await _firestoreService.getAttendanceForSubjectAndDate(
          widget.subject.id!,
          _selectedDate,
        );
        final existingAttendance = existingAttendanceList.firstWhere(
          (att) => att.studentId == student.id,
          orElse: () => Attendance(
            studentId: student.id!,
            studentName: student.name,
            subjectId: widget.subject.id!,
            subjectName: widget.subject.name,
            date: _selectedDate,
            status: AttendanceStatus.alfa,
          ),
        );

        if (existingAttendance.id == null) {
          // Tambah baru
          await _firestoreService.addAttendance(
            Attendance(
              studentId: student.id!,
              studentName: student.name,
              subjectId: widget.subject.id!,
              subjectName: widget.subject.name,
              date: _selectedDate,
              status: status,
              notes: notes,
            ),
          );
        } else {
          // Update yang sudah ada
          // Gunakan metode updateAttendance yang baru
          await _firestoreService.updateAttendance(
            Attendance(
              id: existingAttendance.id, // Penting: sertakan ID dokumen
              studentId: student.id!,
              studentName: student.name,
              subjectId: widget.subject.id!,
              subjectName: widget.subject.name,
              date: _selectedDate,
              status: status,
              notes: notes,
            ),
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil disimpan!')),
        );
        Navigator.of(context).pop(); // Kembali setelah menyimpan
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan absensi: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          'Absensi ${widget.subject.name}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tanggal Absensi:',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            DateFormat('EEEE, dd MMMM', 'id_ID').format(_selectedDate), // Format tanggal lengkap
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.blueGrey[700]),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _students.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.blueGrey[300]),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Tidak ada siswa untuk mata pelajaran ini.',
                                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.blueGrey[600]),
                                  ),
                                  Text(
                                    'Silakan tambahkan siswa terlebih dahulu.',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey[500]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                        Text(
                                          'NIS: ${student.studentId} | Kelas: ${student.className}',
                                          style: GoogleFonts.poppins(color: Colors.blueGrey[600], fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: AttendanceStatus.values.map((status) {
                                            return ChoiceChip(
                                              label: Text(
                                                status.toString().split('.').last.toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  color: _attendanceStatus[student.id!] == status
                                                      ? Colors.white
                                                      : Colors.blueGrey[700],
                                                ),
                                              ),
                                              selected: _attendanceStatus[student.id!] == status,
                                              selectedColor: _getStatusColor(status),
                                              onSelected: (selected) {
                                                setState(() {
                                                  _attendanceStatus[student.id!] = status;
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: TextEditingController(text: _attendanceNotes[student.id!]),
                                          onChanged: (value) {
                                            _attendanceNotes[student.id!] = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Catatan (Opsional)',
                                            hintText: 'Misal: Izin karena sakit',
                                            prefixIcon: Icon(Icons.notes, color: Colors.blueGrey[400]),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveAttendance,
                          icon: const Icon(Icons.save),
                          label: Text(
                            _isLoading ? 'Menyimpan...' : 'SIMPAN ABSENSI',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.hadir:
        return Colors.green;
      case AttendanceStatus.izin:
        return Colors.blue;
      case AttendanceStatus.sakit:
        return Colors.amber.shade700;
      case AttendanceStatus.alfa:
        return Colors.red;
      // Default case dihapus karena semua enum sudah ditangani
    }
  }
}
