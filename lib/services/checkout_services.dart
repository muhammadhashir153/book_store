import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutService {
  static final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('Orders');

  // Add a new order
  static Future<void> placeOrder({
    required String userId,
    required String bookId,
    required String price,
    required int quantity,
    String status = 'orderReceived',
  }) async {
    print('Placing order: userId=$userId, bookId=$bookId, qty=$quantity, price=$price');

    if (userId.isEmpty || bookId.isEmpty || price.isEmpty || quantity <= 0) {
      print('❌ Invalid order data');
      return;
    }

    await _orderCollection.add({
      'user-id': userId,
      'book-id': bookId,
      'price': price,
      'quantity': quantity,
      'status': status,
    });
  }

  // Get all orders for a specific user
  static Future<List<Map<String, dynamic>>> getOrdersForUser(String userId) async {
    final snapshot = await _orderCollection
        .where('user-id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'orderId': doc.id,
        ...data,
      };
    }).toList();
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderCollection.doc(orderId).update({
      'status': newStatus,
    });
  }

  // Delete an order
  static Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
  }
}
