import 'package:flutter/material.dart';

class MateriHeaderWidget extends StatelessWidget {
  final String subjectName;
  final String description;

  const MateriHeaderWidget({
    super.key,
    this.subjectName = 'Matematika',
    this.description = 'Angka, rumus, dan logika',
  });

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;

    return Container(
      //settingan container
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      width: double.infinity,
      height: screenwidth * 0.42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      //settingan container

      // isi container
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.35),
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MATA PELAJARAN',
                  style: TextStyle(color: Colors.white70),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // isi container
    );
  }
}
