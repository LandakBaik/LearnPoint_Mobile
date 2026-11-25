import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

class UjianTokenDialogWidget extends StatefulWidget {
  final UjianItem item;

  const UjianTokenDialogWidget({
    super.key,
    required this.item,
  });

  static Future<bool?> show(BuildContext context, UjianItem item) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UjianTokenDialogWidget(item: item),
    );
  }

  @override
  State<UjianTokenDialogWidget> createState() => _UjianTokenDialogWidgetState();
}

class _UjianTokenDialogWidgetState extends State<UjianTokenDialogWidget> {
  static const Color _primaryBlue = Color(0xFF0757C9);
  static const Color _darkText = Color(0xFF13233A);
  static const Color _secondaryText = Color(0xFF596579);

  final TextEditingController _tokenController = TextEditingController();
  String? _tokenError;
  bool _isValidating = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submitToken() async {
    final kode = _tokenController.text.trim();
    if (kode.isEmpty) {
      setState(() => _tokenError = 'Token ujian wajib diisi.');
      return;
    }
    setState(() {
      _isValidating = true;
      _tokenError = null;
    });
    try {
      await UjianApiService.validasiToken(
        ujianId: widget.item.id,
        token: kode,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _tokenError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.vpn_key_rounded, color: _primaryBlue, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Masukkan Token Sesi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.item.judul} (Sesi ${widget.item.sesi})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan kode token dari guru pengawas untuk mulai mengerjakan ujian.',
            style: TextStyle(
              fontSize: 11.5,
              color: _secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: _darkText,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: S1-AB12',
              hintStyle: const TextStyle(fontSize: 13, letterSpacing: 0.5),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_tokenError != null) ...[
            const SizedBox(height: 8),
            Text(
              _tokenError!,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isValidating ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isValidating ? null : _submitToken,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: _isValidating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Mulai Ujian',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}
