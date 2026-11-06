import 'package:flutter/material.dart';
import '../../models/materi_page.dart';
import '../../services/materi_preferences_service.dart';
import '../../services/materi_service.dart';
import '../detail_materi.dart';

class MateriSectionWidget extends StatefulWidget {
  final int? mapelId;
  final String subjectName;

  const MateriSectionWidget({
    super.key,
    this.mapelId,
    this.subjectName = 'Matematika',
  });

  @override
  State<MateriSectionWidget> createState() => _MateriSectionWidgetState();
}

class _MateriSectionWidgetState extends State<MateriSectionWidget> {
  int selectedIndex = 0;
  Set<String> completedKeys = {};
  Set<String> bookmarkedKeys = {};
  List<MateriItemModel> apiMateriList = [];
  bool isLoadingApi = false;

  final List<String> semesters = [
    'Semua',
    'Semester 1',
    'Semester 2',
  ];

  final List<String> fallbackMateri = [
    'Persamaan Linear',
    'Bangun Ruang',
    'Statistika',
    'Peluang',
    'Aljabar',
    'Bilangan Bulat',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgressStates();
    _loadMateriFromApi();
  }

  Future<void> _loadProgressStates() async {
    final completed = await MateriPreferencesService.getCompletedKeys();
    final bookmarked = await MateriPreferencesService.getBookmarkedKeys();
    if (!mounted) return;
    setState(() {
      completedKeys = completed.toSet();
      bookmarkedKeys = bookmarked.toSet();
    });
  }

  Future<void> _loadMateriFromApi() async {
    if (widget.mapelId == null) return;
    setState(() {
      isLoadingApi = true;
    });
    final items = await MateriService.fetchMateriPerMapel(widget.mapelId!);
    if (!mounted) return;
    setState(() {
      apiMateriList = items;
      isLoadingApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool useApiData = apiMateriList.isNotEmpty;
    final int itemCount =
        useApiData ? apiMateriList.length : fallbackMateri.length;

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
          SizedBox(
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
            child: isLoadingApi
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final MateriItemModel? apiItem =
                          useApiData ? apiMateriList[index] : null;
                      final String title =
                          apiItem?.judul ?? fallbackMateri[index];

                      final itemKey = MateriPreferencesService.getMateriKey(
                        widget.subjectName,
                        title,
                      );
                      final isCompleted = completedKeys.contains(itemKey);
                      final isBookmarked = bookmarkedKeys.contains(itemKey);

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMateriPage(
                                title: title,
                                subject: widget.subjectName,
                                materiItem: apiItem,
                              ),
                            ),
                          );
                          _loadProgressStates();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: Color(0xFF6336ED),
                                    size: 32,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isBookmarked)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(
                                            Icons.bookmark_rounded,
                                            color: Color(0xFF6336ED),
                                            size: 18,
                                          ),
                                        ),
                                      if (isCompleted)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF10B981),
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                              Text(
                                title,
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
