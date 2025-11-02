import 'package:apphoctienganh/Authencation/login.dart';
import 'package:apphoctienganh/Authencation/register.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class Start_Screen extends StatefulWidget {
  const Start_Screen({super.key});

  @override
  State<Start_Screen> createState() => _Start_ScreenState();
}

class _Start_ScreenState extends State<Start_Screen> {
  final List<String> imgList = [
    'assets/xinchao.gif',
    'assets/gifdocsach.gif',
    'assets/gifintailieu.gif',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset('assets/logoapp.png', width: 50, height: 50),
            ),
            Text(
              'AppLearnEnglish',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(83, 209, 197, 1),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ứng dụng Học Tiếng Anh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // In đậm phần "Ứng dụng"
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8), // Khoảng cách giữa 2 dòng
                Text(
                  'Học mọi lúc, mọi nơi với các bài học từ vựng, ngữ pháp và kỹ năng giao tiếp, giúp bạn cải thiện tiếng Anh nhanh chóng.',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3), // thời gian giữa các ảnh
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: imgList.map((path) => buildImage(path)).toList(),
          ),
          SizedBox(height: 38),

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register_Screen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(83, 209, 197, 1),
                      disabledBackgroundColor: Color.fromRGBO(83, 209, 197, 1),
                      foregroundColor: Color.fromRGBO(83, 209, 197, 1),
                    ),
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
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

Widget buildImage(String path) => Container(
  margin: EdgeInsets.symmetric(horizontal: 5),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Gif(image: AssetImage(path), fps: 72, autostart: Autostart.loop),
  ),
);
