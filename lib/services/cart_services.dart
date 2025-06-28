import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  static final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('Cart');

  // Add a book to cart
  static Future<void> addToCart({
    required String userId,
    required String bookId,
    required int quantity,
    required String finalPrice,
  }) async {
    print('Adding to cart: userId=$userId, bookId=$bookId, qty=$quantity, price=$finalPrice');

    if (userId.isEmpty || bookId.isEmpty || quantity <= 0 || finalPrice.isEmpty) {
      print('❌ Invalid input');
      return;
    }

    await _cartCollection.add({
      'user-id': userId,
      'book-id': bookId,
      'quantity': quantity,
      'final-price': finalPrice,
    });
  }

  // Get all cart items for a specific user
  static Future<List<Map<String, dynamic>>> getCartForUser(String userId) async {
    final snapshot = await _cartCollection
        .where('user-id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'cartId': doc.id,
        'bookId': doc['book-id'],
        'quantity': doc['quantity'],
        'finalPrice': doc['final-price'],
      };
    }).toList();
  }

  // Remove a cart item by userId and bookId
  static Future<void> removeFromCart(String userId, String bookId) async {
    final snapshot = await _cartCollection
        .where('user-id', isEqualTo: userId)
        .where('book-id', isEqualTo: bookId)
        .get();

    for (final doc in snapshot.docs) {
      await _cartCollection.doc(doc.id).delete();
    }
  }

  // Check if a specific book is already in the user's cart
  static Future<bool> isBookInCart(String userId, String bookId) async {
    final snapshot = await _cartCollection
        .where('user-id', isEqualTo: userId)
        .where('book-id', isEqualTo: bookId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Update quantity and price of a book in cart
  static Future<void> updateCartItem({
    required String userId,
    required String bookId,
    required int quantity,
    required String finalPrice,
  }) async {
    final snapshot = await _cartCollection
        .where('user-id', isEqualTo: userId)
        .where('book-id', isEqualTo: bookId)
        .get();

    for (final doc in snapshot.docs) {
      await _cartCollection.doc(doc.id).update({
        'quantity': quantity,
        'final-price': finalPrice,
      });
    }
  }
}
