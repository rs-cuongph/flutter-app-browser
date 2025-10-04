import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../utils/url_normalizer.dart';
import 'webview_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isUrlValid = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_validateUrl);
  }

  void _validateUrl() {
    setState(() {
      _isUrlValid = UrlNormalizer.isValid(_urlController.text);
    });
  }

  Future<void> _openPage() async {
    if (!_isUrlValid) return;

    try {
      final normalizedUrl = UrlNormalizer.normalize(_urlController.text);
      await ref.read(historyProvider.notifier).addItem(normalizedUrl);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: normalizedUrl),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openRecentItem(String baseUrl) async {
    await ref.read(historyProvider.notifier).addItem(baseUrl);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebViewPage(url: baseUrl),
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple WebView'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Nhập URL (vd: https://example.com)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _openPage(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUrlValid ? _openPage : null,
              child: const Text('Mở trang'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: historyState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : historyState.items.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có trang gần đây',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: historyState.items.length,
                          itemBuilder: (context, index) {
                            final item = historyState.items[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.public),
                                title: Text(item.baseUrl),
                                subtitle: Text(
                                  _formatDate(item.lastOpenedAt),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => ref
                                      .read(historyProvider.notifier)
                                      .removeItem(item.baseUrl),
                                ),
                                onTap: () => _openRecentItem(item.baseUrl),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }
}
