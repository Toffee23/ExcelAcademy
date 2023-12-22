import 'dart:io';

import 'package:course_view/model.dart';
import 'package:course_view/pages/course_view/page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({
    Key? key,
    this.isFirst = false,
    required this.videoModel,
  }) : super(key: key);
  final bool isFirst;
  final VideoModel videoModel;

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    initialize();

    super.initState();
  }

  Future<void> initialize() async {
    final offlinePath = await getOfflinePath();
    if (offlinePath != null) {
      _controller = VideoPlayerController.file(File(offlinePath))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    } else {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.url))
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              setState(() {});
            });
    }
  }

  Future<String?> getOfflinePath() async {
    // Get the app's documents directory
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    // Specify the file path to save the video
    final String videoPath =
        '${appDocumentsDirectory.path}/${widget.videoModel.id}.mp4';

    final isExist = await File(videoPath).exists();
    if (isExist) {
      return videoPath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      width: MediaQuery.sizeOf(context).width * .63,
      margin: EdgeInsets.only(left: widget.isFirst ? 0 : 10),
      child: MaterialButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CourseViewPage(videoModel: widget.videoModel)));
        },
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey.withOpacity(.3),
                child: Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.language_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'English subtitle',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Corporate Reporting',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 5.0,
                      ),
                    ),
                    minimumSize: const MaterialStatePropertyAll(Size.zero),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).primaryColor),
                  ),
                  child: const Text('Add to cart'),
                ),
                const Spacer(),
                Icon(
                  Icons.star,
                  color: Theme.of(context).primaryColor,
                ),
                const Text('4.1'),
                const SizedBox(width: 5.0)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class _VideoAppState extends State<VideoApp> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(Uri.parse(
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Demo',
//       home: Scaffold(
//         body: Center(
//           child: _controller.value.isInitialized
//               ? AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           )
//               : Container(),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             setState(() {
//               _controller.value.isPlaying
//                   ? _controller.pause()
//                   : _controller.play();
//             });
//           },
//           child: Icon(
//             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }
