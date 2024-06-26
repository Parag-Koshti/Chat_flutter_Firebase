import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  FullImageScreen({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadTaskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir.path,
          fileName: "downloaded_image.jpg",
          showNotification: true,
          openFileFromNotification: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download started...')),
        );
        print('Download directory: ${externalDir.path}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get storage directory')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(Icons.error),
            ),
          ),
          _appbar(context),
        ],
      ),
    );
  }

  Widget _appbar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => _downloadImage(context, imageUrl),
              icon: Icon(
                CupertinoIcons.cloud_download,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
