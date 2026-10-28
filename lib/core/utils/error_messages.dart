import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

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

  static String friendly(Object error) {
    final message = isNetworkError(error)
        ? 'No internet connection. Check your network and tap Try Again.'
        : 'Something went wrong while loading. Please try again in a moment.';
    return kDebugMode ? '$message\n\n$error' : message;
  }
}
