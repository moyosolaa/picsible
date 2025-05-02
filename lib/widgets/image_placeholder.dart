import 'package:flutter/cupertino.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(12)),
      width: double.infinity,
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 64, color: CupertinoColors.systemGrey),
          SizedBox(height: 12),
          Text('No Image Selected', style: TextStyle(color: CupertinoColors.systemGrey)),
        ],
      ),
    );
  }
}
