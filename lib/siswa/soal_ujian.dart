import 'package:flutter/material.dart';

// ============================================================
// COLORS
// ============================================================

const Color primaryBlue = Color(0xFF0757C9);
const Color darkText = Color(0xFF13233A);
const Color secondaryText = Color(0xFF596579);
const Color lightBlue = Color(0xFFEAF4FF);
const Color cardBlue = Color(0xFFF0F5FF);
const Color greenColor = Color(0xFF008A63);

// ============================================================
// HALAMAN UJIAN
// ============================================================

class QuizStartPage extends StatefulWidget {
  const QuizStartPage({super.key});

  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> {
  // ==========================================================
  // FORM KEY
  // ==========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final TextEditingController _answerController = TextEditingController();

  // ==========================================================
  // STATE
  // ==========================================================

  int currentQuestion = 19;

  final int totalQuestion = 20;

  bool isSubmitting = false;

  // Menyimpan jawaban
  final Map<int, String> answers = {};

  // ==========================================================
  // DATA SOAL
  // ==========================================================

  final List<String> questions = [
    'Jelaskan mekanisme pernapasan dada dan pernapasan perut pada manusia saat fase inspirasi dan fase ekspirasi! Sebutkan otot-otot utama yang berperan dalam kedua proses tersebut.',

    'Looking back on the things Ive done, I was trying to be someone trying to be',

    'Jelaskan proses pertukaran gas oksigen dan karbon dioksida yang terjadi di dalam alveolus.',

    'Sebutkan organ-organ utama pada sistem pernapasan manusia dan jelaskan fungsi masing-masing organ tersebut.',

    'Jelaskan perbedaan antara pernapasan eksternal dan pernapasan internal.',

    'Apa yang dimaksud dengan volume tidal pada sistem pernapasan manusia? Jelaskan.',

    'Jelaskan bagaimana diafragma berperan dalam proses inspirasi dan ekspirasi.',

    'Mengapa manusia membutuhkan oksigen dalam proses metabolisme tubuh?',

    'Jelaskan hubungan antara sistem pernapasan dan sistem peredaran darah.',

    'Sebutkan beberapa gangguan yang dapat terjadi pada sistem pernapasan manusia.',

    'Jelaskan bagaimana udara dapat masuk hingga mencapai alveolus.',

    'Apa fungsi hidung dalam sistem pernapasan manusia?',

    'Jelaskan peran trakea dan bronkus dalam sistem pernapasan.',

    'Mengapa paru-paru memiliki banyak alveolus? Jelaskan hubungannya dengan pertukaran gas.',

    'Jelaskan apa yang terjadi pada tekanan udara di dalam paru-paru ketika inspirasi.',

    'Apa perbedaan mekanisme pernapasan dada dan pernapasan perut?',

    'Jelaskan pengaruh aktivitas fisik terhadap frekuensi pernapasan manusia.',

    'Mengapa frekuensi pernapasan dapat meningkat setelah melakukan olahraga?',

    'Jelaskan mekanisme pernapasan dada dan pernapasan perut pada manusia saat fase inspirasi dan fase ekspirasi! Sebutkan otot-otot utama yang berperan dalam kedua proses tersebut.',

    'Jelaskan kembali hubungan antara inspirasi, ekspirasi, diafragma, dan otot antartulang rusuk.',
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // Contoh jawaban yang sudah ada seperti pada desain
    _answerController.text = 'Pada fase inspirasi pernapasan dada, otot antartulang rusuk luar berkontraksi sehingga tulang rusuk terangkat, volume rongga dada membesar, dan tekanan udara di dalam paru-paru mengecil dibandingkan tekanan atmosfer luar, sehingga udara luar terdorong masuk ke paru-paru.';
  }

  // ==========================================================
  // WORD COUNT
  // ==========================================================

  int _countWords(String text) {
    final String trimmed = text.trim();

    if (trimmed.isEmpty) {
      return 0;
    }

    return trimmed.split(RegExp(r'\s+')).length;
  }

  // ==========================================================
  // SAVE ANSWER
  // ==========================================================

  void _saveCurrentAnswer() {
    answers[currentQuestion] = _answerController.text;
  }

  // ==========================================================
  // LOAD QUESTION
  // ==========================================================

  void _loadQuestion(int questionNumber) {
    _saveCurrentAnswer();

    setState(() {
      currentQuestion = questionNumber;

      _answerController.text = answers[questionNumber] ?? '';

      _answerController.selection = TextSelection.fromPosition(
        TextPosition(offset: _answerController.text.length),
      );
    });
  }

  // ==========================================================
  // PREVIOUS
  // ==========================================================

  void _previousQuestion() {
    if (currentQuestion > 1) {
      _loadQuestion(currentQuestion - 1);
    }
  }

  // ==========================================================
  // NEXT
  // ==========================================================

  void _nextQuestion() {
    if (currentQuestion < totalQuestion) {
      _loadQuestion(currentQuestion + 1);
    }
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  void _submitExam() {
    // Simpan jawaban terlebih dahulu
    _saveCurrentAnswer();

    // Jalankan validasi Form
    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _showSubmitConfirmation();
  }

  // ==========================================================
  // KONFIRMASI SELESAI
  // ==========================================================

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: greenColor),
              SizedBox(width: 10),
              Text(
                'Kirim Ujian?',
                style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: const Text(
            'Pastikan semua jawaban sudah diperiksa sebelum mengirim ujian.',
            style: TextStyle(color: secondaryText, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Periksa Lagi',
                style: TextStyle(color: secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  isSubmitting = true;
                });

                _showSuccessDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // SUCCESS
  // ==========================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: greenColor, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ujian Berhasil Dikirim',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                  ),
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final int wordCount = _countWords(_answerController.text);

    final double progress = currentQuestion / totalQuestion;

    return Scaffold(
      backgroundColor: lightBlue,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            _buildHeader(),

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: width < 400 ? 20 : 25),
                child: Column(
                  children: [
                    // ================================
                    // EXAM INFORMATION
                    // ================================

                    _buildExamHeader(progress),

                    // ================================
                    // INFORMATION BANNER
                    // ================================
                    _buildInfoBanner(),

                    // ================================
                    // QUESTION CARD
                    // ================================
                    _buildQuestionCard(wordCount),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOTTOM BUTTON
            // ==================================================
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E7F0), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          // BACK
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: darkText,
            ),
          ),

          const SizedBox(width: 8),

          // LOGO
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 9),

          // TITLE
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LearnPoint',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'E-LEARNING SMP',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0872B4),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // NOTIFICATION
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 25,
                  color: darkText,
                ),
              ),

              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 3),

          // PROFILE
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXAM HEADER
  // ============================================================

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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: primaryBlue,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'IPA: Sistem Pernapasan pada Manusia',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      color: primaryBlue,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$currentQuestion/$totalQuestion',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBEAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 9, color: Color(0xFF0874AD)),
                    SizedBox(width: 7),
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: Color(0xFF0874AD),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '18:45',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16466B),
                      ),
                    ),
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
                        const Expanded(
                          child: Text(
                            'Progres Kuis',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Text(
                          '${(progress * 100).round()}% '
                          '($currentQuestion/$totalQuestion)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFDCE8FA),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryBlue,
                        ),
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

  // ============================================================
  // INFO BANNER
  // ============================================================

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(22, 20, 22, 2),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: primaryBlue, size: 24),

          const SizedBox(width: 11),

          const Expanded(
            child: Text(
              'Kamu di soal uraian terakhir! Jawab secara runtut dengan bahasa ilmiah yang tepat ya.',
              style: TextStyle(
                fontSize: 14,
                color: darkText,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _buildQuestionCard(int wordCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // QUESTION HEADER
            // ==================================================

            Wrap(
              spacing: 6,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Soal No. $currentQuestion',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBEAFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Esai Uraian',
                    style: TextStyle(
                      color: Color(0xFF0874AD),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Bobot
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: greenColor,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Bobot: 15 Poin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ==================================================
            // QUESTION
            // ==================================================
            Text(
              questions[currentQuestion - 1],
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: darkText,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DIAGRAM
            // ==================================================
            _buildDiagramCard(),

            const SizedBox(height: 20),

            // ==================================================
            // WORD TARGET
            // ==================================================
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: greenColor,
                  size: 21,
                ),

                const SizedBox(width: 6),

                const Expanded(
                  child: Text(
                    'Target: Min. 50 kata',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4C5668),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF63F0B6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$wordCount kata ditulis',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007A58),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // ANSWER FORM
            // ==================================================
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFD8E4F7)),
              ),
              child: Column(
                children: [
                  // TOOLBAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCE8FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'B',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(width: 20),

                        const Text(
                          'I',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(width: 20),

                        const Icon(
                          Icons.format_list_bulleted,
                          size: 21,
                          color: darkText,
                        ),

                        const Spacer(),

                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur coretan akan dibuka.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 19),
                          label: const Text('Coretan'),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // NAMA: ABDUL AZIZ NURULLAH
                  // NIM : E412518866
                  // GOL : E
                  // ==================================================
                  TextFormField(
                    controller: _answerController,

                    minLines: 7,
                    maxLines: 12,

                    keyboardType: TextInputType.multiline,

                    textInputAction: TextInputAction.newline,

                    style: const TextStyle(
                      fontSize: 16,
                      color: darkText,
                      height: 1.6,
                    ),

                    decoration: const InputDecoration(
                      hintText: 'Tuliskan jawabanmu di sini...',
                      hintStyle: TextStyle(
                        color: Color(0xFF8B96A8),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(18, 15, 18, 18),
                    ),

                    validator: (value) {
                      final String text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Jawaban tidak boleh kosong.';
                      }

                      final int words = _countWords(text);
                      
                      if (words < 50) {
                        return 'Jawaban minimal 50 kata. '
                            'Saat ini baru $words kata.';
                      }

                      return null;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // ERROR INFORMATION
            // ==================================================
            const SizedBox(height: 8),

            const Text(
              '* Jawaban minimal 50 kata untuk dapat mengirim ujian.',
              style: TextStyle(
                fontSize: 11,
                color: secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIAGRAM CARD
  // ============================================================

  Widget _buildDiagramCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Color(0xFF8BA4C0),
              size: 48,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagram Bantu: Rongga Toraks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Klik untuk perbesar ilustrasi\npernapasan dada & perut',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFDCE8FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.zoom_in, color: primaryBlue, size: 22),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

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
          // ==================================================
          // SEBELUMNYA - ICON SAJA
          // ==================================================

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Icon(Icons.chevron_left, size: 27),
            ),
          ),

          const SizedBox(width: 8),
          // ==================================================
          // NEXT
          // ==================================================
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Icon(Icons.chevron_right, size: 25),
            ),
          ),

          const SizedBox(width: 8),

          // ==================================================
          // KIRIM UJIAN
          // ==================================================
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitExam,
                icon: const Icon(Icons.check_circle_outline, size: 23),
                label: const Text(
                  'Kirim Ujian\nSelesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: greenColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF78BDA9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
