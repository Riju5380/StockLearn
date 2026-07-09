import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/course.dart';
import 'course_viewer_screen.dart';

/// Screen displaying details of a specific course, allowing users to unlock it or launch classroom.
class CourseDetailsScreen extends StatefulWidget {
  /// The course details to be shown.
  final Course course;

  /// Creates a [CourseDetailsScreen] widget.
  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isFetchingCurriculum = false;

  @override
  void initState() {
    super.initState();
    if (widget.course.slug.isNotEmpty) {
      _fetchCurriculum();
    }
  }

  Future<void> _fetchCurriculum() async {
    setState(() {
      _isFetchingCurriculum = true;
    });
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.fetchAndSyncCourseDetails(widget.course.slug);
    if (mounted) {
      setState(() {
        _isFetchingCurriculum = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    // Dynamic course tracker to monitor updates from AppStateProvider
    final dynamicCourse = appState.courses.firstWhere(
      (c) => c.id == widget.course.id,
      orElse: () => widget.course,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPurchased = dynamicCourse.isPurchased;
    final canAfford = appState.walletBalance >= dynamicCourse.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Video/Header cover placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title, Category, Rating
                  Text(
                    dynamicCourse.category.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dynamicCourse.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 4),
                      Text('${dynamicCourse.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('${dynamicCourse.hours} Total Hours', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('By ${dynamicCourse.instructor}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    dynamicCourse.description,
                    style: TextStyle(height: 1.5, color: isDark ? Colors.grey[350] : Colors.grey[700]),
                  ),
                  const Divider(height: 32),

                  // Curriculum Lessons list
                  Text('Curriculum', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_isFetchingCurriculum && dynamicCourse.lessons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (dynamicCourse.lessons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No lessons available in curriculum.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dynamicCourse.lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lessonObj = dynamicCourse.lessons[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF151D30) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lessonObj.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Purchase / Learn Action Bottom Bar
            _buildActionBottomBar(context, appState, dynamicCourse, isPurchased, canAfford),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBottomBar(
      BuildContext context, AppStateProvider appState, Course course, bool isPurchased, bool canAfford) {
    
    VoidCallback? onPressed;
    String label = 'Unlock Course';
    Color btnColor = const Color(0xFF10B981); // Emerald green

    if (isPurchased) {
      btnColor = const Color(0xFF1E3A8A); // primary blue
      label = 'Go to Classroom';
      onPressed = () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CourseViewerScreen(course: course)),
        );
      };
    } else {
      if (!canAfford) {
        onPressed = null;
        label = 'Insufficient Balance (₹${course.price.toStringAsFixed(0)})';
      } else {
        onPressed = () async {
          final success = await appState.purchaseCourse(course);
          if (!context.mounted) return;
          if (success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text('Course Unlocked!'),
                  ],
                ),
                content: Text('Successfully purchased "${course.title}". It has been added to your purchased courses.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => CourseViewerScreen(course: course)),
                      );
                    },
                    child: const Text('Go to Classroom'),
                  ),
                ],
              ),
            );
          }
        };
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isPurchased)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    '₹${course.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
