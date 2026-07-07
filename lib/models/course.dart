class Course {
  final String id;
  final String title;
  final String category;
  final String instructor;
  final double price;
  final double hours;
  final double rating;
  final String description;
  final List<String> lessons;
  final List<String> completedLessons;
  final String coverImage;
  bool isPurchased;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.price,
    required this.hours,
    required this.rating,
    required this.description,
    required this.lessons,
    this.completedLessons = const [],
    required this.coverImage,
    this.isPurchased = false,
  });

  double get progress {
    if (lessons.isEmpty) return 0.0;
    return completedLessons.length / lessons.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'instructor': instructor,
      'price': price,
      'hours': hours,
      'rating': rating,
      'description': description,
      'lessons': lessons,
      'completedLessons': completedLessons,
      'coverImage': coverImage,
      'isPurchased': isPurchased,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      instructor: json['instructor'],
      price: json['price'].toDouble(),
      hours: json['hours'].toDouble(),
      rating: json['rating'].toDouble(),
      description: json['description'],
      lessons: List<String>.from(json['lessons']),
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      coverImage: json['coverImage'],
      isPurchased: json['isPurchased'] ?? false,
    );
  }

  Course copyWith({
    List<String>? completedLessons,
    bool? isPurchased,
  }) {
    return Course(
      id: id,
      title: title,
      category: category,
      instructor: instructor,
      price: price,
      hours: hours,
      rating: rating,
      description: description,
      lessons: lessons,
      completedLessons: completedLessons ?? this.completedLessons,
      coverImage: coverImage,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}
