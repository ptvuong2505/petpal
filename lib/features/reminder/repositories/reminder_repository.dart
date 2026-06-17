import '../data/reminder_dao.dart';
import '../models/reminder.dart';

class ReminderRepository {
  ReminderRepository({required ReminderDao dao}) : _dao = dao;

  final ReminderDao _dao;

  Future<List<Reminder>> getReminders() {
    return _dao.getReminders();
  }

  Future<int> createReminder(Reminder reminder) {
    return _dao.insertReminder(reminder);
  }
}
