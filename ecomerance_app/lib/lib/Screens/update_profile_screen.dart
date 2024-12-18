import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:ecomerance_app/Screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Auth/firestore.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  var profileFormKey = GlobalKey<FormState>();
  bool isEnabled = false;
  bool isSaving = false;
  String imageUrl = "";
  bool isLoading = false;
  File? _selectedImage;
  final FirestoreService _firestoreService = FirestoreService();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Map<String, dynamic>? userData; // Variable to store fetched user data

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen initializes
  }

  Future<void> fetchUserData() async {
    try {
      userData = await _firestoreService.getUserData();
      if (userData != null) {
        _firstNameController.text = userData?['userName'] ?? '';
        _emailController.text = userData?['email'] ?? '';
        _passwordController.text = userData?['password'] ?? '';
      }
      setState(() {}); // Update the UI after fetching data
    } catch (e) {
      // Handle error fetching user data
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
        isEnabled = true;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
        isEnabled = true;
      });
    }
  }

  _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
                padding: EdgeInsets.all(9),
                height: 140,
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    ListTile(
                      onTap: () {
                        _pickImageFromCamera();
                        Navigator.of(context).pop();
                      },
                      leading: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                      ),
                      title: const Text("Camera",style: TextStyle(color: Colors.white),),
                    ),
                    ListTile(
                      onTap: () {
                        _pickImageFromGallery();
                        Navigator.of(context).pop();
                      },
                      leading: const Icon(
                        Icons.image,
                        color: AppColors.primary,
                      ),
                      title: const Text("Gallery",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ));
        });
  }

  Future<void> _saveInfo() async {
    if (!profileFormKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child("ecommerceApp")
            .child("/images")
            .child(DateTime.now().toIso8601String());

        firebase_storage.UploadTask uploadTask = ref.putFile(_selectedImage!);
        await uploadTask.whenComplete(() => null);
        imageUrl = await ref.getDownloadURL();
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser!.uid;

      await db.collection("users").doc(uid).update({
        "imageUrl": imageUrl ?? userData?['imageUrl'],
        'userName': _firstNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );


      setState(() {
        isSaving = false;
        isEnabled = false;
      });
    } catch (e) {
      log('Error while updating: $e');
      Fluttertoast.showToast(
        msg: 'Failed to save data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        textColor: Colors.white,
        backgroundColor: Colors.red,
        fontSize: 16,
        timeInSecForIosWeb: 2,
      );
      setState(() {
        isSaving = false;
      });
    }
  }

  void _checkForChanges() {
    if (_firstNameController.text.trim() != userData?['userName'] ||
        _emailController.text.trim() != userData?['email'] ||
        _passwordController.text.trim() != userData?['password'] ||
        _selectedImage != null) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _firstNameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _passwordController.addListener(_checkForChanges);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const AppText(
          text: 'Update Profile Screen',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          textColor: Colors.white,
        ),
        backgroundColor: AppColors.primary,

      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: profileFormKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                userData != null
                    ? Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            border: Border.all(
                                width: 2,  color: AppColors.primary,),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: (_selectedImage != null)
                                  ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                                  : (userData?["imageUrl"] != '')
                                  ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, progress) =>
                                      Center(
                                        child:
                                        CircularProgressIndicator(
                                          value: progress
                                              .progress,
                                        ),
                                      ),
                                  imageUrl: userData?["imageUrl"])
                                  : Icon(Icons.camera_alt,size: 50,  color: AppColors.primary,)
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 100,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              onPressed: () {
                                _showPicker();
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    AppText(
                      textAlign: TextAlign.center,
                      text: '${userData?['userName'] ?? ''}'.toUpperCase(),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _firstNameController,
                      prefixIcon: Icons.person,
                      hintText: 'First Name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a valid name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _emailController,
                      prefixIcon: Icons.email,
                      hintText: 'Email',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _passwordController,
                      prefixIcon: Icons.lock,
                      hintText: 'Password',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty ) {
                          return 'Please enter a valid password number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      onTap: isEnabled ? _saveInfo : null,
                      label: isSaving ? 'Saving...' : 'Save',
                      bgColor: isEnabled ? AppColors.primary : Colors.grey,
                      labelColor: Colors.white,
                    ),
                  ],
                )
                    : SizedBox(
                    height: 40,
                    width: 30,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
