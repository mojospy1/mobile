import 'package:apphoctienganh/home/net_stepcrad.dart';
import 'package:apphoctienganh/model/listflashcard.dart';
import 'package:flutter/material.dart';

class MemoryCard extends StatefulWidget {
  final FlashcardList flashcardList;

  const MemoryCard({super.key, required this.flashcardList});

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  @override
  Widget build(BuildContext context) {
    return _buildCard(widget.flashcardList);
  }

  Widget _buildCard(FlashcardList flashcardList) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
         FlashcardScreen(flashcardList: flashcardList),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color.fromRGBO(71, 142, 135, 1), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon trong vòng tròn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Icon(
                Icons.insert_drive_file,
                color: Color.fromRGBO(83, 209, 197, 1),
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            // Tiêu đề
            Text(
              flashcardList.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            // Nghiên cứu bởi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Nghiên cứu bởi 0",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Đánh giá sao
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "0.0 (0)",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
