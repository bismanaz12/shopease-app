import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/CustomTextformField.dart';
import '../../CustomWidgets/appText.dart';
import '../Model/create_post.dart';


class AdminCreatePost extends StatefulWidget {
  const AdminCreatePost({super.key});

  @override
  State<AdminCreatePost> createState() => _AdminCreatePostState();
}

class _AdminCreatePostState extends State<AdminCreatePost> {
  final GlobalKey<FormState> _adminAddPostFormKey = GlobalKey<FormState>();
  final TextEditingController _postNameController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isImageSelected = true;
  bool isSaving = false;


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isImageSelected = true;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.all(9),
          height: 140,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text("Camera", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.white),
                title: Text("Gallery", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    setState(() {
      isSaving = true;
    });
    if (_adminAddPostFormKey.currentState!.validate() && _isImageSelected) {
      try {
        String imageUrl = '';
        if (_selectedImage != null) {
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('posts')
              .child(DateTime.now().toIso8601String());
          firebase_storage.UploadTask uploadTask = ref.putFile(_selectedImage!);
          await uploadTask.whenComplete(() => null);
          imageUrl = await ref.getDownloadURL();
        }

        // Create product object
        Post newPost = Post(
          postName: _postNameController.text,
          postDescription: _postDescriptionController.text,
          postImage: imageUrl,
        );

        await FirebaseFirestore.instance.collection('createPosts').add({
          'postName': newPost.postName,
          'postDescription': newPost.postDescription,
          'postImage': newPost.postImage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully')),
        );
        Get.back();

        _adminAddPostFormKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
          _isImageSelected = false;
          _postNameController.clear();
          _postDescriptionController.clear();
        });
        setState(() {
          isSaving = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload product: $e')),
        );
        setState(() {
          isSaving = false;
        });
      }
    } else {
      if (!_isImageSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('please select an Image')),
        );
        setState(() {
          isSaving = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: AppText(
          text: 'Create Post Screen',
          textColor: Colors.white,
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _adminAddPostFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: 'Post Image', fontSize: 16, textColor: Colors.white),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800, width: 2),
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                          : Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppText(text: 'Post Name', fontSize: 16, textColor: Colors.white),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _postNameController,
                    obscureText: false,
                    hintText: 'Post Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the post name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  AppText(text: 'Post Description', fontSize: 16, textColor: Colors.white),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _postDescriptionController,
                    obscureText: false,
                    hintText: 'Post Description',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the post description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    onTap: _createPost,
                    label: isSaving? 'Creating...':'create Post ',
                    bgColor: Colors.teal,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _postNameController.dispose();
    _postDescriptionController.dispose();
    super.dispose();
  }
}
