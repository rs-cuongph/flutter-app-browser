import 'package:flutter_test/flutter_test.dart';
import 'package:webview_app/utils/url_normalizer.dart';

void main() {
  group('UrlNormalizer.normalize', () {
    test('adds https:// when scheme is missing', () {
      expect(
        UrlNormalizer.normalize('example.com'),
        equals('https://example.com'),
      );
      expect(
        UrlNormalizer.normalize('google.com'),
        equals('https://google.com'),
      );
    });

    test('preserves existing https:// scheme', () {
      expect(
        UrlNormalizer.normalize('https://example.com'),
        equals('https://example.com'),
      );
    });

    test('preserves existing http:// scheme', () {
      expect(
        UrlNormalizer.normalize('http://example.com'),
        equals('http://example.com'),
      );
    });

    test('converts host to lowercase', () {
      expect(
        UrlNormalizer.normalize('EXAMPLE.COM'),
        equals('https://example.com'),
      );
      expect(
        UrlNormalizer.normalize('https://Google.COM'),
        equals('https://google.com'),
      );
    });

    test('preserves port numbers', () {
      expect(
        UrlNormalizer.normalize('example.com:8080'),
        equals('https://example.com:8080'),
      );
      expect(
        UrlNormalizer.normalize('https://localhost:3000'),
        equals('https://localhost:3000'),
      );
    });

    test('removes path from URL', () {
      expect(
        UrlNormalizer.normalize('example.com/path/to/page'),
        equals('https://example.com'),
      );
      expect(
        UrlNormalizer.normalize('https://example.com/about'),
        equals('https://example.com'),
      );
    });

    test('removes query parameters', () {
      expect(
        UrlNormalizer.normalize('example.com?query=value'),
        equals('https://example.com'),
      );
      expect(
        UrlNormalizer.normalize('https://example.com/page?foo=bar&baz=qux'),
        equals('https://example.com'),
      );
    });

    test('removes fragment/hash', () {
      expect(
        UrlNormalizer.normalize('example.com#section'),
        equals('https://example.com'),
      );
      expect(
        UrlNormalizer.normalize('https://example.com/page#top'),
        equals('https://example.com'),
      );
    });

    test('handles complex URLs correctly', () {
      expect(
        UrlNormalizer.normalize('EXAMPLE.COM:8080/path?query=1#hash'),
        equals('https://example.com:8080'),
      );
    });

    test('trims whitespace', () {
      expect(
        UrlNormalizer.normalize('  example.com  '),
        equals('https://example.com'),
      );
    });

    test('rejects javascript: scheme', () {
      expect(
        () => UrlNormalizer.normalize('javascript:alert(1)'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UrlNormalizer.normalize('JAVASCRIPT:void(0)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects data: scheme', () {
      expect(
        () => UrlNormalizer.normalize('data:text/html,<h1>test</h1>'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects ftp: scheme', () {
      expect(
        () => UrlNormalizer.normalize('ftp://example.com'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects empty URL', () {
      expect(
        () => UrlNormalizer.normalize(''),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UrlNormalizer.normalize('   '),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid URL format', () {
      expect(
        () => UrlNormalizer.normalize('not a url'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('UrlNormalizer.isValid', () {
    test('returns true for valid URLs', () {
      expect(UrlNormalizer.isValid('example.com'), isTrue);
      expect(UrlNormalizer.isValid('https://example.com'), isTrue);
      expect(UrlNormalizer.isValid('example.com:8080'), isTrue);
    });

    test('returns false for invalid URLs', () {
      expect(UrlNormalizer.isValid(''), isFalse);
      expect(UrlNormalizer.isValid('javascript:alert(1)'), isFalse);
      expect(UrlNormalizer.isValid('not a url'), isFalse);
    });
  });

  group('UrlNormalizer.tryNormalize', () {
    test('returns normalized URL for valid input', () {
      expect(
        UrlNormalizer.tryNormalize('example.com'),
        equals('https://example.com'),
      );
    });

    test('returns null for invalid input', () {
      expect(UrlNormalizer.tryNormalize(''), isNull);
      expect(UrlNormalizer.tryNormalize('javascript:alert(1)'), isNull);
      expect(UrlNormalizer.tryNormalize('not a url'), isNull);
    });
  });
}
