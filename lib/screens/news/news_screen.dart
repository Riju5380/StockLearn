import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/news_article.dart';
import '../../widgets/profile_avatar.dart';
import 'news_detail_screen.dart';
import 'bookmarked_news_screen.dart';

/// Screen presenting the financial news section.
///
/// Dynamically fetches and listens to market news from the [AppStateProvider]
/// connected to the Admin Panel API.
class NewsScreen extends StatefulWidget {
  /// Creates a [NewsScreen] widget.
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  /// Currently selected category filter for the news feed.
  String _selectedCategory = 'All Stories';


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final allArticles = appState.news;

    // Empty news state page
    if (allArticles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('StockLearn News', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmarks_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookmarkedNewsScreen()),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.newspaper, size: 64, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No News Published Yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Check back later! The admin has not published any financial news or regulatory announcements yet.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    appState.loadApiData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
                  label: const Text('Refresh Feed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Dynamically build category list from database articles
    final dynamicCategories = <String>[];
    for (final article in allArticles) {
      final cat = article.category.trim();
      if (cat.isNotEmpty && !dynamicCategories.any((c) => c.toLowerCase() == cat.toLowerCase())) {
        dynamicCategories.add(cat);
      }
    }
    final categories = ['All Stories', ...dynamicCategories];

    // Identify the featured article (n_featured) or fallback to first
    final featuredArticle = allArticles.firstWhere(
      (a) => a.id == 'n_featured',
      orElse: () => allArticles.first,
    );

    // List of non-featured articles
    final otherArticles = allArticles.where((a) => a.id != featuredArticle.id).toList();

    // Filter stories by category if not 'All Stories'
    final finalArticles = _selectedCategory == 'All Stories'
        ? otherArticles
        : otherArticles.where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StockLearn News', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarkedNewsScreen()),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Provider.of<AppStateProvider>(context, listen: false).setNavigationIndex(3);
            },
            child: const Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ProfileAvatar(radius: 16, iconSize: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Featured News Card (Interest Rates Stabilization)
          if (_selectedCategory == 'All Stories') ...[
            _buildFeaturedCard(context, featuredArticle, isDark),
            const SizedBox(height: 20),
          ],

          // 2. Horizontally scrollable Category Chips
          _buildCategoryChips(isDark, categories),
          const SizedBox(height: 20),

          // 3. News stories list
          if (finalArticles.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'No stories found.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: finalArticles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNewsCard(context, finalArticles[index], isDark);
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Top featured card
  Widget _buildFeaturedCard(BuildContext context, NewsArticle article, bool isDark) {
    final appState = Provider.of<AppStateProvider>(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    article.category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.snippet,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Read Full Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    Text(
                      '${article.source} • ${article.timeAgo}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  appState.bookmarkedNewsIds.contains(article.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  appState.toggleNewsBookmark(article.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Categories list
  Widget _buildCategoryChips(bool isDark, List<String> categories) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = cat;
              });
            },
            selectedColor: const Color(0xFF1E3A8A),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: isDark ? const Color(0xFF151D30) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  // Row card matching screenshots
  Widget _buildNewsCard(BuildContext context, NewsArticle article, bool isDark) {
    final appState = Provider.of<AppStateProvider>(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(article.category.toUpperCase(), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('${article.source} • ${article.timeAgo}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.snippet,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    appState.bookmarkedNewsIds.contains(article.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: appState.bookmarkedNewsIds.contains(article.id)
                        ? const Color(0xFF2563EB)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    appState.toggleNewsBookmark(article.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // News Thumbnail simulation
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.image_outlined, color: isDark ? Colors.grey[700] : Colors.grey[400], size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
