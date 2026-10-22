import 'package:flutter/material.dart';

import '../../models/materi_page.dart';

class SubjectMateriCardWidget extends StatelessWidget {
  final MateriModel subject;
  final String imageUrl;
  final double elevation;
  final double horizontalMargin;
  final VoidCallback? ontap;

  const SubjectMateriCardWidget({
    super.key,
    required this.subject,
    required this.imageUrl,
    this.elevation = 0,
    this.horizontalMargin = 20,
    this.ontap
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();

    return Card(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 5, horizontalMargin, 10),
      color: subject.color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: subject.color.withValues(alpha: 0.18)),
      ),

      child: InkWell(
        onTap: ontap,
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
                    Text(
                      subject.materi,
                      style: TextStyle(fontSize: 20 * textScale),
                    ),
                    Text(
                      subject.description,
                      style: TextStyle(fontSize: 14 * textScale),
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
