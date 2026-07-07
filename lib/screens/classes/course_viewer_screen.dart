import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/course.dart';

class CourseViewerScreen extends StatefulWidget {
  final Course course;

  const CourseViewerScreen({super.key, required this.course});

  @override
  State<CourseViewerScreen> createState() => _CourseViewerScreenState();
}

class _CourseViewerScreenState extends State<CourseViewerScreen> {
  int _activeLessonIndex = 0;
  bool _isPlaying = false;
  double _playbackProgress = 0.0;

  void _simulateVideoPlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _playbackProgress = 0.0;
    });

    if (_isPlaying) {
      // Small simulated ticker
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted || !_isPlaying) return false;
        
        setState(() {
          _playbackProgress += 0.05;
        });

        if (_playbackProgress >= 1.0) {
          setState(() {
            _playbackProgress = 1.0;
            _isPlaying = false;
          });
          
          // Auto complete the lesson!
          final appState = Provider.of<AppStateProvider>(context, listen: false);
          final dynamicCourse = appState.courses.firstWhere((c) => c.id == widget.course.id);
          final activeLesson = dynamicCourse.lessons[_activeLessonIndex];
          
          if (!dynamicCourse.completedLessons.contains(activeLesson)) {
            appState.toggleLessonCompletion(dynamicCourse, activeLesson);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Completed Lesson: "$activeLesson"')),
            );
          }
          return false;
        }
        return true;
      });
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
    final activeLessonTitle = dynamicCourse.lessons[_activeLessonIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(dynamicCourse.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Simulated Video Player Box
            _buildVideoPlayerBox(activeLessonTitle, isDark),

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

            // 3. Lessons List with check boxes
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dynamicCourse.lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lesson = dynamicCourse.lessons[index];
                  final isCompleted = dynamicCourse.completedLessons.contains(lesson);
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
                          appState.toggleLessonCompletion(dynamicCourse, lesson);
                        },
                      ),
                      title: Text(
                        lesson,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isActive && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                          color: isActive ? const Color(0xFF2563EB) : Colors.grey,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _activeLessonIndex = index;
                            _isPlaying = false;
                            _playbackProgress = 0.0;
                          });
                          _simulateVideoPlay();
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _activeLessonIndex = index;
                          _isPlaying = false;
                          _playbackProgress = 0.0;
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

  // Video box simulator
  Widget _buildVideoPlayerBox(String activeLesson, bool isDark) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.black87,
      child: Stack(
        children: [
          // Background graphic
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 48, color: Colors.white24),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    activeLesson,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPlaying ? 'Simulating Playback...' : 'Video Paused',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Playback progress indicator at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _playbackProgress,
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 20),
                        onPressed: _simulateVideoPlay,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        _isPlaying
                            ? '${(_playbackProgress * 100).toStringAsFixed(0)}%'
                            : '00:00 / 10:00',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
