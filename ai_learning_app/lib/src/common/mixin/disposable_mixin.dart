import 'dart:async';
import 'package:flutter/widgets.dart';

mixin DisposableMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<ChangeNotifier> _notifiers = [];

  void autoCancel(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void autoDispose(ChangeNotifier notifier) {
    _notifiers.add(notifier);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    for (final notifier in _notifiers) {
      notifier.dispose();
    }
    super.dispose();
  }
}
