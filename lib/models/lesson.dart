/// Represents a single lesson/lecture within a course curriculum.
///
/// Each lesson contains a title and an external link (Chrome video URL)
/// that the user can launch to watch the video session.
class Lesson {
  /// The user-visible title of this lesson.
  final String title;

  /// The external web URL (Chrome link) where the video is hosted.
  final String videoUrl;

  /// Creates a [Lesson] instance.
  ///
  /// Requires a [title] and a [videoUrl] link.
  const Lesson({
    required this.title,
    required this.videoUrl,
  });

  /// Factory constructor to parse a [Lesson] from a JSON map.
  ///
  /// Expects `title` (String) and `videoUrl` (String) keys.
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      title: json['title'] as String? ?? 'Untitled Lesson',
      videoUrl: json['videoUrl'] as String? ?? json['video_url'] as String? ?? '',
    );
  }

  /// Converts this [Lesson] instance into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoUrl': videoUrl,
    };
  }
}
