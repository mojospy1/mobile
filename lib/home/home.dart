import 'package:apphoctienganh/Authencation/profile.dart';
import 'package:apphoctienganh/Flashcash/createflashcard.dart';
import 'package:apphoctienganh/home/HomeProvider.dart';
import 'package:apphoctienganh/home/memorycard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreakIndicator extends StatefulWidget {
  const StreakIndicator({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StreakIndicatorState createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> {
  late int selectedDay;

  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();

    selectedDay = DateTime.now().weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange),
            SizedBox(width: 10),
            ...List.generate(days.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildDayIndicator(days[index], index),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDayIndicator(String day, int index) {
    bool isHighlighted = selectedDay == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isHighlighted ? Colors.orange.withOpacity(0.3) : Colors.grey[300],
        ),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(color: isHighlighted ? Colors.orange : Colors.black),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Gọi loadData khi vào màn Home
    context.read<HomeProvider>().loadDataforsetstateinhomepage();
  }

  // Kiểm tra kết nối khi ứng dụng vừa m
  @override
  Widget build(BuildContext context) {
    final flashcardLists = context.watch<HomeProvider>().flashcardLists;
    int currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Trang chủ '),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: const StreakIndicator(),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Đã nghiên cứu và xem gần đây',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text('Xem tất cả', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "CÁC HỌC PHẦN ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            flashcardLists.isEmpty
                ? const Center(
                  child: Text(
                    'Nhấn vào nút + để tạo bộ flashcard mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Color.fromRGBO(59, 157, 146, 1),
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: (flashcardLists.length / 2).ceil(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    int firstIndex = index * 2;
                    int secondIndex = firstIndex + 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MemoryCard(
                            flashcardList:
                                context
                                    .read<HomeProvider>()
                                    .flashcardLists[firstIndex],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (secondIndex < flashcardLists.length)
                          Expanded(
                            child: MemoryCard(
                              flashcardList:
                                  context
                                      .read<HomeProvider>()
                                      .flashcardLists[secondIndex],
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    );
                  },
                ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateFlashcard()),
            );
          },
          backgroundColor: const Color.fromRGBO(83, 209, 197, 1),
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex)
            return; // Không làm gì nếu chọn lại tab đang ở

          setState(() {
            currentIndex = index;
          });

          Widget nextPage;

          if (index == 0) {
            nextPage = HomePage();
          } else if (index == 1) {
            nextPage = CreateFlashcard();
          } else {
            nextPage = ProfileScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ "),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Flashcard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Người dùng",
          ),
        ],

        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
