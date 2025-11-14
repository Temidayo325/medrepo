import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leftIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final Color backgroundColor; // NEW: customizable background
  final Color colors;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leftIcon,
    this.trailingIcon,
    this.onTrailingPressed,
    this.backgroundColor = Colors.white, // default white
    this.colors = Colors.blueGrey,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (mounted) {
      setState(() => _imagePath = savedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor, // use the customizable color
      elevation: 0,
      toolbarHeight: 100,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Profile Avatar or Default Icon
            GestureDetector(
              onTap: () {
                // Switch to Profile tab (index 3)
                NavigationController.selectedIndex.value = 3;
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey.shade50,
                backgroundImage:
                    _imagePath != null ? FileImage(File(_imagePath!)) : null,
                child: _imagePath == null
                    ? Icon(
                        widget.leftIcon ?? Icons.person_4,
                        color: Colors.blueGrey.shade800,
                        size: 28,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 20),

            // Title
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 2,
                  color: widget.colors,
                  fontSize: 20,
                ),
              ),
            ),

            // Optional trailing icon
            if (widget.trailingIcon != null)
              InkWell(
                onTap: widget.onTrailingPressed,
                borderRadius: BorderRadius.circular(30),
                child: Icon(
                  widget.trailingIcon,
                  color: Colors.blueGrey.shade800,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
