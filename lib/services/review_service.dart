import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewService {
  static final CollectionReference _reviewCollection = FirebaseFirestore
      .instance
      .collection('Reviews');

  /// Add a new review
  static Future<void> addReview({
    required String bookId,
    required String userId,
    required bool isLiked,
    required double rating,
    required String comment,
  }) async {
    await _reviewCollection.add({
      'book-id': bookId,
      'user-id': userId,
      'is-liked': isLiked,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch reviews for a specific book
  static Future<List<Map<String, dynamic>>> getReviewsForBook(
    String bookId,
  ) async {
    final reviewSnapshot = await _reviewCollection
        .where('book-id', isEqualTo: bookId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> reviews = [];

    for (final doc in reviewSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['user-id'] ?? '';

      // Get user info from 'users' collection
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      final userData = userSnapshot.data();

      // Format timestamp
      final timestamp = data['timestamp'];
      String formattedTime = 'Just now';
      if (timestamp is Timestamp) {
        formattedTime = timeago.format(timestamp.toDate());
      }

      reviews.add({
        'reviewId': doc.id,
        'bookId': data['book-id'],
        'userId': userId,
        'isLiked': data['is-liked'],
        'rating': data['rating'],
        'comment': data['comment'],
        'timestamp': formattedTime,
        'user': {
          'username': userData?['name'] ?? 'Unknown',
          'profileImage': userData?['profileImage'] ?? '',
        },
      });
    }

    return reviews;
  }

  /// Get average rating for a specific book
  static Future<double> getAverageRatingForBook(String bookId) async {
    final snapshot = await _reviewCollection
        .where('book-id', isEqualTo: bookId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double totalRating = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rating = data['rating'];
      if (rating is num) {
        totalRating += rating.toDouble();
      }
    }

    return totalRating / snapshot.docs.length;
  }
}
