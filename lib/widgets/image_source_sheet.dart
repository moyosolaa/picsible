import 'package:flutter/cupertino.dart';

class ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const ImageSourceSheet({super.key, required this.onCameraSelected, required this.onGallerySelected});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Select Image Source'),
      actions: <Widget>[
        CupertinoActionSheetAction(onPressed: onCameraSelected, child: const Text('Camera')),
        CupertinoActionSheetAction(onPressed: onGallerySelected, child: const Text('Gallery')),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }
}
