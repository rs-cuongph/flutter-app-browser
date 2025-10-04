import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum WebViewErrorType {
  invalidUrl,
  network,
  ssl,
  dns,
  timeout,
  unknown,
}

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _hasError = false;
  String? _errorMessage;
  WebViewErrorType _errorType = WebViewErrorType.unknown;
  bool _isLoading = false;
  Timer? _loadingTimer;
  static const int _timeoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    _validateAndLoadUrl();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: _timeoutSeconds), () {
      if (_isLoading) {
        setState(() {
          _hasError = true;
          _errorType = WebViewErrorType.timeout;
          _errorMessage = _getErrorMessage(WebViewErrorType.timeout, null);
          _isLoading = false;
        });
      }
    });
  }

  void _cancelLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  void _validateAndLoadUrl() {
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (!urlPattern.hasMatch(widget.url)) {
      setState(() {
        _hasError = true;
        _errorType = WebViewErrorType.invalidUrl;
        _errorMessage = 'URL không hợp lệ: ${widget.url}';
      });
    }
  }

  WebViewErrorType _classifyError(WebResourceError error) {
    final errorCode = error.type.toNativeValue() ?? 0;
    final description = error.description.toLowerCase();

    // SSL errors
    if (description.contains('ssl') || description.contains('certificate')) {
      return WebViewErrorType.ssl;
    }

    // DNS errors
    if (description.contains('dns') ||
        description.contains('host') ||
        description.contains('not found') ||
        errorCode == -1003) {
      return WebViewErrorType.dns;
    }

    // Network errors
    if (description.contains('network') ||
        description.contains('internet') ||
        description.contains('connection') ||
        errorCode == -1009) {
      return WebViewErrorType.network;
    }

    // Timeout errors
    if (description.contains('timeout') ||
        description.contains('timed out') ||
        errorCode == -1001) {
      return WebViewErrorType.timeout;
    }

    return WebViewErrorType.unknown;
  }

  String _getErrorMessage(WebViewErrorType type, String? originalMessage) {
    switch (type) {
      case WebViewErrorType.invalidUrl:
        return 'URL không đúng định dạng. Vui lòng kiểm tra lại.';
      case WebViewErrorType.network:
        return 'Không có kết nối mạng. Vui lòng kiểm tra kết nối internet của bạn.';
      case WebViewErrorType.ssl:
        return 'Lỗi bảo mật SSL. Trang web có thể không an toàn.';
      case WebViewErrorType.dns:
        return 'Không tìm thấy trang web. Vui lòng kiểm tra lại địa chỉ.';
      case WebViewErrorType.timeout:
        return 'Hết thời gian chờ. Vui lòng thử lại.';
      case WebViewErrorType.unknown:
        return originalMessage ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPage();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllow: 'camera; microphone; geolocation',
                iframeAllowFullscreen: true,
                // iOS-specific settings for camera/media
                allowsPictureInPictureMediaPlayback: true,
                allowsAirPlayForMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _hasError = false;
                  _progress = 0;
                  _isLoading = true;
                });
                _startLoadingTimer();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) {
                _cancelLoadingTimer();
                setState(() {
                  _progress = 1;
                  _isLoading = false;
                });
              },
              onReceivedError: (controller, request, error) {
                _cancelLoadingTimer();
                final errorType = _classifyError(error);
                setState(() {
                  _hasError = true;
                  _errorType = errorType;
                  _errorMessage = _getErrorMessage(errorType, error.description);
                  _isLoading = false;
                });
              },
              onReceivedHttpError: (controller, request, response) {
                if (response.statusCode == 404) {
                  setState(() {
                    _hasError = true;
                    _errorType = WebViewErrorType.dns;
                    _errorMessage = 'Trang không tồn tại (404).';
                    _isLoading = false;
                  });
                }
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
            ),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage() {
    final errorInfo = _getErrorInfo(_errorType);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  errorInfo.icon,
                  size: 80,
                  color: errorInfo.color,
                ),
                const SizedBox(height: 24),
                Text(
                  errorInfo.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Đã xảy ra lỗi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_errorType != WebViewErrorType.invalidUrl)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _errorMessage = null;
                          });
                          _webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    if (_errorType != WebViewErrorType.invalidUrl)
                      const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ErrorInfo _getErrorInfo(WebViewErrorType type) {
    switch (type) {
      case WebViewErrorType.invalidUrl:
        return _ErrorInfo(
          icon: Icons.link_off,
          color: Colors.orange,
          title: 'URL không hợp lệ',
        );
      case WebViewErrorType.network:
        return _ErrorInfo(
          icon: Icons.wifi_off,
          color: Colors.red,
          title: 'Lỗi kết nối',
        );
      case WebViewErrorType.ssl:
        return _ErrorInfo(
          icon: Icons.security,
          color: Colors.amber,
          title: 'Cảnh báo bảo mật',
        );
      case WebViewErrorType.dns:
        return _ErrorInfo(
          icon: Icons.language,
          color: Colors.blue,
          title: 'Không tìm thấy trang',
        );
      case WebViewErrorType.timeout:
        return _ErrorInfo(
          icon: Icons.timer_off,
          color: Colors.deepOrange,
          title: 'Hết thời gian chờ',
        );
      case WebViewErrorType.unknown:
        return _ErrorInfo(
          icon: Icons.error_outline,
          color: Colors.red,
          title: 'Không thể tải trang',
        );
    }
  }
}

class _ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;

  _ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
  });
}
