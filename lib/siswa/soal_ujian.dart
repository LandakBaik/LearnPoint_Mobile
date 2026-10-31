import 'package:flutter/material.dart';

// ============================================================
// COLORS - DESAIN LEARNPOINT TETAP MENGGUNAKAN PALET SEBELUMNYA
// ============================================================
const Color primaryBlue = Color(0xFF0757C9);
const Color darkText = Color(0xFF13233A);
const Color secondaryText = Color(0xFF596579);
const Color lightBlue = Color(0xFFEAF4FF);
const Color cardBlue = Color(0xFFF0F5FF);
const Color greenColor = Color(0xFF008A63);

// ============================================================
// MODEL SOAL
// ============================================================
enum QuestionType { uraian, single, multiple, matching }

class ExamQuestion {
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final List<String> correctAnswers;
  final List<String> leftItems;
  final List<String> rightItems;

  const ExamQuestion({
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer = '',
    this.correctAnswers = const [],
    this.leftItems = const [],
    this.rightItems = const [],
  });

  String get typeLabel {
    switch (type) {
      case QuestionType.uraian:
        return 'Esai Uraian';
      case QuestionType.single:
        return 'Pilihan Ganda';
      case QuestionType.multiple:
        return 'Pilihan Ganda Lebih dari Satu';
      case QuestionType.matching:
        return 'Menghubungkan';
    }
  }
}

class QuizStartPage extends StatefulWidget {
  const QuizStartPage({super.key});

  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _answerController = TextEditingController();

  int currentQuestion = 1;
  final int totalQuestion = 20;
  bool isSubmitting = false;

  // Jawaban disimpan berdasarkan nomor soal (1-20).
  final Map<int, dynamic> answers = {};

