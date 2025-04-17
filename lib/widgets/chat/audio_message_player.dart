import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({super.key, required this.audioUrl});

  final String audioUrl;

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (!isPlaying) {
              await audioPlayer.play(UrlSource(widget.audioUrl));
              setState(() {
                isPlaying = true;
              });
            } else {
              await audioPlayer.pause();
              setState(() {
                isPlaying = false;
              });
            }
          },
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        Expanded(
          child: Slider.adaptive(
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            onChanged: (value) {
              setState(() {
                audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
        ),
        Text('${position.inSeconds} / ${duration.inSeconds}')
      ],
    );
  }
}
