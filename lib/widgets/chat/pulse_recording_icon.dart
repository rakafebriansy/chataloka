import 'package:flutter/material.dart';

class PulseRecordingIcon extends StatefulWidget {
  @override
  _PulseRecordingIconState createState() => _PulseRecordingIconState();
}

class _PulseRecordingIconState extends State<PulseRecordingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); 

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(
              Icons.mic,
              color: Colors.orangeAccent,
            ),
          );
        },
      ),
    );
  }
}
