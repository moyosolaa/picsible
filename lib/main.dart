import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Picsible',
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue, brightness: Brightness.light),
      home: const MyHomePage(title: 'Picsible Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Failed to pick image: ${e.toString()}'),
              actions: <Widget>[
                CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  void _showImageSourceActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Select Image Source'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Text('Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Text('Gallery'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(widget.title)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child:
                      _image == null
                          ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            width: double.infinity,
                            height: 500,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  CupertinoIcons.photo_fill_on_rectangle_fill,
                                  size: 64,
                                  color: CupertinoColors.systemGrey,
                                ),
                                SizedBox(height: 12),
                                Text('No Image Selected', style: TextStyle(color: CupertinoColors.systemGrey)),
                              ],
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, width: double.infinity, height: 500, fit: BoxFit.cover),
                          ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton.filled(onPressed: _showImageSourceActionSheet, child: const Text('Select Image')),
                  if (_image != null) CupertinoButton(onPressed: _clearImage, child: const Text('Clear')),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
