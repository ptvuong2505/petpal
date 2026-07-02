import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({required ReminderRepository repository})
      : _repository = repository;

  final ReminderRepository _repository;

  List<Reminder> reminders = [];
  bool isLoading = false;

  Future<void> loadReminders() async {
    isLoading = true;
    notifyListeners();

    reminders = await _repository.getReminders();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createReminder(Reminder reminder) async {
    await _repository.createReminder(reminder);
    await loadReminders();
  }
}