  // Materi bertema interpretasi lagu Shape of My Heart.
  // Soal menggunakan pertanyaan orisinal, bukan menyalin lirik lagu.
  final List<ExamQuestion> questions = const [
    // 1-4: URAIAN
    ExamQuestion(
      type: QuestionType.uraian,
      text: 'Menurut interpretasimu, bagaimana sebuah lagu dapat menceritakan perasaan seseorang tanpa menyebutkannya secara langsung?',
    ),
    ExamQuestion(
      type: QuestionType.uraian,
      text: 'Jelaskan bagaimana simbol atau metafora dalam sebuah lagu dapat membuat maknanya terasa lebih dalam.',
    ),
    ExamQuestion(
      type: QuestionType.uraian,
      text: 'Tuliskan interpretasimu tentang hubungan antara permainan kartu dan pilihan hidup sebagai tema sebuah lagu.',
    ),
    ExamQuestion(
      type: QuestionType.uraian,
      text: 'Menurutmu, bagaimana suasana musik dapat membantu pendengar memahami emosi yang ingin disampaikan penyanyi?',
    ),

    // 5-8: PILIHAN GANDA (SATU JAWABAN)
    ExamQuestion(
      type: QuestionType.single,
      text: 'Apa fungsi utama metafora dalam sebuah lagu?',
      options: ['Menyampaikan makna secara kiasan', 'Menghilangkan semua emosi', 'Mengganti melodi', 'Menentukan durasi lagu'],
      correctAnswer: 'Menyampaikan makna secara kiasan',
    ),
    ExamQuestion(
      type: QuestionType.single,
      text: 'Jika sebuah lagu menggunakan simbol kartu untuk membahas kehidupan, pendekatan bahasa tersebut disebut ...',
      options: ['Metafora', 'Onomatope', 'Instruksi teknis', 'Daftar pustaka'],
      correctAnswer: 'Metafora',
    ),
    ExamQuestion(
      type: QuestionType.single,
      text: 'Hal yang paling tepat dilakukan saat menafsirkan lagu adalah ...',
      options: ['Memperhatikan konteks dan simbol', 'Mengabaikan semua kata', 'Menebak tanpa alasan', 'Hanya menghitung jumlah bait'],
      correctAnswer: 'Memperhatikan konteks dan simbol',
    ),
    ExamQuestion(
      type: QuestionType.single,
      text: 'Unsur musik yang dapat membantu membangun suasana emosional adalah ...',
      options: ['Melodi dan tempo', 'Nomor halaman', 'Ukuran kertas', 'Nama folder'],
      correctAnswer: 'Melodi dan tempo',
    ),

    // 9-12: PILIHAN GANDA LEBIH DARI SATU
    ExamQuestion(
      type: QuestionType.multiple,
      text: 'Pilih semua unsur yang dapat membantu pendengar menafsirkan makna sebuah lagu.',
      options: ['Pilihan kata', 'Metafora atau simbol', 'Suasana musik', 'Warna sampul saja'],
      correctAnswers: ['Pilihan kata', 'Metafora atau simbol', 'Suasana musik'],
    ),
    ExamQuestion(
      type: QuestionType.multiple,
      text: 'Pilih hal-hal yang termasuk cara menyampaikan emosi melalui karya musik.',
      options: ['Melodi', 'Dinamika suara', 'Tempo', 'Nomor seri perangkat'],
      correctAnswers: ['Melodi', 'Dinamika suara', 'Tempo'],
    ),
    ExamQuestion(
      type: QuestionType.multiple,
      text: 'Ketika menganalisis simbol dalam lagu, informasi apa yang sebaiknya diperhatikan?',
      options: ['Konteks penggunaannya', 'Makna kiasannya', 'Hubungannya dengan tema', 'Harga alat pemutar musik'],
      correctAnswers: ['Konteks penggunaannya', 'Makna kiasannya', 'Hubungannya dengan tema'],
    ),
    ExamQuestion(
      type: QuestionType.multiple,
      text: 'Pilih pernyataan yang merupakan interpretasi, bukan fakta teknis lagu.',
      options: ['Lagu terasa melankolis bagi pendengar', 'Simbol dapat menggambarkan pilihan hidup', 'Makna lagu bisa ditafsirkan berbeda', 'Lagu pasti memiliki tepat 100 kata'],
      correctAnswers: ['Lagu terasa melankolis bagi pendengar', 'Simbol dapat menggambarkan pilihan hidup', 'Makna lagu bisa ditafsirkan berbeda'],
    ),

    // 13-16: MENGHUBUNGKAN
    ExamQuestion(
      type: QuestionType.matching,
      text: 'Hubungkan istilah musik dan bahasa dengan pengertiannya.',
      leftItems: ['Metafora', 'Melodi', 'Tempo', 'Interpretasi'],
      rightItems: ['Penafsiran makna', 'Pola rangkaian nada', 'Perbandingan kiasan', 'Kecepatan musik'],
    ),
    ExamQuestion(
      type: QuestionType.matching,
      text: 'Pasangkan unsur lagu dengan perannya.',
      leftItems: ['Lirik', 'Dinamika', 'Ritme', 'Suasana'],
      rightItems: ['Kesan emosi yang terasa', 'Keras-lembut bunyi', 'Kata-kata dalam lagu', 'Pola ketukan'],
    ),
    ExamQuestion(
      type: QuestionType.matching,
      text: 'Hubungkan cara penyampaian dengan contohnya.',
      leftItems: ['Simbol', 'Pesan langsung', 'Metafora', 'Nada minor'],
      rightItems: ['Ungkapan kiasan', 'Tanda yang mewakili ide', 'Pernyataan eksplisit', 'Sering memberi kesan sendu'],
    ),
    ExamQuestion(
      type: QuestionType.matching,
      text: 'Pasangkan kegiatan analisis dengan tujuan yang tepat.',
      leftItems: ['Mencermati kata', 'Mendengarkan tempo', 'Mengenali simbol', 'Membandingkan tafsir'],
      rightItems: ['Memahami pilihan bahasa', 'Menilai kecepatan musik', 'Menemukan makna kiasan', 'Melihat perbedaan sudut pandang'],
    ),

    // 17-20: URAIAN (empat jenis sudah tercakup; total tiap jenis dibuat seimbang)
    ExamQuestion(
      type: QuestionType.uraian,
      text: 'Jelaskan mengapa dua orang dapat memiliki interpretasi berbeda terhadap lagu yang sama.',
    ),
    ExamQuestion(
      type: QuestionType.single,
      text: 'Apa yang dimaksud dengan interpretasi sebuah karya lagu?',
      options: ['Penafsiran terhadap makna karya', 'Daftar perangkat audio', 'Penghitungan ukuran file', 'Penggantian nama penyanyi'],
      correctAnswer: 'Penafsiran terhadap makna karya',
    ),
    ExamQuestion(
      type: QuestionType.multiple,
      text: 'Pilih pendekatan yang baik saat menyampaikan pendapat tentang makna lagu.',
      options: ['Memberi alasan yang jelas', 'Mengaitkan pendapat dengan unsur lagu', 'Menghargai tafsir berbeda', 'Menyatakan tafsir pribadi pasti satu-satunya yang benar'],
      correctAnswers: ['Memberi alasan yang jelas', 'Mengaitkan pendapat dengan unsur lagu', 'Menghargai tafsir berbeda'],
    ),
    ExamQuestion(
      type: QuestionType.matching,
      text: 'Hubungkan istilah berikut dengan penjelasannya.',
      leftItems: ['Tema', 'Suasana', 'Bukti pendukung', 'Sudut pandang'],
      rightItems: ['Gagasan utama', 'Kesan yang dibangun karya', 'Unsur yang mendukung tafsir', 'Cara seseorang melihat makna'],
    ),
  ];

