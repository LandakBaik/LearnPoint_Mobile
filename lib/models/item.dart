import 'package:flutter/material.dart';

class ItemModel {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;

  const ItemModel({
    required this.name,
    required this.desc,
    required this.icon,
    required this.color,
  });
}

final List<ItemModel> item = [
  ItemModel(
    name: 'Perisai Bintang',
    desc: 'Melindungi poinmu saat salah menjawab kuis.',
    icon: Icons.shield,
    color: Colors.amber,
  ),
  ItemModel(
    name: 'Ramuan Waktu',
    desc: 'Menambah waktu 30 detik saat mengerjakan kuis.',
    icon: Icons.hourglass_bottom,
    color: Colors.cyan,
  ),
  ItemModel(
    name: 'Pedang Cahaya',
    desc: 'Menggandakan poin pada soal berikutnya.',
    icon: Icons.flash_on,
    color: Colors.orangeAccent,
  ),
  ItemModel(
    name: 'Buku Petunjuk',
    desc: 'Menghilangkan 2 pilihan jawaban yang salah.',
    icon: Icons.menu_book,
    color: Colors.lightGreenAccent,
  ),
];
