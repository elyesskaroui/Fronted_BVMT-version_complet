import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import '../../features/home/domain/entities/market_summary_entity.dart';

/// Service de persistance locale pour l'état de l'app (GetStorage)
class LocalStorageService {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserName = 'user_name';
  static const _keyChartPrefix = 'chart_intraday_';
  static const _keyChartTimestamp = 'chart_ts_';

  /// Durée de validité du cache (30 minutes)
  static const _cacheDuration = Duration(minutes: 30);

  late final GetStorage _box;

  Future<void> init() async {
    await GetStorage.init();
    _box = GetStorage();
  }

  // ── Onboarding ──
  bool get hasSeenOnboarding => _box.read<bool>(_keyOnboardingSeen) ?? false;
  void setOnboardingSeen() => _box.write(_keyOnboardingSeen, true);

  // ── Auth ──
  bool get isLoggedIn => _box.read<bool>(_keyIsLoggedIn) ?? false;
  String? get userName => _box.read<String>(_keyUserName);

  void setLoggedIn(String name) {
    _box.write(_keyIsLoggedIn, true);
    _box.write(_keyUserName, name);
  }

  void setLoggedOut() {
    _box.write(_keyIsLoggedIn, false);
    _box.remove(_keyUserName);
  }

  void clearAll() {
    _box.erase();
  }


  /// Sauvegarde les données intraday d'un indice dans GetStorage
  void cacheChartData(String indexName, List<ChartPoint> data) {
    final key = '$_keyChartPrefix$indexName';
    final tsKey = '$_keyChartTimestamp$indexName';
    final jsonList = data
        .map((p) => {'time': p.time, 'value': p.value})
        .toList();
    _box.write(key, jsonEncode(jsonList));
    _box.write(tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Lit les données en cache pour un indice (null si expiré ou absent)
  List<ChartPoint>? getCachedChartData(String indexName) {
    final key = '$_keyChartPrefix$indexName';
    final tsKey = '$_keyChartTimestamp$indexName';

    final raw = _box.read<String>(key);
    final ts = _box.read<int>(tsKey);

    if (raw == null || ts == null) return null;

    // Vérifier l'expiration du cache
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) {
      _box.remove(key);
      _box.remove(tsKey);
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => ChartPoint(
                time: (item['time'] as num).toDouble(),
                value: (item['value'] as num).toDouble(),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Supprime le cache d'un indice spécifique
  void clearChartCache(String indexName) {
    _box.remove('$_keyChartPrefix$indexName');
    _box.remove('$_keyChartTimestamp$indexName');
  }



  /// Écriture brute dans GetStorage (clé/valeur)
  void writeRaw<T>(String key, T value) => _box.write(key, value);

  /// Lecture brute depuis GetStorage
  T? readRaw<T>(String key) => _box.read<T>(key);

  /// Suppression brute dans GetStorage
  void removeRaw(String key) => _box.remove(key);
}
