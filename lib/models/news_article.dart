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
    return NewsArticle(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: json['source'] as String? ?? 'Unknown',
      timeAgo: json['timeAgo'] as String? ?? 'Recently',
      imageUrl: json['imageUrl'] as String? ?? '',
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
