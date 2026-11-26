import 'package:dio/dio.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/features/siswa/statistik/models/student_statistics_model.dart';

class StatisticsApiService {
  static Future<StudentStatisticsResponse> getStatistics({int? periodId}) async {
    try {
      final response = await ApiConfig.dio.get(
        ApiConfig.siswaStatistikEndpoint,
        queryParameters: periodId == null ? null : {'academic_period_id': periodId},
      );
      final body = response.data;
      final payload = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body is Map
              ? Map<String, dynamic>.from(body)
              : null;
      if (payload == null) {
        throw const StatisticsException('Format statistik dari server tidak sesuai.');
      }
      return StudentStatisticsResponse.fromJson(payload);
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : error.message ?? 'Gagal memuat statistik.';
      throw StatisticsException(message);
    }
  }
}

class StatisticsException implements Exception {
  const StatisticsException(this.message);
  final String message;

  @override
  String toString() => message;
}
