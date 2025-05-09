import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> _conversationItems = [
    {
      'sender': 'user',
      'text': 'Tolong beri tahu, apa yang ada di depanku sekarang?',
    },
    {
      'sender': 'ai',
      'text':
          'Di depanmu ada sebuah rak berisi banyak makanan kemasan yang tersusun dengan sangat rapi. Apakah ada yang ingin kamu ketahui lagi?',
    },
    {
      'sender': 'user',
      'text': 'Apakah terdapat makanan ringan berbahan kentang di rak ini?',
    },
    {
      'sender': 'ai',
      'text':
          'Tidak ada makanan ringan berbahan kentang di rak ini. Mungkin kamu bisa mengarahkan kamera ke sebelah kanan. Aku akan coba memindainya.',
    },
    {
      'sender': 'user',
      'text': 'Berapa jumlah uang yang saat ini ada di depanku?',
    },
    {
      'sender': 'ai',
      'text':
          'Saat ini ada selembar uang lima puluh ribu dan dua lembar uang dua ribu. Sehingga ada lima puluh empat ribu rupiah di depanmu.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3A58D0);
    const Color primaryWhite = Colors.white;

    const Color bodyBackground = Colors.white;
    const Color textColorBlack = Colors.black;
    const Color bubbleColor = Color(0xFFB5C0ED);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: bodyBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'History',
          style: TextStyle(
            color: primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            height: 1.27,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
              ),
              child: Text(
                'Recent conversations are deleted every time you close NetrAI.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorBlack,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  height: 1.05,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _conversationItems.length,
                itemBuilder: (context, index) {
                  final item = _conversationItems[index];
                  return _buildConversationBubble(
                    text: item['text'],
                    isUser: item['sender'] == 'user',
                    bubbleColor: bubbleColor,
                    textColor: textColorBlack,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationBubble({
    required String text,
    required bool isUser,
    required Color bubbleColor,
    required Color textColor,
  }) {
    const TextStyle chatTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 9,
      color: Colors.black,
      height: 1.5,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[300] : bubbleColor,
          borderRadius: BorderRadius.circular(
            12.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Text(text, style: chatTextStyle),
      ),
    );
  }
}
