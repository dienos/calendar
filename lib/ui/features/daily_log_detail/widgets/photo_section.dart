import 'dart:io';
import 'package:flutter/material.dart';

class PhotoSection extends StatelessWidget {
  final List<String> images;

  const PhotoSection({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final controller = PageController(viewportFraction: 0.85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('오늘의 사진', style: theme.textTheme.titleMedium),
                ],
              ),
              Text('옆으로 밀어보기', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
