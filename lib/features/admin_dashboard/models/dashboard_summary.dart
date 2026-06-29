class DashboardSummary {
  const DashboardSummary({
    required this.totalPets,
    required this.totalBookings,
    required this.totalReviews,
    required this.openTasks,
    required this.dailyBookings,
    required this.recentBookings,
    required this.recentReviews,
  });

  static const empty = DashboardSummary(
    totalPets: 0,
    totalBookings: 0,
    totalReviews: 0,
    openTasks: 0,
    dailyBookings: [],
    recentBookings: [],
    recentReviews: [],
  );

  final int totalPets;
  final int totalBookings;
  final int totalReviews;
  final int openTasks;
  final List<DailyBookingCount> dailyBookings;
  final List<RecentBooking> recentBookings;
  final List<RecentReview> recentReviews;
}

class DailyBookingCount {
  const DailyBookingCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class RecentBooking {
  const RecentBooking({
    required this.id,
    required this.serviceName,
    required this.petName,
    required this.bookingDate,
    this.startTime,
    required this.status,
  });

  final int id;
  final String serviceName;
  final String petName;
  final String bookingDate;
  final String? startTime;
  final String status;
}

class RecentReview {
  const RecentReview({
    required this.customerName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String customerName;
  final int rating;
  final String comment;
  final DateTime? createdAt;
}
