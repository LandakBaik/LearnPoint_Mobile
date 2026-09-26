import 'package:flutter/material.dart';

import '../../models/materi_page.dart';

class SubjectMateriCardWidget extends StatelessWidget {
  final MateriModel subject;
  final String imageUrl;
  final double elevation;

  const SubjectMateriCardWidget({
    super.key,
    required this.subject,
    required this.imageUrl,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      color: subject.color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: subject.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(subject.icon, color: subject.iconColor),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.materi, style: const TextStyle(fontSize: 20)),
                    Text(subject.description),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
