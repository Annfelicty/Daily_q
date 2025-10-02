import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDMq7zSTX61wr-9K9tpSs6tKE0hamU4dGk",
      authDomain: "couples-daily-q.firebaseapp.com",
      projectId: "couples-daily-q",
      storageBucket: "couples-daily-q.firebasestorage.app",
      messagingSenderId: "108314497781",
      appId: "1:108314497781:web:3d3a17bc384a0aaf532bbc",
    ),
  );
  runApp(const CouplesDailyQApp());
}

class CouplesDailyQApp extends StatelessWidget {
  const CouplesDailyQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couples Daily Q',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const SetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 🔹 First screen: enter name + room code
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  void _proceed() {
    final name = _nameController.text.trim();
    final room = _roomController.text.trim();
    if (name.isNotEmpty && room.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyQScreen(userName: name, roomCode: room),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: "Room Code (e.g. love123)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _proceed,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Daily Question + Q&A screen
class DailyQScreen extends StatefulWidget {
  final String userName;
  final String roomCode;

  const DailyQScreen({super.key, required this.userName, required this.roomCode});

  @override
  State<DailyQScreen> createState() => _DailyQScreenState();
}

class _DailyQScreenState extends State<DailyQScreen> {
  final List<String> questions = [
    "What’s your favorite memory of us?",
    "If we could travel anywhere together, where would we go?",
    "What’s one little thing I do that makes you smile?",
    "If today was a date day, what would you want us to do?",
    "What song reminds you of me?",
  ];

  late String _todayQuestion;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🔹 Random daily question (same for both partners if run on same day)
    _todayQuestion = questions[DateTime.now().day % questions.length];
  }

  void _submitAnswer() async {
    final answer = _controller.text.trim();
    if (answer.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("rooms")
          .doc(widget.roomCode)
          .collection("qna")
          .add({
        "question": _todayQuestion,
        "answer": answer,
        "user": widget.userName,
        "date": DateTime.now().toIso8601String(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final qnaStream = FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.roomCode)
        .collection("qna")
        .orderBy("date", descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("Couples Daily Q 💖 - Room ${widget.roomCode}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Question:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _todayQuestion,
              style: const TextStyle(fontSize: 18, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Your Answer",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Past Q&As:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: qnaStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("Loading...");
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data["question"] ?? ""),
                        subtitle: Text("${data["user"]}: ${data["answer"]}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
