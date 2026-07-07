import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/profile_avatar.dart';
import 'news_detail_screen.dart';
import 'bookmarked_news_screen.dart';

class NewsArticle {
  final String id;
  final String category;
  final String title;
  final String snippet;
  final String content;
  final String source;
  final String timeAgo;
  final String imageUrl;

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
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  // Global static list of all news articles, including the featured one
  static const List<NewsArticle> allArticles = [
    NewsArticle(
      id: 'n_featured',
      category: 'Global',
      title: 'Interest Rates Stabilize as Inflation Targets Approach',
      snippet: 'Leading central banks indicate a shift toward neutrality as the latest consumer price index (CPI) prints align with long-term targets.',
      content: 'Central banks in major economies have signaled that the aggressive cycle of monetary tightening is coming to an end. In their latest joint policy statement, representatives highlighted that price pressures are cooling, with the consumer price index (CPI) approaching the target rate of 2%.\n\nWhile central bankers emphasized that they will remain data-dependent, the market has responded positively, pricing in a high probability of rate cuts later this autumn. Bond yields have settled, and indices have rallied in response to the anticipation of cheaper borrowing costs.\n\nEconomists warning of potential lagged recessionary effects urge caution, suggesting that keeping interest rates higher for slightly too long is a safer option than cutting premature policy lines.',
      source: 'Financial Times',
      timeAgo: '12 mins ago',
      imageUrl: 'featured_inflation',
    ),
    NewsArticle(
      id: 'n1',
      category: 'Market',
      title: 'Semiconductor Rally Continues Amidst AI Supply Chain Breakthroughs',
      snippet: 'Nvidia and AMD shares hit fresh record highs as major cloud providers boost capital expenditure budgets for next-gen data centers.',
      content: 'Major technology companies have announced a significant increase in capital expenditure budgets for artificial intelligence infrastructure. Global semiconductor manufacturers are reporting record-high backlogs, signaling that demand for advanced graphics processors and accelerators shows no sign of slowing down.\n\nAnalysts at major institutions suggest that supply chain optimizations in East Asia have helped resolve bottlenecks that plagued the industry last year. However, pricing power remains strong, keeping profit margins elevated for key chip designs and fabrication firms.\n\nRetail traders have actively participated in this rally, though financial advisers warn of premium valuations and elevated volatility in tech portfolios.',
      source: 'Bloomberg',
      timeAgo: '45 mins ago',
      imageUrl: 'semiconductor_rally',
    ),
    NewsArticle(
      id: 'n2',
      category: 'Regulatory',
      title: 'SEC Updates Framework for Digital Asset Custody Requirements',
      snippet: 'The Securities and Exchange Commission issued new guidance targeting institutional digital asset storage, creating stricter capital buffers.',
      content: 'The Securities and Exchange Commission (SEC) has released an updated framework outlining stricter custody rules for broker-dealers and asset managers dealing with digital currencies and tokenized assets.\n\nUnder the new guidelines, institutional platforms must maintain higher liquidity buffers and verify digital asset reserves on a weekly basis through independent third-party audits. The move has sparked mixed reactions; consumer advocacy groups have lauded it as a shield against platform insolvencies, while industry coalitions argue that the regulatory overhead could stifle innovation and push firms offshore.\n\nFirms have been given six months to align their backend infrastructure with the new compliance regulations.',
      source: 'Reuters',
      timeAgo: '2 hrs ago',
      imageUrl: 'sec_custody',
    ),
    NewsArticle(
      id: 'n3',
      category: 'Global',
      title: 'European Energy Prices Diverge Following Renewables Surge',
      snippet: 'Northern European markets record negative pricing during peak wind and solar production hours, driving grids to export excess electricity.',
      content: 'Divergent weather patterns across Europe have resulted in unprecedented spreads in regional electricity rates. Strong winds in the North Sea and clear sunshine across Iberia led to record renewable output, pushing power prices below zero in several countries during midday hours.\n\nGrid operators were forced to offer negative pricing to balance power lines. Meanwhile, other countries with lower grid interconnection capacities relied on backup fossil fuel generators, keeping localized household rates high. This divergence highlights the pressing need for massive grid infrastructure upgrades and large-scale battery storage installations across the continent.',
      source: 'Wall Street Journal',
      timeAgo: '4 hrs ago',
      imageUrl: 'european_energy',
    ),
    NewsArticle(
      id: 'n4',
      category: 'Taxes',
      title: 'New Capital Gains Tax Rate Proposals Debated in Parliament',
      snippet: 'Proposed amendments seek to adjust Short-Term Capital Gains (STCG) tax thresholds to close loopholes on high-frequency retail trades.',
      content: 'A new tax bill proposed in the national legislature seeks to restructure the taxation of retail securities transactions. Under the proposed amendments, profits realized from asset sales held for less than 90 days would attract a premium surcharge, effectively creating a tiered short-term capital gains tax structure.\n\nProponents of the bill argue it will curb speculative day-trading volatility and incentivize long-term investments that support economic stability. Critics, however, state that higher transaction charges will reduce retail liquidity and penalize small-scale traders trying to leverage market volatility.\n\nThe debate is set to continue next week, with market associations lobbying for exceptions for standard index funds and retirement accounts.',
      source: 'Financial Times',
      timeAgo: '1 day ago',
      imageUrl: 'taxation_news',
    ),
  ];

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All Stories';
  final List<String> _categories = ['All Stories', 'Market', 'Global', 'Regulatory', 'Taxes'];

  // Retrieve non-featured articles from global static list
  late final List<NewsArticle> _articles = NewsScreen.allArticles
      .where((a) => a.id != 'n_featured')
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter articles
    final finalArticles = _selectedCategory == 'All Stories'
        ? _articles
        : _articles.where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    // Featured article for top card (Interest Rates)
    final featuredArticle = NewsScreen.allArticles.firstWhere((a) => a.id == 'n_featured');

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
          _buildCategoryChips(isDark),
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
  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
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
