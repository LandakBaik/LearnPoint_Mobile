import 'package:flutter/foundation.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/services/profile_service.dart';
import 'package:learnpoint_mobile/shared/models/user_model.dart';

typedef LoadCachedProfileFn = Future<StudentProfileModel?> Function();
typedef FetchProfileRemoteFn = Future<StudentProfileModel> Function();
typedef UpdateGuruProfileRemoteFn = Future<StudentProfileModel> Function({
  String? nomorTelepon,
  String? jenisKelamin,
  String? currentPassword,
  String? password,
  String? passwordConfirmation,
});

/// Shared state (Provider) untuk data profil pengguna lintas halaman.
class ProfileProvider extends ChangeNotifier {
  final LoadCachedProfileFn _loadCachedProfile;
  final FetchProfileRemoteFn _fetchProfileRemote;
  final UpdateGuruProfileRemoteFn _updateGuruProfileRemote;

  ProfileProvider({
    LoadCachedProfileFn? loadCachedProfile,
    FetchProfileRemoteFn? fetchProfileRemote,
    UpdateGuruProfileRemoteFn? updateGuruProfileRemote,
  })  : _loadCachedProfile =
            loadCachedProfile ?? ProfileService.loadCachedProfile,
        _fetchProfileRemote =
            fetchProfileRemote ?? ProfileService.fetchProfile,
        _updateGuruProfileRemote =
            updateGuruProfileRemote ?? ProfileService.updateGuruProfile;

  StudentProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  StudentProfileModel? get profile => _profile;
  StudentProfileModel get currentProfile =>
      _profile ?? const StudentProfileModel.empty();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mengisi state profil dari [UserModel] hasil login tanpa menunggu /api/profile.
  void seedFromUser(UserModel user) {
    _profile = StudentProfileModel.fromUserModel(user);
    _errorMessage = null;
    notifyListeners();
  }

  /// Menghapus state profil di memori saat logout.
  void clearCache() {
    _profile = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Memastikan profil terisi dari cache lokal lalu menyegarkan dari server.
  /// Aman dipanggil berulang dari berbagai halaman.
  Future<StudentProfileModel?> ensureLoaded({bool forceRefresh = false}) async {
    if (_profile == null) {
      final cached = await _loadCachedProfile();
      if (cached != null) {
        _profile = cached;
        notifyListeners();
      }
    }

    if (_profile != null && !forceRefresh) {
      return _profile;
    }

    return await fetchProfile();
  }

  /// Mengambil data profil terbaru dari server dan memperbarui state bersama.
  Future<StudentProfileModel?> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _fetchProfileRemote();
      _profile = fetched;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return fetched;
    } on ProfileException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return _profile;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data profil: $e';
      notifyListeners();
      return _profile;
    }
  }

  /// Memperbarui profil Guru dan langsung menyinkronkan ke seluruh UI pendengar.
  Future<StudentProfileModel> updateGuruProfile({
    String? nomorTelepon,
    String? jenisKelamin,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final updated = await _updateGuruProfileRemote(
      nomorTelepon: nomorTelepon,
      jenisKelamin: jenisKelamin,
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    _profile = updated;
    _errorMessage = null;
    notifyListeners();
    return updated;
  }
}
