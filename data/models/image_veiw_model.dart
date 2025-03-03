import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? userImageUrl;
  User? user;

  void showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.prColor,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.blColor),
            title: Text(tr('show_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              if (userImageUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: Center(
                        child: Image.network(userImageUrl!),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: AppColors.blColor),
            title: Text(tr('choose_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.blColor),
            title: Text(tr('delete_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              _deleteImage();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = '${user!.uid}_profile.jpg';
      try {
        await _storage.ref('user_images/$fileName').putFile(imageFile);
        String imageUrl =
            await _storage.ref('user_images/$fileName').getDownloadURL();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'image_url': imageUrl});
        userImageUrl = imageUrl;
        notifyListeners();
        userImageUrl = imageUrl;
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _deleteImage() async {
    if (userImageUrl != null) {
      String fileName = '${user!.uid}_profile.jpg';
      try {
        await _storage.ref('user_images/$fileName').delete();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'image_url': FieldValue.delete()});
        userImageUrl = null;
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }
}
