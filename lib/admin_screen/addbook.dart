import 'dart:convert';
import 'dart:io' as io;

import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Addbook extends StatefulWidget {
  const Addbook({super.key});

  // final String title;

  @override
  State<Addbook> createState() => _AddbookState();
}

class _AddbookState extends State<Addbook> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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
    if (coverImage == null) {
      setState(() {
        imageError = 'Please select a cover image.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String coverImageUrl = await uploadCoverImage(coverImage!);
      final newBook = BookModel(
        title: _titleController.text,
        description: _descController.text,
        authorName: _authorController.text,
        price: _priceController.text,
        genre: genre,
        imageUrl: coverImageUrl,
      );
      await BookService.addBook(newBook);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully!')),
        );
      }

      setState(() {
        _titleController.clear();
        _descController.clear();
        _authorController.clear();
        _priceController.clear();
        genre = null;
        coverImage = null;
        imageError = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add book: $e')));
      }
      // print('Error adding book: $e');
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
        title: Text("Add Book"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Enter Book Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Author Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: genre,
                items: genres.map((String g) {
                  return DropdownMenuItem<String>(value: g, child: Text(g));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    genre = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a genre';
                  }
                  return null;
                },
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
                child: const Text('Select Cover Image'),
              ),
              if (imageError != null)
                Text(imageError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Preview Cover Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (coverImage != null)
                kIsWeb
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
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
