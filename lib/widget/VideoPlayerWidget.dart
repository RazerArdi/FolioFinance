import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';

// VideoPlayerWidget using flutter_video_view
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _controller.initialize().then((_) {
      setState(() {}); // Rebuild widget when video is initialized
      _controller.play(); // Automatically start playing the video
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// MediaListWidget to handle displaying multiple media items
class MediaListWidget extends StatelessWidget {
  // Example: Replace with actual async data-fetching method
  Future<List<Map<String, String>>> fetchMediaData() async {
    await Future.delayed(Duration(seconds: 2));

    // Example of media data that includes both image and video URLs
    return [
      {'mediaUrl': 'https://www.example.com/video.mp4'},
      {'mediaUrl': 'https://www.example.com/image.jpg'},
      {'mediaUrl': 'https://www.example.com/another_image.png'},
      {'mediaUrl': 'https://www.example.com/another_video.mp4'}
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: fetchMediaData(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Handle empty or null data
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Retrieve the media list
        final mediaList = snapshot.data!;

        return ListView.builder(
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final mediaUrl = mediaList[index]['mediaUrl'];

            if (mediaUrl == null || mediaUrl.isEmpty) {
              return SizedBox.shrink(); // Skip empty or null URLs
            }

            bool isVideo = mediaUrl.endsWith('.mp4') || mediaUrl.endsWith('.mov');
            bool isImage = mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.jpeg') || mediaUrl.endsWith('.png');

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isVideo
                        ? VideoPlayerWidget(videoUrl: mediaUrl) // Handle video
                        : isImage
                        ? Image.network(mediaUrl, fit: BoxFit.cover) // Handle image
                        : Center(child: Text('Unsupported media type')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
