import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/subject_model.dart';
import 'package:aplikasi_absensi_sederhana/firestore_service.dart';
import 'package:aplikasi_absensi_sederhana/subject_form_screen.dart';
import 'package:aplikasi_absensi_sederhana/dashboard_screen.dart'; // Import DashboardScreen
import 'package:aplikasi_absensi_sederhana/student_list_screen.dart'; // Import StudentListScreen
import 'package:aplikasi_absensi_sederhana/attendance_subject_selection_screen.dart'; // Import AttendanceSubjectSelectionScreen
import 'package:aplikasi_absensi_sederhana/profile_screen.dart'; // Import ProfileScreen
import 'package:aplikasi_absensi_sederhana/login_screen.dart'; // Import LoginScreen

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
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
        _errorMessage = 'Gagal memuat data mata pelajaran: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSubject(String subjectId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus mata pelajaran ini?'),
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
        await _firestoreService.deleteSubject(subjectId);
        _fetchSubjects(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mata pelajaran berhasil dihapus!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus mata pelajaran: $e')),
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
          'Daftar Mata Pelajaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green, // Warna AppBar untuk mata pelajaran
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
                  color: Colors.green, // Sesuaikan warna ikon dengan tema
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.green, // Sesuaikan warna header dengan tema
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
                Navigator.pop(context); // Tutup drawer
                // Sudah di halaman ini, tidak perlu navigasi
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
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
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
                          Icon(Icons.book_outlined, size: 80, color: Colors.blueGrey[300]),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada data mata pelajaran.',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.blueGrey[600]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SubjectFormScreen()),
                              );
                              _fetchSubjects(); // Refresh after adding
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Mata Pelajaran Baru'),
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
                              backgroundColor: Colors.green.shade50, // Menggunakan shade yang lebih terang
                              child: Text(
                                subject.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            title: Text(
                              subject.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Kode: ${subject.code}\n${subject.description}',
                              style: GoogleFonts.poppins(color: Colors.blueGrey[600]),
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubjectFormScreen(subject: subject),
                                      ),
                                    );
                                    _fetchSubjects(); // Refresh after editing
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSubject(subject.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: _subjects.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubjectFormScreen()),
                );
                _fetchSubjects(); // Refresh after adding
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mata Pelajaran'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null, // FAB hanya muncul jika daftar tidak kosong
    );
  }
}
