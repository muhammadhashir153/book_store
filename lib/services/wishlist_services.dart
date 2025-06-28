import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  static final CollectionReference _wishlistCollection = FirebaseFirestore
      .instance
      .collection('wishlist');

  // Add a book to wishlist
  static Future<void> addToWishlist(String userId, String bookId) async {
    print('Adding to wishlist: userId=$userId, bookId=$bookId'); // ✅ Debug

    if (userId.isEmpty || bookId.isEmpty) {
      print('❌ Empty userId or bookId');
      return;
    }

    await _wishlistCollection.add({'user-id': userId, 'book-id': bookId});
  }

  // Get all wishlisted books for a specific user
static Future<List<Map<String, String>>> getWishlistForUser(String userId) async {
  final snapshot = await _wishlistCollection
      .where('user-id', isEqualTo: userId)
      .get();

  return snapshot.docs.map((doc) {
    return {
      'wishlistId': doc.id,
      'bookId': doc['book-id'] as String,
    };
  }).toList();
}
  // Remove a book from wishlist by user and book ID
  static Future<void> removeFromWishlist(String userId, String bookId) async {
    final snapshot = await _wishlistCollection
        .where('user-id', isEqualTo: userId)
        .where('book-id', isEqualTo: bookId)
        .get();

    for (final doc in snapshot.docs) {
      await _wishlistCollection.doc(doc.id).delete();
    }
  }

  // Check if a specific book is in the user's wishlist
  static Future<bool> isBookWishlisted(String userId, String bookId) async {
    final snapshot = await _wishlistCollection
        .where('user-id', isEqualTo: userId)
        .where('book-id', isEqualTo: bookId)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
