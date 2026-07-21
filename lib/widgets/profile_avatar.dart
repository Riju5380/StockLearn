import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

/// A reusable profile avatar widget that displays the user's selected profile picture.
///
/// Automatically retrieves profile picture path/data from [AppStateProvider].
/// Handles database-stored base64 image strings, remote image URLs,
/// local file images, preset avatar graphics, and default icons.
class ProfileAvatar extends StatelessWidget {
  /// The radius size of the circular avatar.
  final double radius;

  /// The size of the icon inside the avatar if no custom image is set.
  final double iconSize;

  /// Creates a [ProfileAvatar] widget.
  const ProfileAvatar({
    super.key,
    this.radius = 16,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final path = appState.profilePicturePath;

    if (path.isNotEmpty) {
      if (path.startsWith('preset_')) {
        final index = int.tryParse(path.split('_')[1]) ?? 0;
        final List<Color> colors = [
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.teal,
          Colors.indigo,
          Colors.amber,
        ];
        final List<IconData> icons = [
          Icons.face,
          Icons.sentiment_very_satisfied,
          Icons.cruelty_free,
          Icons.emoji_emotions,
          Icons.pets,
          Icons.sports_esports,
          Icons.star,
          Icons.bolt,
        ];
        final color = colors[index % colors.length];
        final icon = icons[index % icons.length];
        return CircleAvatar(
          radius: radius,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: iconSize, color: color),
        );
      } else if (path.startsWith('http') || path.startsWith('https')) {
        // Remote image URL from database API
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(path),
        );
      } else if (path.length > 200) {
        // Base64 encoded image string stored in database
        try {
          final cleanBase64 = path.contains(',') ? path.split(',')[1] : path;
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.transparent,
            backgroundImage: MemoryImage(base64Decode(cleanBase64)),
          );
        } catch (e) {
          print('[ProfileAvatar] Failed to decode base64 avatar image: $e');
        }
      } else {
        // Custom local device photo file path
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: kIsWeb
              ? NetworkImage(path)
              : FileImage(File(path)) as ImageProvider,
        );
      }
    }

    // Default icon avatar if no profile picture is set
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
      child: Icon(Icons.person, size: iconSize, color: const Color(0xFF10B981)),
    );
  }
}
