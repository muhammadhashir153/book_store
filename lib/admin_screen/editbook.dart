import 'dart:convert';
import 'dart:io' as io;

import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditBook extends StatefulWidget {
  final BookModel book;
  const EditBook({super.key, required this.book});

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;

  bool _isSubmitting = false;
  XFile? coverImage;
  String? genre;
  String? imageError;

  final List<String> genres = [
    'Fiction',
    'Non-Fiction',
    'Fantasy',
    'Romance',
    'Sci-Fi',
    'Biography',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _descController = TextEditingController(text: widget.book.description);
    _authorController = TextEditingController(text: widget.book.authorName);
    _priceController = TextEditingController(text: widget.book.price);
    genre = widget.book.genre;
  }

  Future<String> uploadCoverImage(XFile imageFile) async {
    const apiKey = '65cc0244b560b957fa8a47cc812a6963';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final response = await http.post(
      uri,
      body: {
        'image': base64Image,
        'name': 'book_cover_${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['url'];
    } else {
      throw Exception('Image upload failed: ${response.body}');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String coverImageUrl = widget.book.imageUrl ?? '';
      if (coverImage != null) {
        coverImageUrl = await uploadCoverImage(coverImage!);
      }

      final updatedBook = BookModel(
        id: widget.book.id,
        title: _titleController.text,
        description: _descController.text,
        authorName: _authorController.text,
        price: _priceController.text,
        genre: genre,
        imageUrl: coverImageUrl,
      );

      await BookService.updateBook(widget.book.id!, updatedBook);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully!')),
        );
        Navigator.pop(context); // Go back after update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update book: $e')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Edit Book"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Update Book Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter author name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: genre,
                items: genres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    genre = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select genre' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      coverImage = pickedFile;
                      imageError = null;
                    });
                  } else {
                    setState(() {
                      imageError = 'No image selected.';
                    });
                  }
                },
                child: const Text('Change Cover Image'),
              ),
              if (imageError != null)
                Text(imageError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Book'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Preview Cover Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              coverImage != null
                  ? (kIsWeb
                      ? Image.network(
                          coverImage!.path,
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          io.File(coverImage!.path),
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        ))
                  : Image.network(
                      widget.book.imageUrl ?? '',
                      height: 150,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
