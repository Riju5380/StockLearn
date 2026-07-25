import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/course.dart';
import '../../widgets/profile_avatar.dart';
import 'course_details_screen.dart';
import 'course_viewer_screen.dart';
import '../../utils/dialogs.dart';

/// Screen presenting the Virtual Academy Learning marketplace.
///
/// Contains two main tabs:
/// 1. Browse Marketplace: List of virtual skill/trading courses available to unlock.
/// 2. My Purchased Courses: List of unlocked courses with user progress indicators.
class ClassesScreen extends StatefulWidget {
  /// Creates a [ClassesScreen].
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> with SingleTickerProviderStateMixin {
  /// Controller managing tab navigation between Marketplace and Purchased items.
  late TabController _tabController;

  /// Controller managing user input in the search field.
  final _searchController = TextEditingController();

  /// Focus node for search keyboard control.
  final _searchFocusNode = FocusNode();

  /// Selected category filter (defaults to 'All').
  String _selectedCategory = 'All';


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  /// Synchronizes tab controller updates with AppStateProvider's active tab index.
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      if (appState.classesTabIndex != _tabController.index) {
        appState.setClassesTabIndex(_tabController.index);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context);
    if (_tabController.index != appState.classesTabIndex) {
      _tabController.animateTo(appState.classesTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Academy Learning', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_tabController.index != 0) {
                _tabController.animateTo(0);
              }
              _searchFocusNode.requestFocus();
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
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          dividerHeight: 0.0,
          indicatorColor: const Color(0xFF1E3A8A),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Browse Marketplace'),
            Tab(text: 'My Purchased Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(context, appState, isDark),
          _buildMyCoursesTab(context, appState, isDark),
        ],
      ),
    );
  }

  // Browse Courses Tab
  Widget _buildBrowseTab(BuildContext context, AppStateProvider appState, bool isDark) {
    if (appState.courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Courses Published Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'No virtual learning tracks have been published by the admin panel yet. Check back soon for academy content!',
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
                label: const Text('Reload Academy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final searchVal = _searchController.text.toLowerCase();

    // Dynamically build category list from database courses
    final dynamicCategories = <String>[];
    for (final course in appState.courses) {
      final cat = course.category.trim();
      if (cat.isNotEmpty && !dynamicCategories.any((c) => c.toLowerCase() == cat.toLowerCase())) {
        dynamicCategories.add(cat);
      }
    }
    final categories = ['All', ...dynamicCategories];

    // Filter available courses
    final availableCourses = appState.courses.where((course) {
      final matchesCat = _selectedCategory == 'All' ||
          course.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = course.title.toLowerCase().contains(searchVal) ||
          course.instructor.toLowerCase().contains(searchVal);
      return matchesCat && matchesSearch;
    }).toList();

    // Find featured course (c1 by default)
    final featuredCourse = appState.courses.firstWhere((c) => c.id == 'c1', orElse: () => appState.courses[0]);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          // Subtitle Marketplace Info matching screenshots
          Text(
            'Virtual Skill Marketplace',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            'High-quality simulated courses. Enhance your skills across multiple fields using virtual money.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Search Field
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search virtual courses...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDark ? const Color(0xFF151D30) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Horizontal Categories
          _buildCategoryChips(isDark, categories),
          const SizedBox(height: 20),

          // Featured Track Section Header
          Text('Featured Track', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          _buildFeaturedCourseCard(context, featuredCourse, isDark),
          const SizedBox(height: 24),

          // Clinical community promotion card matching screenshots
          _buildCommunityCard(isDark),
          const SizedBox(height: 24),

          // Trending Courses Header
          Text('Trending Now', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableCourses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCourseRowItem(context, availableCourses[index], isDark);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Purchased Courses Tab
  Widget _buildMyCoursesTab(BuildContext context, AppStateProvider appState, bool isDark) {
    final purchasedCourses = appState.courses.where((c) => c.isPurchased).toList();

    if (purchasedCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Purchased Courses Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Buy courses from the Browse Marketplace tab using your virtual wallet balance.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Browse Courses', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: purchasedCourses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final course = purchasedCourses[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CourseViewerScreen(course: course)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151D30) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Color(0xFF10B981), size: 28),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('By ${course.instructor}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 8),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: course.progress,
                                minHeight: 4,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(course.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Chips categories
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

  // Featured Course Card matching screenshots
  Widget _buildFeaturedCourseCard(BuildContext context, Course course, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(Icons.school, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[500]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CME ACCREDITED',
                          style: TextStyle(color: Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(course.category, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          Text('${course.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('by ${course.instructor}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      Text(
                        '₹${course.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Community promotion card
  Widget _buildCommunityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school_outlined, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          const Text(
            'Academy Community',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Join professional peer reviews and weekly live case studies with expert mentors.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showUnderDevelopmentDialog(context, 'Academy Registry');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Join Registry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Row item trending
  Widget _buildCourseRowItem(BuildContext context, Course course, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(Icons.play_circle_outline, size: 44, color: isDark ? Colors.grey[600] : Colors.grey[500]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(course.category.toUpperCase(), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(6)),
                        child: Text('${course.hours} Hours', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('by ${course.instructor}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          Text('${course.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '₹${course.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
