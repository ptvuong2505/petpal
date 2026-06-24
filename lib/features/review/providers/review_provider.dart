import 'package:flutter/foundation.dart';

import '../models/review.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({required ReviewRepository repository})
    : _repository = repository;

  final ReviewRepository _repository;

  List<Review> reviews = [];
  bool isLoading = false;

  Future<void> loadReviews() async {
    isLoading = true;
    notifyListeners();

    reviews = await _repository.getReviews();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createReview(Review review) async {
    await _repository.createReview(review);
    await loadReviews();
  }

  Future<void> updateReview(Review review) async {
    await _repository.updateReview(review);
    await loadReviews();
  }

  Future<void> deleteReview(int id) async {
    await _repository.deleteReview(id);
    await loadReviews();
  }
}