  int _countWords(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
  }

  ExamQuestion get _question => questions[currentQuestion - 1];

  void _saveCurrentAnswer() {
    final q = _question;
    if (q.type == QuestionType.uraian) {
      answers[currentQuestion] = _answerController.text;
    }
  }

  void _loadQuestion(int number) {
    _saveCurrentAnswer();
    setState(() {
      currentQuestion = number;
      final saved = answers[number];
      _answerController.text =
          _question.type == QuestionType.uraian && saved is String ? saved : '';
      _answerController.selection = TextSelection.collapsed(
        offset: _answerController.text.length,
      );
    });
  }

  void _previousQuestion() {
    if (currentQuestion > 1) _loadQuestion(currentQuestion - 1);
  }

  void _nextQuestion() {
    if (currentQuestion < totalQuestion) _loadQuestion(currentQuestion + 1);
  }

  bool _hasAnswer(int number) {
    final value = answers[number];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.length == questions[number - 1].leftItems.length;
    return false;
  }

  void _submitExam() {
    _saveCurrentAnswer();
    final q = _question;
    if (q.type == QuestionType.uraian && _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawaban uraian tidak boleh kosong.')),
      );
      return;
    }
    final unanswered = List.generate(totalQuestion, (i) => i + 1)
        .where((n) => !_hasAnswer(n))
        .toList();
    if (unanswered.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Masih ada soal kosong'),
          content: Text('Soal yang belum dijawab: ${unanswered.join(', ')}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Periksa lagi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadQuestion(unanswered.first);
              },
              child: const Text('Ke soal kosong'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: greenColor),
            SizedBox(width: 10),
            Expanded(child: Text('Kirim Ujian?', style: TextStyle(color: darkText))),
          ],
        ),
        content: const Text(
          'Pastikan semua jawaban sudah diperiksa sebelum mengirim ujian.',
          style: TextStyle(color: secondaryText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Periksa Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => isSubmitting = true);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: greenColor, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ujian Berhasil Dikirim',
                style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'Jawaban ujian kamu telah berhasil dikirim.',
          style: TextStyle(color: secondaryText, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestion;
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _buildExamHeader(progress),
                    _buildInfoBanner(),
                    _buildQuestionCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE1E7F0), width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: darkText),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LearnPoint', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryBlue)),
                SizedBox(height: 2),
                Text('E-LEARNING SMP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF0872B4), letterSpacing: 0.8)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, size: 25, color: darkText),
              ),
              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 3),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 23),
          ),
        ],
      ),
    );
  }

  Widget _buildExamHeader(double progress) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PENILAIAN TENGAH SEMESTER',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primaryBlue, letterSpacing: 0.2),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bahasa Inggris: Interpretasi Lagu',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_view_rounded, color: primaryBlue, size: 19),
                    const SizedBox(width: 5),
                    Text('$currentQuestion/$totalQuestion', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: darkText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFCBEAFF), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 9, color: Color(0xFF0874AD)),
                    SizedBox(width: 7),
                    Icon(Icons.timer_outlined, size: 18, color: Color(0xFF0874AD)),
                    SizedBox(width: 5),
                    Text('18:45', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF16466B))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Progres Kuis', style: TextStyle(fontSize: 13, color: secondaryText, fontWeight: FontWeight.w500))),
                        Text('${(progress * 100).round()}% ($currentQuestion/$totalQuestion)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFDCE8FA),
                        valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final String message;
    switch (_question.type) {
      case QuestionType.uraian:
        message = 'Jawab dengan kalimatmu sendiri dan jelaskan alasanmu secara runtut.';
        break;
      case QuestionType.single:
        message = 'Pilih satu jawaban yang paling tepat.';
        break;
      case QuestionType.multiple:
        message = 'Kamu dapat memilih lebih dari satu jawaban.';
        break;
      case QuestionType.matching:
        message = 'Pasangkan setiap item di sebelah kiri dengan pilihan yang sesuai.';
        break;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(22, 20, 22, 2),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(color: const Color(0xFFDCE6FF), borderRadius: BorderRadius.circular(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: primaryBlue, size: 24),
          const SizedBox(width: 11),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 14, color: darkText, height: 1.4, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final q = _question;
    final saved = answers[currentQuestion];
    final selected = saved is List<String> ? saved : <String>[];
    final matching = saved is Map<String, String> ? saved : <String, String>{};

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                  child: Text('Soal No. $currentQuestion', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFCBEAFF), borderRadius: BorderRadius.circular(20)),
                  child: Text(q.typeLabel, style: const TextStyle(color: Color(0xFF0874AD), fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_outlined, color: greenColor, size: 20),
                    SizedBox(width: 4),
                    Text('Bobot: 5 Poin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: darkText)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(q.text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: darkText, height: 1.6)),
            const SizedBox(height: 20),
            if (q.type == QuestionType.uraian) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: greenColor, size: 21),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Jawaban dengan kalimat sendiri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4C5668)))),
                  Text('${_countWords(_answerController.text)} kata', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: greenColor)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD8E4F7))),
                child: TextFormField(
                  controller: _answerController,
                  minLines: 7,
                  maxLines: 12,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 16, color: darkText, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan jawabanmu di sini...',
                    hintStyle: TextStyle(color: Color(0xFF8B96A8), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(18, 15, 18, 18),
                  ),
                  onChanged: (value) {
                    answers[currentQuestion] = value;
                    setState(() {});
                  },
                ),
              ),
            ] else if (q.type == QuestionType.single) ...[
              ...q.options.map((option) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryBlue,
                    title: Text(option, style: const TextStyle(color: darkText, height: 1.35)),
                    value: option,
                    groupValue: saved is String ? saved : null,
                    onChanged: (value) => setState(() => answers[currentQuestion] = value),
                  )),
            ] else if (q.type == QuestionType.multiple) ...[
              ...q.options.map((option) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryBlue,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(option, style: const TextStyle(color: darkText, height: 1.35)),
                    value: selected.contains(option),
                    onChanged: (checked) {
                      setState(() {
                        final updated = List<String>.from(selected);
                        if (checked == true) {
                          if (!updated.contains(option)) updated.add(option);
                        } else {
                          updated.remove(option);
                        }
                        answers[currentQuestion] = updated;
                      });
                    },
                  )),
            ] else ...[
              ...q.leftItems.map((left) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(12)),
                            child: Text(left, style: const TextStyle(color: darkText, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, color: primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: matching[left],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFEAF2FF),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            hint: const Text('Pilih pasangan', style: TextStyle(fontSize: 12)),
                            items: q.rightItems.map((right) => DropdownMenuItem<String>(
                                  value: right,
                                  child: Text(right, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                )).toList(),
                            onChanged: (value) {
                              setState(() {
                                final updated = Map<String, String>.from(matching);
                                if (value == null) {
                                  updated.remove(left);
                                } else {
                                  updated[left] = value;
                                }
                                answers[currentQuestion] = updated;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 8),
            Text(
              q.type == QuestionType.uraian
                  ? '* Pastikan jawabanmu sudah tersimpan sebelum berpindah soal.'
                  : '* Jawaban tersimpan otomatis saat kamu memilih opsi.',
              style: const TextStyle(fontSize: 11, color: secondaryText, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E7F0), width: 0.8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 54,
            child: ElevatedButton(
              onPressed: currentQuestion > 1 ? _previousQuestion : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFDCE8FA),
                foregroundColor: darkText,
                disabledBackgroundColor: const Color(0xFFEAF0F8),
                disabledForegroundColor: const Color(0xFF9AA4B3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Icon(Icons.chevron_left, size: 27),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            height: 54,
            child: ElevatedButton(
              onPressed: currentQuestion < totalQuestion ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFEAF0FF),
                foregroundColor: darkText,
                disabledBackgroundColor: const Color(0xFFEAF0F8),
                disabledForegroundColor: const Color(0xFF9AA4B3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Icon(Icons.chevron_right, size: 25),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitExam,
                icon: const Icon(Icons.check_circle_outline, size: 23),
                label: const Text(
                  'Kirim Ujian\nSelesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, height: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: greenColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF78BDA9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
