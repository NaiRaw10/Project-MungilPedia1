create database db_hewanPengerat;
use db_hewanPengerat;

create table categories(
id				int auto_increment primary key,
namaKategori	varchar(100)
);

insert into categories (namaKategori) values
('Hamster'),
('Marmut'),
('Chinchilla');

create table posts(
id 				int auto_increment primary key,
kategoriId		int not null,
judul			varchar(255) not null,
deskripsi		text not null,
karakteristik	text,
gambar			varchar(255),
foreign key (kategoriId) references categories (id)
);

insert into posts (kategoriId, judul, deskripsi, karakteristik, gambar) values
(1, 'Hamster Syrian', 'Hamster bersikap soliter dan paling populer sebagai hewan peliharaan.', 'Ukuran tubuh relatif besar, gerakan cukup tenang, ramah.', 'hamster(S)'),
(1, 'Hamster Roborovski', 'Hamster dengan ukuran paling kecil dan sangat lincah.', 'Ukuran mini, bergerak cepat, pemalu.', 'hamster(R)'),
(2, 'Marmut American', 'Marmut American (American Shorthair) adalah jenis marmut paling populer dan paling banyak dipelihara. Ras ini dikenal memiliki daya tahan tubuh yang kuat dan perawatan yang relatif mudah.', 'Bulu lurus, pendek, dan sangat halus. Bentuk tubuh cenderung membulat, ramah, serta tenang sehingga cocok untuk pemula.', 'marmut(American)'),
(3, 'Chinchilla Standard Grey', 'Chinchilla dengan warna abu-abu klasik bernuansa lembut.', 'Bulu sangat tebal dan halus, butuh mandi pasir khusus.', 'chinchilla(Grey)');
