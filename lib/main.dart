import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
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
  }

  Future<void> showLoveMessage() async {
    await _audioPlayer.setVolume(70.0);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/heartbeat.mp3'));

    setState(() {
      currentMessage = (loveMessages..shuffle()).first;
    });

    addFloatingHeart();
  }

  void addFloatingHeart() {
    final double leftPosition = Random().nextDouble() * MediaQuery.of(context).size.width;

    setState(() {
      floatingHearts.add(
        Positioned(
          left: leftPosition,
          bottom: 0,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            duration: Duration(seconds: 3),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -value * MediaQuery.of(context).size.height),
                  child: child,
                ),
              );
            },
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
        if (floatingHearts.isNotEmpty) floatingHearts.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: showLoveMessage,
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
          ),
        ],
      ),
    );
  }
}
