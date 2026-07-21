import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_state_provider.dart';
import '../../models/course.dart';

/// Screen allowing users to view course contents, launch video lessons, and track progress.
///
/// Integrates with [url_launcher] to open lesson video URLs as Chrome links in the default browser.
class CourseViewerScreen extends StatefulWidget {
  /// The course which the user is viewing.
  final Course course;

  /// Creates a [CourseViewerScreen] widget.
  const CourseViewerScreen({super.key, required this.course});

  @override
  State<CourseViewerScreen> createState() => _CourseViewerScreenState();
}

class _CourseViewerScreenState extends State<CourseViewerScreen> {
  /// Index of the currently selected/active lesson.
  int _activeLessonIndex = 0;

  /// Launches the lesson video link in an external browser (e.g. Chrome).
  ///
  /// Automatically marks the lesson as completed upon launching the URL.
  Future<void> _playVideoLesson(String title, String videoUrl) async {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video link available for this lesson.')),
      );
      return;
    }

    final uri = Uri.tryParse(videoUrl);
    if (uri != null) {
      try {
        // Launch in external system browser (Chrome/Safari)
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Auto-complete the lesson on successful launch
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final dynamicCourse = appState.courses.firstWhere((c) => c.id == widget.course.id);
        
        if (!dynamicCourse.completedLessons.contains(title)) {
          await appState.toggleLessonCompletion(dynamicCourse, title);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lesson "$title" marked as completed!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        }
      } catch (e) {
        print('[CourseViewerScreen] Could not launch URL: $videoUrl. Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open lesson link: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final dynamicCourse = appState.courses.firstWhere(
      (c) => c.id == widget.course.id,
      orElse: () => widget.course,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeLesson = dynamicCourse.lessons.isNotEmpty
        ? dynamicCourse.lessons[_activeLessonIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(dynamicCourse.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Simulated/Link Video Player Info Box
            _buildVideoHeaderBox(activeLesson, isDark),

            // 2. Course Title and Progress Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Course Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(dynamicCourse.progress * 100).toStringAsFixed(0)}% Complete',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: dynamicCourse.progress,
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // 3. Curriculum Lessons list with check boxes
            Expanded(
              child: dynamicCourse.lessons.isEmpty
                  ? const Center(child: Text('No lessons in this course.'))
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: dynamicCourse.lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lessonObj = dynamicCourse.lessons[index];
                        final isCompleted = dynamicCourse.completedLessons.contains(lessonObj.title);
                        final isActive = _activeLessonIndex == index;

                        return Container(
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF2563EB).withOpacity(0.06)
                                : (isDark ? const Color(0xFF151D30) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF2563EB)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              width: isActive ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            leading: Checkbox(
                              value: isCompleted,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                appState.toggleLessonCompletion(dynamicCourse, lessonObj.title);
                              },
                            ),
                            title: Text(
                              lessonObj.title,
                              style: TextStyle(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.open_in_browser,
                                color: Color(0xFF2563EB),
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _activeLessonIndex = index;
                                });
                                _playVideoLesson(lessonObj.title, lessonObj.videoUrl);
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _activeLessonIndex = index;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the information box displaying details about the currently selected lesson.
  Widget _buildVideoHeaderBox(dynamic activeLesson, bool isDark) {
    if (activeLesson == null) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black87,
        child: const Center(child: Text('No lesson active', style: TextStyle(color: Colors.white))),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.black87,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chrome_reader_mode, size: 48, color: Colors.white54),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    activeLesson.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click the browser icon to watch lesson video',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _playVideoLesson(activeLesson.title, activeLesson.videoUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Watch Video', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Text(
                    'Chrome Video Link',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
