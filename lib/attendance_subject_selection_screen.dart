import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/subject_model.dart';
import 'package:aplikasi_absensi_sederhana/firestore_service.dart';
import 'package:aplikasi_absensi_sederhana/attendance_marking_screen.dart';
import 'package:aplikasi_absensi_sederhana/dashboard_screen.dart'; // Import DashboardScreen
import 'package:aplikasi_absensi_sederhana/student_list_screen.dart'; // Import StudentListScreen
import 'package:aplikasi_absensi_sederhana/subject_list_screen.dart'; // Import SubjectListScreen
import 'package:aplikasi_absensi_sederhana/profile_screen.dart'; // Import ProfileScreen
import 'package:aplikasi_absensi_sederhana/login_screen.dart'; // Import LoginScreen

class AttendanceSubjectSelectionScreen extends StatefulWidget {
  const AttendanceSubjectSelectionScreen({super.key});

  @override
  State<AttendanceSubjectSelectionScreen> createState() => _AttendanceSubjectSelectionScreenState();
}

class _AttendanceSubjectSelectionScreenState extends State<AttendanceSubjectSelectionScreen> {
  late FirestoreService _firestoreService;
  List<Subject> _subjects = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser; // Tambahkan untuk menyimpan info pengguna

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Dapatkan pengguna saat ini
    if (_currentUser != null) {
      _firestoreService = FirestoreService(userId: _currentUser!.uid);
      _fetchSubjects();
    } else {
      setState(() {
        _errorMessage = 'Pengguna tidak terautentikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final subjects = await _firestoreService.getSubjects();
      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar mata pelajaran: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Pilih Mata Pelajaran Absensi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange, // Warna AppBar untuk absensi
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
                  color: Colors.orange, // Sesuaikan warna ikon dengan tema
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.orange, // Sesuaikan warna header dengan tema
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentListScreen()),
                );
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
                Navigator.pop(context); // Tutup drawer
                // Sudah di halaman ini, tidak perlu navigasi
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
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _subjects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber, size: 80, color: Colors.blueGrey[300]),
                          const SizedBox(height: 10),
                          Text(
                            'Tidak ada mata pelajaran yang tersedia.',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.blueGrey[600]),
                          ),
                          Text(
                            'Silakan tambahkan mata pelajaran terlebih dahulu.',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade50, // Menggunakan shade yang lebih terang
                              child: Icon(Icons.book, color: Colors.orange),
                            ),
                            title: Text(
                              subject.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Kode: ${subject.code}',
                              style: GoogleFonts.poppins(color: Colors.blueGrey[600]),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.orange),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceMarkingScreen(subject: subject),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
