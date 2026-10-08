import 'package:flutter/material.dart';

class MateriHeaderWidget extends StatelessWidget {
  const MateriHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;

    return Container(

        //settingan container
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
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
                        )
                ),
                // Container(
                //     decoration: const BoxDecoration(
                //     gradient: LinearGradient(
                //         begin: Alignment.centerLeft,
                //         end: Alignment.centerRight,
                //         colors: [
                //         Color(0xFF6336ED),
                //         Color(0xFF6336ED),
                //         Color(0x886336ED),
                //         ],
                //     ),
                //     ),
                // ),

                const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                            'MATA PELAJARAN',
                            style: TextStyle(color: Colors.white70),
                            ),

                            Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                                'Matematika',
                                style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            ),

                            Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                                'Angka, rumus, dan logika',
                                style: TextStyle(color: Colors.white70),
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
