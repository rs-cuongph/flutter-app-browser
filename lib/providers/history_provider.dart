import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_item.dart';
import '../repositories/history_repository.dart';

class HistoryState {
  final List<RecentItem> items;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<RecentItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.getRecentItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải lịch sử: $e',
      );
    }
  }

  Future<void> addItem(String baseUrl) async {
    try {
      await _repository.addRecentItem(baseUrl);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(error: 'Không thể thêm mục: $e');
    }
  }

  Future<void> removeItem(String baseUrl) async {
    try {
      await _repository.removeItem(baseUrl);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(error: 'Không thể xóa mục: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _repository.clearHistory();
      state = state.copyWith(items: []);
    } catch (e) {
      state = state.copyWith(error: 'Không thể xóa lịch sử: $e');
    }
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences chưa được khởi tạo');
  }
  return HistoryRepository(prefs);
});

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});
