import '../data/review_dao.dart';
import '../models/review.dart';

class ReviewRepository {
  ReviewRepository({required ReviewDao dao}) : _dao = dao;

  final ReviewDao _dao;

  Future<List<Review>> getReviews() {
    return _dao.getReviews();
  }

  Future<int> createReview(Review review) {
    return _dao.insertReview(review);
  }
}
