class Postingan {
  final int idPost;
  final int idUser;
  final String isiPost;
  final String? jenisPost;
  final String? fileMedia;
  final String namaLengkap;
  final String username;
  final String? fotoProfil;
  final String dibuatPada;
  int totalSuka;
  final int totalKomen;
  bool sudahSuka;

  Postingan({
    required this.idPost,
    required this.idUser,
    required this.isiPost,
    this.jenisPost,
    this.fileMedia,
    required this.namaLengkap,
    required this.username,
    this.fotoProfil,
    required this.dibuatPada,
    required this.totalSuka,
    required this.totalKomen,
    required this.sudahSuka,
  });

  factory Postingan.fromJson(Map<String, dynamic> json) {
    return Postingan(
      idPost: json['id_post'],
      idUser: json['id_user'],
      isiPost: json['isi_post'] ?? '',
      jenisPost: json['jenis_post'],
      fileMedia: json['file_media'],
      namaLengkap: json['nama_lengkap'] ?? '',
      username: json['username'] ?? '',
      fotoProfil: json['foto_profil'],
      dibuatPada: json['dibuat_pada'] ?? '',
      totalSuka: json['total_suka'] ?? 0,
      totalKomen: json['total_komen'] ?? 0,
      sudahSuka: json['sudah_suka'] ?? false,
    );
  }
}
