import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:course_view/model.dart';
import 'package:course_view/widgets/button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CourseViewPage extends StatefulWidget {
  const CourseViewPage({
    Key? key,
    required this.videoModel,
  }) : super(key: key);
  final VideoModel videoModel;

  @override
  State<CourseViewPage> createState() => _CourseViewPageState();
}

class _CourseViewPageState extends State<CourseViewPage> {
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  List<String> srcs = [
    "https://assets.mixkit.co/videos/preview/mixkit-spinning-around-the-earth-29351-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"
  ];

  Future<void> initializePlayer() async {
    print('you');
    final offlinePath = await getOfflinePath();
    if (offlinePath != null) {
      print('time');
      _videoPlayerController1 = VideoPlayerController.file(File(offlinePath));
      _videoPlayerController2 = VideoPlayerController.file(File(offlinePath));
      await Future.wait([
        _videoPlayerController1.initialize(),
        _videoPlayerController2.initialize()
      ]);
      _createChewieController();
    } else {
      print('the');
      _videoPlayerController1 =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.url));
      _videoPlayerController2 =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.url));
      await Future.wait([
        _videoPlayerController1.initialize(),
        _videoPlayerController2.initialize()
      ]);
      _createChewieController();
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
    );
  }

  Widget _subtitleWidget() => Row(
        children: [
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
      );

  Widget _ratingWidget(BuildContext context) => Row(
        children: <Widget>[
          Icon(
            Icons.star,
            color: Theme.of(context).primaryColor,
          ),
          const Text('4.1'),
        ],
      );

  Widget _watchedWidget(BuildContext context) => Row(
        children: <Widget>[
          Icon(
            Icons.people_alt,
            color: Theme.of(context).primaryColor,
          ),
          const Text('2,363'),
        ],
      );

  Widget _infoWidget() => const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            CupertinoIcons.info,
            color: Colors.grey,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'This package selected on choice of offer for the course, we strongly advice to go for a better choice.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );

  bool get _canPlayVideo =>
      _chewieController != null &&
      _chewieController!.videoPlayerController.value.isInitialized;

  Future<void> downloadVideo() async {
    print('anything');
    final result = await getOfflinePath();
    print(result);

    final Dio dio = Dio();

    try {
      showProgressDialog();
      final Response<List<int>> response = await dio.get<List<int>>(
        widget.videoModel.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      // Get the app's documents directory
      final Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();

      // Specify the file path to save the video
      // final String savePath =
      //     '${appDocumentsDirectory.path}/${widget.videoModel.id}.mp4';
      final String savePath = 'storage/emulated/0/document/video.mp4';
      // Write the downloaded bytes to the file
      await File(savePath).writeAsBytes(response.data!);
      closeProgressDialog();
      print('Video downloaded successfully to: $savePath');
    } catch (error) {
      print('Error downloading video: $error');
    }
  }

  void showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Offline Download'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text('Downloading for offline in progress'),
            ],
          ),
        );
      },
    );
  }

  void closeProgressDialog() {
    Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course View'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _canPlayVideo
                  ? Chewie(controller: _chewieController!)
                  : Container(
                      color: Colors.grey.withOpacity(.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Basic Accounting Process and Systems',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                _subtitleWidget(),
                const Spacer(),
                ActionButton(
                  onPressed: () {},
                  iconData: CupertinoIcons.link,
                  text: 'Share',
                )
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: <Widget>[
                _ratingWidget(context),
                const SizedBox(width: 8.0),
                _watchedWidget(context),
                const Spacer(),
                ActionButton(
                  onPressed: downloadVideo,
                  iconData: Icons.download,
                  text: 'Download',
                )
              ],
            ),
            const SizedBox(height: 10.0),
            _infoWidget(),
            const SizedBox(height: 30.0),
            Text(
              'Course Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Kickstart and accelerate your career as an Advanced Audit '
              'and Assurance personnel from this revision course tailored '
              'to bring the best in you. The detailed study notes, standards '
              'questions and answers, past questions trend also serve as '
              'important course material necessary to broaden your '
              'understanding of the course.',
              style: TextStyle(
                color: Colors.grey.shade700,
                wordSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
