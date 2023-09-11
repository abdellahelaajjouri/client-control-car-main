import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageShowScreen extends StatefulWidget {
  final String url;
  const ImageShowScreen({super.key, required this.url});

  @override
  State<ImageShowScreen> createState() => _ImageShowScreenState();
}

class _ImageShowScreenState extends State<ImageShowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            //
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),

              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.url),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.url),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                );
              },
              itemCount: 1,
              loadingBuilder: (context, event) => Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),

              // pageController: widget.pageController,
              onPageChanged: (index) {},
            ),

            //
            Positioned(
              left: 15,
              top: 25,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
