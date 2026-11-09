import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';

/// An error raised away from any screen; the words are chosen where it is shown.
class TextError implements Exception {
  final String Function(AppLocalizations) text;
  const TextError(this.text);
}

/// Turns an exception into a message a user can act on. The raw exception text
/// (host names, URLs, query strings) is shown only in debug builds.
class ErrorMessages {
  const ErrorMessages._();

  static bool isNetworkError(Object error) {
    if (error is SocketException || error is TimeoutException || error is HttpException) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('network is unreachable') ||
        text.contains('timed out');
  }

  static String friendly(Object error, AppLocalizations t) {
    final message = isNetworkError(error)
        ? t.errNoInternet
        : t.errGeneric;
    return kDebugMode ? '$message\n\n$error' : message;
  }
}
