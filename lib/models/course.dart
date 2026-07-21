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

  /// The URL-friendly identifier of the course.
  final String slug;

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
    this.slug = '',
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
      'slug': slug,
    };
  }

  /// Factory constructor to parse a [Course] from a JSON map.
  factory Course.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final idVal = json['id'];
    final idStr = idVal?.toString() ?? '';

    String categoryName = 'General';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        categoryName = json['category']['name'] as String? ?? 'General';
      } else if (json['category'] is String) {
        categoryName = json['category'] as String;
      }
    }

    var lessonsList = json['lessons'] as List? ?? json['modules'] as List? ?? [];
    List<Lesson> parsedLessons = lessonsList
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();

    return Course(
      id: idStr,
      title: json['title'] as String? ?? '',
      category: categoryName,
      instructor: json['instructor_name'] as String? ?? json['instructor'] as String? ?? 'Unknown',
      price: toDouble(json['price']),
      hours: toDouble(json['total_hours'] ?? json['hours']),
      rating: toDouble(json['avg_rating'] ?? json['rating']),
      description: json['description'] as String? ?? '',
      lessons: parsedLessons,
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      coverImage: json['thumbnail'] as String? ?? json['coverImage'] as String? ?? '',
      isPurchased: json['isPurchased'] as bool? ?? false,
      slug: json['slug'] as String? ?? '',
    );
  }

  /// Creates a copy of this Course with updated progress or purchase status.
  Course copyWith({
    List<String>? completedLessons,
    bool? isPurchased,
    String? slug,
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
      slug: slug ?? this.slug,
    );
  }
}
