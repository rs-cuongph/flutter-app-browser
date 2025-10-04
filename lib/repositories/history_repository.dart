import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_item.dart';

class HistoryRepository {
  static const String _historyKey = 'recent_history';
  static const int _maxHistorySize = 10;

  final SharedPreferences _prefs;

  HistoryRepository(this._prefs);

  Future<List<RecentItem>> getRecentItems() async {
    final jsonString = _prefs.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => RecentItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecentItem(String baseUrl) async {
    final items = await getRecentItems();

    items.removeWhere((item) => item.baseUrl == baseUrl);

    items.insert(
      0,
      RecentItem(
        baseUrl: baseUrl,
        lastOpenedAt: DateTime.now(),
      ),
    );

    if (items.length > _maxHistorySize) {
      items.removeRange(_maxHistorySize, items.length);
    }

    final jsonList = items.map((item) => item.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  Future<void> removeItem(String baseUrl) async {
    final items = await getRecentItems();
    items.removeWhere((item) => item.baseUrl == baseUrl);

    final jsonList = items.map((item) => item.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(jsonList));
  }
}
