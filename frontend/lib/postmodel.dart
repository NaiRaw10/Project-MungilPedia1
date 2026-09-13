class Post {
  final int id;
  final String judul;
  final String deskripsi;
  final String? karakteristik;
  final String gambar;
  final int? kategoriId;

  Post({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.karakteristik,
    required this.gambar,
    this.kategoriId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      karakteristik: json['karakteristik'],
      gambar: json['gambar'] ?? '',
      kategoriId: json['kategori_id'] != null
          ? (json['kategori_id'] is int
              ? json['kategori_id']
              : int.tryParse(json['kategori_id'].toString()))
          : (json['id_kategori'] != null
              ? (json['id_kategori'] is int
                  ? json['id_kategori']
                  : int.tryParse(json['id_kategori'].toString()))
              : null),
    );
  }
}