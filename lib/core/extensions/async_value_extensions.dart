import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failure.dart';

extension AsyncValueExtensions<T> on AsyncValue<T> {
  bool get isLoadingState => this is AsyncLoading<T>;

  Failure? get failure {
    final err = error;
    if (err is Failure) return err;
    return null;
  }

  String? get errorMessage {
    final f = failure;
    if (f != null) return f.displayMessage;
    return error?.toString();
  }

  T? get valueOrPrevious {
    return when(
      data: (d) => d,
      loading: () => valueOrNull,
      error: (_, __) => valueOrNull,
    );
  }
}
