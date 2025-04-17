import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullscreenImageMessageViewer extends StatefulWidget {
  final String imageUrl;
  final String message;

  const FullscreenImageMessageViewer({
    Key? key,
    required this.imageUrl,
    required this.message,
  }) : super(key: key);

  @override
  State<FullscreenImageMessageViewer> createState() => _FullscreenImageMessageViewerState();
}

class _FullscreenImageMessageViewerState extends State<FullscreenImageMessageViewer> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final CustomTheme customTheme = Theme.of(context).extension<CustomTheme>()!;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: widget.imageUrl,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    open = !open;
                  });
                },
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) =>
                          Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          Image.asset(AssetsManager.imageError),
                ),
              ),
            ),
          ),
          if (open)
            AnimatedSwitcher(
              duration: Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 80),
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: customTheme.text.dark),
                  child: Center(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.openSans(
                        color: customTheme.text.light,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
