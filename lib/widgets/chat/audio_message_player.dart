import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.textColor,
    required this.backgroundColor,
  });

  final String audioUrl;
  final Color textColor;
  final Color backgroundColor;

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  late final AudioPlayer audioPlayer;
  late final MessageProvider messageProvider;

  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isStartPressed = false;
  bool isInitialized = false;

  Future<void> seekToPosition(double seconds) async {
    final newPosition = Duration(seconds: seconds.toInt());
    await audioPlayer.seek(newPosition);
    await audioPlayer.resume();
  }

  @override
  void initState() {
    super.initState();

    initAudio();
  }

  Future<void> initAudio() async {
    messageProvider = context.read<MessageProvider>();
    audioPlayer = AudioPlayer();
    await audioPlayer.setSourceUrl(widget.audioUrl);
    final newDuration = await audioPlayer.getDuration();

    if (newDuration != null) {
      setState(() {
        duration = newDuration;
      });
    }

    // listen to changes in player state
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (!mounted) return;
      if (event == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else if (event == PlayerState.paused) {
        setState(() {
          isPlaying = false;
        });
      } else if (event == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          position = duration;
        });
      }
    });

    // listen to changes in player position
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      setState(() {
        position = newPosition;
        if (position == duration || position > duration) {
          isStartPressed = false;
        }
      });
    });

    // listen to changes in player duration
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration;
      });
    });

    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    messageProvider.setActivePlayer(null);
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.orangeAccent,
          child: CircleAvatar(
            backgroundColor: widget.backgroundColor,
            radius: 20,
            child: IconButton(
              onPressed: () async {
                if (!isPlaying) {
                  if (messageProvider.activePlayer != audioPlayer) {
                    await messageProvider.setActivePlayer(audioPlayer);
                  }
                  await audioPlayer.play(UrlSource(widget.audioUrl));
                  setState(() {
                    isPlaying = true;
                    isStartPressed = true;
                  });
                } else {
                  await audioPlayer.pause();
                  setState(() {
                    isPlaying = false;
                  });
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Slider.adaptive(
            thumbColor: widget.textColor,
            inactiveColor: widget.textColor,
            activeColor: Colors.orangeAccent,
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            onChanged: seekToPosition,
          ),
        ),
        Text(
          isStartPressed ? formatDuration(position) : formatDuration(duration),
          style: GoogleFonts.openSans(color: widget.textColor),
        ),
      ],
    );
  }
}
