import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/dashboard_screen.dart'; // Import DashboardScreen
import 'package:aplikasi_absensi_sederhana/student_list_screen.dart'; // Import StudentListScreen
import 'package:aplikasi_absensi_sederhana/subject_list_screen.dart'; // Import SubjectListScreen
import 'package:aplikasi_absensi_sederhana/attendance_subject_selection_screen.dart'; // Import AttendanceSubjectSelectionScreen
import 'package:aplikasi_absensi_sederhana/login_screen.dart'; // Import LoginScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          'Profil Guru',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple, // Warna AppBar untuk profil
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: Drawer( // Tambahkan Drawer di sini
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'Guru',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'Tidak ada email',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.deepPurple, // Sesuaikan warna ikon dengan tema
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.deepPurple, // Sesuaikan warna header dengan tema
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
                Navigator.pop(context); // Tutup drawer
                // Sudah di halaman ini, tidak perlu navigasi
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple.shade50, // Menggunakan shade yang lebih terang
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.displayName ?? 'Wilrenty',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.blueGrey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.verified_user, color: Colors.deepPurple),
                    title: Text(
                      'Status Autentikasi',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      user?.emailVerified == true ? 'Email Terverifikasi' : 'Email Belum Terverifikasi',
                      style: GoogleFonts.poppins(color: Colors.blueGrey[600]),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    title: Text(
                      'Bergabung Sejak',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      user?.metadata.creationTime != null
                          ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                          : 'Tidak Diketahui',
                      style: GoogleFonts.poppins(color: Colors.blueGrey[600]),
                    ),
                  ),
                  // Anda bisa menambahkan informasi profil lainnya di sini
                  // Misalnya, jika Anda menyimpan nama lengkap, NIP, dll. di Firestore
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
