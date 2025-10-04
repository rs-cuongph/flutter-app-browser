import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/script_definition.dart';

class ScriptManager {
  static final ScriptManager _instance = ScriptManager._internal();
  factory ScriptManager() => _instance;
  ScriptManager._internal();

  final Map<String, ScriptDefinition> _scripts = {};
  InAppWebViewController? _webViewController;

  /// Khởi tạo webview controller
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  /// Đăng ký một script mới
  void registerScript(ScriptDefinition script) {
    _scripts[script.id] = script;
  }

  /// Đăng ký nhiều script cùng lúc
  void registerScripts(List<ScriptDefinition> scripts) {
    for (final script in scripts) {
      _scripts[script.id] = script;
    }
  }

  /// Xóa script theo ID
  void unregisterScript(String scriptId) {
    _scripts.remove(scriptId);
  }

  /// Lấy script theo ID
  ScriptDefinition? getScript(String scriptId) {
    return _scripts[scriptId];
  }

  /// Lấy tất cả scripts
  List<ScriptDefinition> getAllScripts() {
    return _scripts.values.toList();
  }

  /// Kiểm tra script có tồn tại không
  bool hasScript(String scriptId) {
    return _scripts.containsKey(scriptId);
  }

  /// Thực thi script trong webview
  Future<dynamic> executeScript(String scriptId,
      {Map<String, dynamic>? parameters}) async {
    if (_webViewController == null) {
      throw Exception('WebViewController chưa được khởi tạo');
    }

    final script = _scripts[scriptId];
    if (script == null) {
      throw Exception('Script với ID "$scriptId" không tồn tại');
    }

    try {
      // Tạo script với parameters được inject
      String finalScript = script.script;

      if (parameters != null && parameters.isNotEmpty) {
        // Inject parameters vào script
        final paramsJson = jsonEncode(parameters);
        finalScript = '''
          (function() {
            const params = $paramsJson;
            $finalScript
          })();
        ''';
      }

      // Thực thi script
      final result =
          await _webViewController!.evaluateJavascript(source: finalScript);
      return result;
    } catch (e) {
      throw Exception('Lỗi khi thực thi script "$scriptId": $e');
    }
  }

  /// Thực thi script với JavaScript code trực tiếp
  Future<dynamic> executeRawScript(String script,
      {Map<String, dynamic>? parameters}) async {
    if (_webViewController == null) {
      throw Exception('WebViewController chưa được khởi tạo');
    }

    try {
      String finalScript = script;

      if (parameters != null && parameters.isNotEmpty) {
        final paramsJson = jsonEncode(parameters);
        finalScript = '''
          (function() {
            const params = $paramsJson;
            $script
          })();
        ''';
      }

      final result =
          await _webViewController!.evaluateJavascript(source: finalScript);
      return result;
    } catch (e) {
      throw Exception('Lỗi khi thực thi script: $e');
    }
  }

  /// Tạo JavaScript bridge để web content có thể gọi script
  String generateJavaScriptBridge() {
    final scriptsJson =
        jsonEncode(_scripts.map((key, value) => MapEntry(key, value.toJson())));

    return '''
      (function() {
        // Script Manager Bridge
        window.FlutterScriptManager = {
          scripts: $scriptsJson,
          
          // Lấy danh sách script có sẵn
          getAvailableScripts: function() {
            return Object.keys(this.scripts);
          },
          
          // Lấy thông tin script
          getScriptInfo: function(scriptId) {
            return this.scripts[scriptId] || null;
          },
          
          // Gọi script từ web content
          callScript: function(scriptId, parameters) {
            return new Promise((resolve, reject) => {
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('executeScript', {
                  scriptId: scriptId,
                  parameters: parameters || {}
                }).then(resolve).catch(reject);
              } else {
                reject(new Error('Flutter bridge không khả dụng'));
              }
            });
          },
          
          // Thực thi script trực tiếp
          executeScript: function(script, parameters) {
            return new Promise((resolve, reject) => {
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('executeRawScript', {
                  script: script,
                  parameters: parameters || {}
                }).then(resolve).catch(reject);
              } else {
                reject(new Error('Flutter bridge không khả dụng'));
              }
            });
          }
        };
        
        // Log để debug
        console.log('Flutter Script Manager đã được khởi tạo');
        console.log('Scripts có sẵn:', window.FlutterScriptManager.getAvailableScripts());
      })();
    ''';
  }

  /// Inject JavaScript bridge vào webview
  Future<void> injectJavaScriptBridge() async {
    if (_webViewController == null) return;

    final bridgeScript = generateJavaScriptBridge();
    await _webViewController!.evaluateJavascript(source: bridgeScript);
  }

  /// Xóa tất cả scripts
  void clearAllScripts() {
    _scripts.clear();
  }

  /// Lưu scripts vào storage (có thể implement sau)
  Future<void> saveScripts() async {
    // TODO: Implement persistence
  }

  /// Load scripts từ storage (có thể implement sau)
  Future<void> loadScripts() async {
    // TODO: Implement persistence
  }
}
