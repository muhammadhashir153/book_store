import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class CheckoutService {
  static final CollectionReference _orderCollection = FirebaseFirestore.instance
      .collection('Orders');

  // Add a new order
  static Future<void> placeOrder({
    required String userId,
    required String bookId,
    required String price,
    required int quantity,
    required String invoiceNum,
    String status = 'Order Received',
  }) async {
    print(
      'Placing order: userId=$userId, bookId=$bookId, qty=$quantity, price=$price, invoice=$invoiceNum',
    );

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
      'invoice-num': invoiceNum,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getOrdersForUser(
    String userId,
  ) async {
    final snapshot = await _orderCollection
        .where('user-id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    final Map<String, Map<String, dynamic>> groupedOrders = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final invoiceNum = data['invoice-num'] as String?;
      final timestamp = data['timestamp'] as Timestamp?;

      if (invoiceNum == null) continue;

      final dateTime = timestamp?.toDate();

      if (!groupedOrders.containsKey(invoiceNum)) {
        groupedOrders[invoiceNum] = {
          'invoice-num': invoiceNum,
          'status': data['status'],
          'timestamp': dateTime != null ? timeago.format(dateTime) : 'N/A',
          'books': [],
          'totalPrice': 0.0,
        };
      }

      final price = double.tryParse(data['price']?.toString() ?? '') ?? 0.0;
      final quantity = data['quantity'] as int? ?? 0;
      final bookId = data['book-id'] as String? ?? 'unknown';

      groupedOrders[invoiceNum]!['books'].add({
        'book-id': bookId,
        'price': price,
        'quantity': quantity,
      });

      groupedOrders[invoiceNum]!['totalPrice'] =
          (groupedOrders[invoiceNum]!['totalPrice'] as double) +
          (price * quantity);
    }

    return groupedOrders.values.toList();
  }

  static Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    await _orderCollection.doc(orderId).update({'status': newStatus});
  }

  static Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
  }
}
