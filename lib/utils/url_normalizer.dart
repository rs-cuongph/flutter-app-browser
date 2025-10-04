class UrlNormalizer {
  static final RegExp _urlPattern = RegExp(
    r'^(https?://)?([a-zA-Z0-9.-]+)(:[0-9]+)?(/.*)?$',
    caseSensitive: false,
  );

  static final Set<String> _dangerousSchemes = {
    'javascript:',
    'data:',
    'ftp:',
  };

  /// Validates and normalizes a URL
  /// Returns normalized base URL or throws FormatException
  static String normalize(String url) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      throw const FormatException('URL cannot be empty');
    }

    // Check for dangerous schemes
    for (final scheme in _dangerousSchemes) {
      if (trimmedUrl.toLowerCase().startsWith(scheme)) {
        throw FormatException('Unsafe URL scheme: $scheme');
      }
    }

    // Auto-add https:// if no scheme
    final urlWithScheme = _addSchemeIfMissing(trimmedUrl);

    // Validate URL format
    final match = _urlPattern.firstMatch(urlWithScheme);
    if (match == null) {
      throw const FormatException('Invalid URL format');
    }

    // Extract components
    final scheme = match.group(1)?.toLowerCase() ?? 'https://';
    final host = match.group(2)?.toLowerCase() ?? '';
    final port = match.group(3) ?? '';

    if (host.isEmpty) {
      throw const FormatException('URL must have a valid host');
    }

    // Build base URL (scheme + host + port)
    return '$scheme$host$port';
  }

  static String _addSchemeIfMissing(String url) {
    if (!url.contains('://')) {
      return 'https://$url';
    }
    return url;
  }

  /// Checks if a URL is valid without throwing
  static bool isValid(String url) {
    try {
      normalize(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extracts base URL from a full URL (safe version, returns null on error)
  static String? tryNormalize(String url) {
    try {
      return normalize(url);
    } catch (e) {
      return null;
    }
  }
}
