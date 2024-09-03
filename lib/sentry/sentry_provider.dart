import 'package:flutter/material.dart';
import "package:sentry/sentry.dart";
import 'package:sentry_flutter/sentry_flutter.dart';

class FloatingBugReportProvider extends ChangeNotifier {
  late SentryId _eventId;
  late String _userEmail;

  FloatingBugReportProvider({String? userEmail})
      : _eventId = SentryId.newId(),
        _userEmail = 'nguyenducvuong13092003@gmail.com';

  void captureEvent(SentryEvent event, {dynamic stackTrace, dynamic hint}) {
    Sentry.captureEvent(event, stackTrace: stackTrace, hint: hint);
    notifyListeners();
  }

  void captureException(Exception e, {StackTrace? stackTrace}) {
    Sentry.captureException(e, stackTrace: stackTrace);
    notifyListeners();
  }

  void captureMessage({String? message}) {
    Sentry.captureMessage(message);
    notifyListeners();
  }

  void captureUserFeedback(String name, String comments) {
    Sentry.captureUserFeedback(SentryUserFeedback(
      eventId: _eventId,
      comments: comments,
      name: name,
      email: _userEmail,
    ));
    notifyListeners();
  }
}
