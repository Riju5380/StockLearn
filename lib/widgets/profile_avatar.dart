import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final double iconSize;

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
      } else {
        // Custom device photo
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: kIsWeb
              ? NetworkImage(path)
              : FileImage(File(path)) as ImageProvider,
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
      child: Icon(Icons.person, size: iconSize, color: const Color(0xFF10B981)),
    );
  }
}
