import 'dart:async';

import '../../core/constants/app_constants.dart';

class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({
    Duration? duration,
  }) : duration = duration ??
            const Duration(milliseconds: AppConstants.searchDebounceMs);

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
