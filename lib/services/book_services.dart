import 'package:book_store/models/book_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  static final CollectionReference _booksCollection = FirebaseFirestore.instance
      .collection('Books');

  static Future<List<BookModel>> getAllBooks() async {
    final snapshot = await _booksCollection.get();
    return snapshot.docs
        .map(
          (doc) =>
              BookModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }
  
  static Future<BookModel?> getBookById(String id) async {
    final doc = await _booksCollection.doc(id).get();
    if (doc.exists) {
      return BookModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  static Future<void> addBook(BookModel book) async {
    await _booksCollection.add(book.toJson());
  }

  static Future<void> deleteBook(String id) async {
    await _booksCollection.doc(id).delete();
  }

  static Future<void> updateBook(String id, BookModel book) async {
    await _booksCollection.doc(id).update(book.toJson());
  }
}
