import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/news_article.dart';
import '../../utils/dialogs.dart';

/// Screen showing the full content and details of a selected news article.
class NewsDetailScreen extends StatelessWidget {
  /// The news article to display.
  final NewsArticle article;

  /// Creates a [NewsDetailScreen] widget.
  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Article', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<AppStateProvider>(context).bookmarkedNewsIds.contains(article.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: () {
              Provider.of<AppStateProvider>(context, listen: false).toggleNewsBookmark(article.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              showUnderDevelopmentDialog(context, 'Sharing news');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            // Category & Source header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.category.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${article.source} • ${article.timeAgo}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Title
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Banner Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.newspaper, size: 60, color: isDark ? Colors.grey[700] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 20),

            // Snippet Highlight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                article.snippet,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Content Body Paragraphs
            Text(
              article.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 30),

            const Divider(),
            const SizedBox(height: 10),

            // Educational Glossary card
            _buildGlossaryCard(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGlossaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFF10B981), size: 18),
              SizedBox(width: 8),
              Text(
                'Financial Knowledge Core',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep trading in our Stocks tab. Real-world events described in this article will reflect in simulated price shifts. Analyze trends carefully!',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
