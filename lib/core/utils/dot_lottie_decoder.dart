import 'package:lottie/lottie.dart';

/// Decoder untuk file dotLottie (`.lottie`), yaitu zip berisi `animations/*.json`.
/// Pakai bersama `Lottie.asset(path, decoder: decodeDotLottie)`.
Future<LottieComposition?> decodeDotLottie(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      for (final file in files) {
        if (file.name.startsWith('animations/') &&
            file.name.endsWith('.json')) {
          return file;
        }
      }
      return null;
    },
  );
}
