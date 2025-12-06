import 'package:flutter/foundation.dart';

/// Service to notify listeners about data changes (e.g. appointment CRUD)
class RefreshService extends ChangeNotifier {
  void triggerRefresh() {
    notifyListeners();
  }
}

