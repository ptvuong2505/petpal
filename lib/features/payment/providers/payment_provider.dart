import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import '../repositories/payment_repository.dart';

abstract interface class PaymentPoller {
  void cancel();
}

typedef PaymentPollerFactory =
    PaymentPoller Function(Duration interval, Future<void> Function() callback);

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({
    required PaymentRepositoryContract repository,
    PaymentPollerFactory? pollerFactory,
    this.pollInterval = const Duration(seconds: 5),
  }) : _repository = repository,
       _pollerFactory = pollerFactory ?? _createTimerPoller;

  final PaymentRepositoryContract _repository;
  final PaymentPollerFactory _pollerFactory;
  final Duration pollInterval;

  Payment? payment;
  bool isLoading = false;
  bool isChecking = false;
  String? errorMessage;
  PaymentPoller? _poller;

  Future<void> initialize(int bookingId) async {
    stopPolling();
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      payment = await _repository.initializePayment(bookingId);
      errorMessage = payment?.lastError;
      if (payment?.isTerminal != true) startPolling();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final current = payment;
    if (current == null || current.isTerminal || isChecking) return;
    isChecking = true;
    notifyListeners();
    try {
      payment = await _repository.refreshPayment(current);
      errorMessage = payment?.lastError;
      if (payment?.isTerminal == true) stopPolling();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  void startPolling() {
    if (_poller != null || payment?.isTerminal == true) return;
    _poller = _pollerFactory(pollInterval, refresh);
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> onAppResumed() => refresh();

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  static PaymentPoller _createTimerPoller(
    Duration interval,
    Future<void> Function() callback,
  ) {
    return _TimerPaymentPoller(interval, callback);
  }
}

class _TimerPaymentPoller implements PaymentPoller {
  _TimerPaymentPoller(Duration interval, Future<void> Function() callback)
    : _timer = Timer.periodic(interval, (_) {
        callback();
      });

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
