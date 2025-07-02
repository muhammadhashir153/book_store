class BookModel {
  final String? id;
  final String? title;
  final String? description;
  final String? authorName;
  final String? price;
  final String? genre;
  final String? imageUrl;

  BookModel({
    this.id,
    this.title,
    this.description,
    this.authorName,
    this.price,
    this.genre,
    this.imageUrl,
  });

  factory BookModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return BookModel(
      id: id,
      title: json['title'],
      description: json['description'],
      authorName: json['authorName'],
      price: json['price'],
      genre: json['genre'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'authorName': authorName,
      'price': price,
      'genre': genre,
      'imageUrl': imageUrl,
    };
  }

  /// Optional: fallback dummy/null-safe instance
  static BookModel get empty => BookModel(
    id: '',
    title: 'Unknown Book',
    description: '',
    authorName: '',
    price: '0',
    genre: '',
    imageUrl: '',
  );
}
