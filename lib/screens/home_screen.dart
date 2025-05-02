import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picsible/screens/enhanced_image_editor_screen.dart';
import 'package:picsible/services/permission_service.dart';
import 'package:picsible/widgets/image_placeholder.dart';
import 'package:picsible/widgets/image_source_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source, {bool withEditing = false}) async {
    try {
      final permissionGranted = await PermissionService.requestPermission(context, source);
      if (!permissionGranted) return;

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        if (withEditing) {
          final File? editedImage = await Navigator.push<File>(
            context,
            MaterialPageRoute(builder: (context) => EnhancedImageEditorScreen(image: imageFile)),
          );
          if (editedImage != null) {
            imageFile = editedImage;
          } else {
            return;
          }
        }

        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _image = imageFile;
          _isLoading = false;
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
                CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
      );
    }
  }

  void _clearImage() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _image = null;
      _isLoading = false;
    });
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
                      _isLoading
                          ? const CupertinoActivityIndicator()
                          : _image == null
                          ? const ImagePlaceholder()
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, width: double.infinity, height: 500),
                          ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: CupertinoButton.filled(
                      onPressed:
                          () => showCupertinoModalPopup(
                            context: context,
                            builder:
                                (context) => ImageSourceSheet(
                                  onCameraSelected: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera, withEditing: true);
                                  },
                                  onGallerySelected: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery, withEditing: true);
                                  },
                                ),
                          ),
                      onLongPress:
                          () => showCupertinoModalPopup(
                            context: context,
                            builder:
                                (context) => ImageSourceSheet(
                                  onCameraSelected: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera, withEditing: true);
                                  },
                                  onGallerySelected: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery, withEditing: true);
                                  },
                                ),
                          ),
                      child: const Text('Select Image'),
                    ),
                  ),
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
