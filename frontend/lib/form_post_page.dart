import 'package:flutter/material.dart';
import 'postmodel.dart';
import '../services/api_service.dart';

class FormPostPage extends StatefulWidget {
  final Post? post; // Jika null = Mode Tambah, Jika terisi = Mode Edit

  const FormPostPage({super.key, this.post});

  @override
  State<FormPostPage> createState() => _FormPostPageState();
}

class _FormPostPageState extends State<FormPostPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _karakteristikController;
  late TextEditingController _gambarController;

  int? _selectedKategoriId;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data lama (jika mode edit)
    _judulController = TextEditingController(text: widget.post?.judul ?? '');
    _deskripsiController = TextEditingController(text: widget.post?.deskripsi ?? '');
    _karakteristikController = TextEditingController(text: widget.post?.karakteristik ?? '');
    _gambarController = TextEditingController(text: widget.post?.gambar ?? '');
    _selectedKategoriId = widget.post?.kategoriId;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.fetchCategories();
      setState(() {
        _categories = data;
        _isLoadingCategories = false;
        // Set default kategori jika mode tambah
        if (_selectedKategoriId == null && _categories.isNotEmpty) {
          _selectedKategoriId = _categories.first['id'];
        }
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat kategori: $e")),
      );
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _karakteristikController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih kategori terlebih dahulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "kategoriId": _selectedKategoriId,
      "judul": _judulController.text,
      "deskripsi": _deskripsiController.text,
      "karakteristik": _karakteristikController.text,
      "gambar": _gambarController.text,
    };

    bool isSuccess = false;

    if (widget.post == null) {
      // Mode Tambah (Create)
      isSuccess = await ApiService.createPost(payload);
    } else {
      // Mode Edit (Update)
      isSuccess = await ApiService.updatePost(widget.post!.id, payload);
    }

    setState(() => _isSubmitting = false);

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.post == null
              ? "Artikel berhasil ditambahkan!"
              : "Artikel berhasil diperbarui!"),
        ),
      );
      Navigator.pop(context, true); // Kembali & kirim sinyal 'true' untuk reload
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data artikel.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.post != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Artikel" : "Tambah Artikel Baru"),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown Kategori
                    DropdownButtonFormField<int>(
                      value: _selectedKategoriId,
                      decoration: const InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map<DropdownMenuItem<int>>((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['namaKategori']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedKategoriId = val;
                        });
                      },
                      validator: (val) => val == null ? "Kategori wajib dipilih" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Judul
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: "Judul Artikel",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Judul wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Deskripsi
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Deskripsi wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Karakteristik
                    TextFormField(
                      controller: _karakteristikController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Karakteristik (Opsional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Nama File Gambar
                    TextFormField(
                      controller: _gambarController,
                      decoration: const InputDecoration(
                        labelText: "Nama File Gambar (contoh: hamster(S))",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditMode ? "Perbarui Artikel" : "Simpan Artikel",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}