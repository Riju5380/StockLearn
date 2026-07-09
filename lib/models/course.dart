import 'lesson.dart';

/// Represents a Course uploaded by the admin, containing description, price, and curriculum lessons.
class Course {
  /// The unique identifier of the course.
  final String id;

  /// The title of the course.
  final String title;

  /// The category of the course (e.g. Trading, Investment).
  final String category;

  /// The name of the course instructor.
  final String instructor;

  /// The virtual money price required to unlock the course.
  final double price;

  /// The duration of the course in hours.
  final double hours;

  /// The rating of the course (e.g. 4.9).
  final double rating;

  /// A detailed description of the course content.
  final String description;

  /// The list of [Lesson]s included in the course.
  final List<Lesson> lessons;

  /// The list of completed lesson titles for progress tracking.
  final List<String> completedLessons;

  /// The name or URL of the cover image asset.
  final String coverImage;

  /// Flag indicating whether the user has purchased/unlocked this course.
  bool isPurchased;

  /// Creates a [Course] instance.
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

  /// Computes progress as a fraction from 0.0 to 1.0.
  double get progress {
    if (lessons.isEmpty) return 0.0;
    return completedLessons.length / lessons.length;
  }

  /// Converts this [Course] instance into a JSON-compatible map.
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
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'completedLessons': completedLessons,
      'coverImage': coverImage,
      'isPurchased': isPurchased,
    };
  }

  /// Factory constructor to parse a [Course] from a JSON map.
  factory Course.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List? ?? [];
    List<Lesson> parsedLessons = lessonsList
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();

    return Course(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      instructor: json['instructor'] as String? ?? 'Unknown',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      hours: (json['hours'] as num? ?? 0.0).toDouble(),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      description: json['description'] as String? ?? '',
      lessons: parsedLessons,
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      coverImage: json['coverImage'] as String? ?? '',
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }

  /// Creates a copy of this Course with updated progress or purchase status.
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
