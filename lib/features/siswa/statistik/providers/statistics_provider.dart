import 'package:flutter/foundation.dart';
import 'package:learnpoint_mobile/features/siswa/statistik/models/student_statistics_model.dart';
import 'package:learnpoint_mobile/features/siswa/statistik/services/statistics_api_service.dart';

class StatisticsProvider extends ChangeNotifier {
  StudentStatisticsResponse? _response;
  bool _isLoading = false;
  String? _errorMessage;

  StudentStatisticsResponse? get response => _response;
  StudentStatisticsModel? get statistics => _response?.statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({int? periodId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _response = await StatisticsApiService.getStatistics(periodId: periodId);
    } on StatisticsException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Gagal memuat statistik. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
