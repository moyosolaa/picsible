import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';

class EnhancedImageEditorScreen extends StatefulWidget {
  final File image;

  const EnhancedImageEditorScreen({super.key, required this.image});

  @override
  _EnhancedImageEditorScreenState createState() => _EnhancedImageEditorScreenState();
}

class _EnhancedImageEditorScreenState extends State<EnhancedImageEditorScreen> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  double saturation = 1.0;
  double brightness = 0.0;
  double contrast = 1.0;

  @override
  void initState() {
    super.initState();
    resetEditorState();
  }

  void resetEditorState() {
    setState(() {
      saturation = 1.0;
      brightness = 0.0;
      contrast = 1.0;
      if (editorKey.currentState != null) {
        editorKey.currentState!.reset();
      }
    });
  }

  final defaultColorMatrix = const <double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

  List<double> calculateSaturationMatrix(double saturation) {
    final m = List<double>.from(defaultColorMatrix);
    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return m;
  }

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Image'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Done'), onPressed: () => saveImage()),
      ),
      child: SafeArea(child: Column(children: [Expanded(child: buildImageEditor()), buildControlPanel()])),
    );
  }

  Widget buildImageEditor() {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(calculateContrastMatrix(contrast)),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(calculateSaturationMatrix(saturation)),
        child: ExtendedImage(
          color: brightness > 0 ? Colors.white.withOpacity(brightness) : Colors.black.withOpacity(-brightness),
          colorBlendMode: brightness > 0 ? BlendMode.lighten : BlendMode.darken,
          image: ExtendedFileImageProvider(widget.image, cacheRawData: true),
          extendedImageEditorKey: editorKey,
          mode: ExtendedImageMode.editor,
          fit: BoxFit.contain,
          initEditorConfigHandler:
              (state) => EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
                cropAspectRatio: CropAspectRatios.original,
              ),
        ),
      ),
    );
  }

  Widget buildControlPanel() {
    return Container(
      color: CupertinoColors.systemGroupedBackground,
      child: Column(mainAxisSize: MainAxisSize.min, children: [buildAdjustmentControls(), buildEditingTools()]),
    );
  }

  Widget buildAdjustmentControls() {
    return Column(
      children: [
        buildSlider(
          'Brightness',
          CupertinoIcons.sun_max,
          brightness,
          -1.0,
          1.0,
          (value) => setState(() => brightness = value),
        ),
        // _buildSlider(
        //   'Contrast',
        //   CupertinoIcons.circle_lefthalf_fill,
        //   contrast,
        //   0.0,
        //   4.0,
        //   (value) => setState(() => contrast = value),
        // ),
        buildSlider(
          'Saturation',
          CupertinoIcons.wand_rays,
          saturation,
          0.0,
          2.0,
          (value) => setState(() => saturation = value),
        ),
      ],
    );
  }

  Widget buildSlider(
    String label,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemGrey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: CupertinoColors.systemGrey)),
          Expanded(child: CupertinoSlider(value: value, min: min, max: max, onChanged: onChanged)),
          SizedBox(
            width: 40,
            child: Text(value.toStringAsFixed(1), style: const TextStyle(color: CupertinoColors.systemGrey)),
          ),
        ],
      ),
    );
  }

  Widget buildEditingTools() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildToolButton(CupertinoIcons.rotate_left, 'Rotate Left', () => editorKey.currentState?.rotate(degree: -90)),
          buildToolButton(CupertinoIcons.rotate_right, 'Rotate Right', () => editorKey.currentState?.rotate()),
          buildToolButton(Icons.flip_rounded, 'Flip', () => editorKey.currentState?.flip()),
        ],
      ),
    );
  }

  Widget buildToolButton(IconData icon, String label, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CupertinoColors.activeBlue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: CupertinoColors.activeBlue, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> saveImage() async {
    try {
      final state = editorKey.currentState!;
      final Rect? cropRect = state.getCropRect();
      final EditActionDetails action = state.editAction!;
      final double rotateAngle = action.rotateDegrees;

      final ImageEditorOption option = ImageEditorOption();

      if (cropRect != null) {
        option.addOption(ClipOption.fromRect(cropRect));
      }

      option.addOption(FlipOption(horizontal: action.flipY));

      if (rotateAngle != 0) {
        option.addOption(RotateOption(rotateAngle.toInt()));
      }

      option.addOption(ColorOption.saturation(saturation));
      option.addOption(ColorOption.brightness(brightness + 1));
      option.addOption(ColorOption.contrast(contrast));
      option.outputFormat = const OutputFormat.jpeg(100);

      final Uint8List? result = await ImageEditor.editImage(image: state.rawImageData, imageEditorOption: option);

      if (result != null) {
        widget.image.writeAsBytesSync(result);
        if (mounted) {
          Navigator.of(context).pop(widget.image);
        }
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text('Failed to save image: $e'),
                actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
              ),
        );
      }
    }
  }
}
