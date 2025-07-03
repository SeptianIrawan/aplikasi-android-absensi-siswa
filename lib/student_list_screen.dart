import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/student_model.dart';
import 'package:aplikasi_absensi_sederhana/firestore_service.dart';
import 'package:aplikasi_absensi_sederhana/student_form_screen.dart';
import 'package:aplikasi_absensi_sederhana/dashboard_screen.dart'; // Import DashboardScreen
import 'package:aplikasi_absensi_sederhana/subject_list_screen.dart'; // Import SubjectListScreen
import 'package:aplikasi_absensi_sederhana/attendance_subject_selection_screen.dart'; // Import AttendanceSubjectSelectionScreen
import 'package:aplikasi_absensi_sederhana/profile_screen.dart'; // Import ProfileScreen
import 'package:aplikasi_absensi_sederhana/login_screen.dart'; // Import LoginScreen

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late FirestoreService _firestoreService;
  List<Student> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser; // Tambahkan untuk menyimpan info pengguna

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Dapatkan pengguna saat ini
    if (_currentUser != null) {
      _firestoreService = FirestoreService(userId: _currentUser!.uid);
      _fetchStudents();
    } else {
      setState(() {
        _errorMessage = 'Pengguna tidak terautentikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final students = await _firestoreService.getStudents();
      setState(() {
        _students = students;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data siswa: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus siswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteStudent(studentId);
        _fetchStudents(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Siswa berhasil dihapus!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus siswa: $e')),
          );
        }
      }
    }
  }

  Future<void> _logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Siswa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: Drawer( // Tambahkan Drawer di sini
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                _currentUser?.displayName ?? 'Guru',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                _currentUser?.email ?? 'Tidak ada email',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blueAccent,
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text('Dashboard', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushReplacement( // Gunakan pushReplacement agar tidak menumpuk halaman
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text('Data Siswa', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Sudah di halaman ini, tidak perlu navigasi
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: Text('Data Mata Pelajaran', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SubjectListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text('Absensi', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceSubjectSelectionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Profil Guru', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: GoogleFonts.poppins(color: Colors.redAccent)),
              onTap: () => _logoutUser(context),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt_outlined, size: 80, color: Colors.blueGrey[300]),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada data siswa.',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.blueGrey[600]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StudentFormScreen()),
                              );
                              _fetchStudents(); // Refresh after adding
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Siswa Baru'),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent, // Menggunakan shade yang lebih terang
                              child: Text(
                                student.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            title: Text(
                              student.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'NIS: ${student.studentId} | Kelas: ${student.className}',
                              style: GoogleFonts.poppins(color: Colors.blueGrey[600]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentFormScreen(student: student),
                                      ),
                                    );
                                    _fetchStudents(); // Refresh after editing
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(student.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: _students.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentFormScreen()),
                );
                _fetchStudents(); // Refresh after adding
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Siswa'),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            )
          : null, // FAB hanya muncul jika daftar tidak kosong
    );
  }
}
