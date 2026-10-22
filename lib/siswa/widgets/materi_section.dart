
import 'package:flutter/material.dart';

class MateriSectionWidget extends StatefulWidget {
  const MateriSectionWidget({super.key});

  @override
  State<MateriSectionWidget> createState() =>
      _MateriSectionWidgetState();
}

class _MateriSectionWidgetState extends State<MateriSectionWidget> {
  int selectedIndex = 0;

  final List<String> semesters = [
    'Semua',
    'Semester 1',
    'Semester 2',
  ];
  final List<String> materi = [
    'Persamaan Linear',
    'Bangun Ruang',
    'Statistika',
    'Peluang',
    'Aljabar',
    'Bilangan Bulat',
    ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Materi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28233E),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              'Pilih materi yang ingin kamu pelajari',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Tab semester
          Container(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6336ED)
                            : const Color(0xFFF1EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        semesters[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6336ED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),


            Padding(
            padding: const EdgeInsets.only(top: 24),
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                ),

                itemCount: materi.length,

                itemBuilder: (context, index) {
                return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF6336ED),
                        size: 32,
                        ),

                        Text(
                        materi[index],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28233E),
                        ),
                        ),

                        const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF6336ED),
                        ),
                        ),
                    ],
                    ),
                );
                },
            ),
            ),
        ],
      ),
    );
  }
}
