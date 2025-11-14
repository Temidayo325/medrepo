import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String _prefKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (pickedFile != null) {
      final savedImage = await _saveImagePermanently(File(pickedFile.path));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, savedImage.path);

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<File> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = image.path.split('/').last;
    final newImage = await image.copy('${directory.path}/$name');
    return newImage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 70,
          backgroundColor: Colors.blueGrey.shade50,
          backgroundImage:
              _imageFile != null ? FileImage(_imageFile!) : null,
          child: _imageFile == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blueGrey.shade200,
                )
              : null,
        ),
      ),
    );
  }
}
