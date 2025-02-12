import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(HeartbeatApp());
}

class HeartbeatApp extends StatelessWidget {
  const HeartbeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heartbeat Animation',
      theme: ThemeData(primarySwatch: Colors.red),
      home: HeartbeatScreen(),
    );
  }
}

class HeartbeatScreen extends StatefulWidget {
  const HeartbeatScreen({super.key});

  @override
  _HeartbeatScreenState createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ Initialize AudioPlayer
  int _seconds = 10; // Set countdown time
  Timer? _timer;
  String currentMessage = "Tap the heart for a surprise!";
  List<String> loveMessages = [
    "You are my heartbeat! ❤",
    "Happy Valentine's Day! 💖",
    "Forever and always! 💕",
    "You make my heart skip a beat! 💓",
  ];
  List<Widget> floatingHearts = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void showLoveMessage() {
    // ✅ Play the heartbeat sound
    _audioPlayer.play(AssetSource('sounds/heartbeat.mp3'));

    setState(() {
      currentMessage = (loveMessages..shuffle()).first;
    });

    addFloatingHeart();
  }

  void addFloatingHeart() {
    setState(() {
      floatingHearts.add(
        Positioned(
          left: Random().nextDouble() * MediaQuery.of(context).size.width,
          top: MediaQuery.of(context).size.height,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(seconds: 3),
            child: Icon(
              Icons.favorite,
              color: Colors.pinkAccent,
              size: Random().nextDouble() * 30 + 20,
            ),
          ),
        ),
      );
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        floatingHearts.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _audioPlayer.dispose(); // ✅ Dispose audio player when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text('Animated Heartbeat')),
      body: Stack(
        children: [
          ...floatingHearts,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: showLoveMessage, // ✅ Now plays sound and updates UI
                child: ScaleTransition(
                  scale: _animation,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 120.0,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Countdown: $_seconds s',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                child: Text(
                  currentMessage,
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}