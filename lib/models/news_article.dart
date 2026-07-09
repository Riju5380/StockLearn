/// Represents a news article containing headlines and content about trading,
/// regulatory activity, taxation, and global finance.
class NewsArticle {
  /// The unique identifier of the news article.
  final String id;

  /// The category of the news (e.g. Market, Global, Regulatory, Taxes).
  final String category;

  /// The headline/title of the article.
  final String title;

  /// A brief summary/preview snippet of the article.
  final String snippet;

  /// The complete body text content of the article.
  final String content;

  /// The publication or source (e.g. Bloomberg, Reuters).
  final String source;

  /// The human-readable string indicating when the article was published (e.g. "12 mins ago").
  final String timeAgo;

  /// The image URL or image name string associated with the article.
  final String imageUrl;

  /// Creates a [NewsArticle] instance.
  const NewsArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.snippet,
    required this.content,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
  });

  /// Factory constructor to parse a [NewsArticle] from a JSON map.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
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

    String timeAgoStr = 'Recently';
    if (json['published_at'] != null) {
      try {
        final parsedTime = DateTime.parse(json['published_at'] as String);
        final diff = DateTime.now().difference(parsedTime);
        if (diff.inDays > 0) {
          timeAgoStr = '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          timeAgoStr = '${diff.inHours}h ago';
        } else if (diff.inMinutes > 0) {
          timeAgoStr = '${diff.inMinutes}m ago';
        } else {
          timeAgoStr = 'Just now';
        }
      } catch (_) {
        timeAgoStr = 'Recently';
      }
    } else if (json['timeAgo'] != null) {
      timeAgoStr = json['timeAgo'] as String;
    }

    return NewsArticle(
      id: idStr,
      category: categoryName,
      title: json['title'] as String? ?? '',
      snippet: json['summary'] as String? ?? json['snippet'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: json['source_name'] as String? ?? json['source'] as String? ?? 'Unknown',
      timeAgo: timeAgoStr,
      imageUrl: json['featured_image'] as String? ?? json['imageUrl'] as String? ?? '',
    );
  }

  /// Converts this [NewsArticle] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'snippet': snippet,
      'content': content,
      'source': source,
      'timeAgo': timeAgo,
      'imageUrl': imageUrl,
    };
  }
}
