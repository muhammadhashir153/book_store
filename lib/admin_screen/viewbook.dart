import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:book_store/admin_screen/editbook.dart';
import 'package:book_store/admin_screen/addbook.dart';
import 'package:flutter/material.dart';

class ViewBooks extends StatefulWidget {
  const ViewBooks({super.key});

  @override
  State<ViewBooks> createState() => _ViewBooksState();
}

class _ViewBooksState extends State<ViewBooks> {
  List<BookModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final books = await BookService.getAllBooks();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  Future<void> _deleteBook(String id) async {
    await BookService.deleteBook(id);
    fetchBooks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book deleted successfully')),
    );
  }

  void _editBook(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBook(book: book),
      ),
    ).then((_) => fetchBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(child: Text('No books available'))
              : ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return ListTile(
                      leading: Image.network(
                        book.imageUrl ?? '',
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      ),
                      title: Text(book.title ?? ''),
                      subtitle: Text(book.authorName ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBook(book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBook(book.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Addbook()),
      ).then((_) => fetchBooks()); // refresh after returning
    },
    child: const Icon(Icons.add),
    tooltip: 'Add New Book',
  ),
    );
  }
}
