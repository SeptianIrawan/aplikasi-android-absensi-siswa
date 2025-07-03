import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_absensi_sederhana/student_model.dart';
import 'package:aplikasi_absensi_sederhana/firestore_service.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student; // Null jika menambah, ada jika mengedit

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _classNameController;
  late FirestoreService _firestoreService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not authenticated, perhaps navigate back to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk mengakses fitur ini.')),
        );
      });
      return;
    }
    _firestoreService = FirestoreService(userId: user.uid);

    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _studentIdController = TextEditingController(text: widget.student?.studentId ?? '');
    _classNameController = TextEditingController(text: widget.student?.className ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newStudent = Student(
        id: widget.student?.id, // Pertahankan ID jika mengedit
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        className: _classNameController.text.trim(),
      );

      try {
        if (widget.student == null) {
          await _firestoreService.addStudent(newStudent);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Siswa berhasil ditambahkan!')),
            );
          }
        } else {
          await _firestoreService.updateStudent(newStudent);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Siswa berhasil diperbarui!')),
            );
          }
        }
        if (mounted) {
          Navigator.of(context).pop(); // Kembali ke daftar siswa
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan siswa: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Siswa' : 'Tambah Siswa Baru',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Perbarui Detail Siswa' : 'Masukkan Detail Siswa Baru',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Budi Santoso',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Induk Siswa (NIS)',
                  hintText: 'Contoh: 123456789',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIS tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  hintText: 'Contoh: X IPA 1',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kelas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveStudent,
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH SISWA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
