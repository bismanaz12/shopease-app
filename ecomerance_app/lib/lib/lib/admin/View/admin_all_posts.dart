import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/appText.dart';
import '../Model/create_post.dart';
import 'dart:io';
import 'admin_create_post.dart';

class AdminAllPosts extends StatefulWidget {
  const AdminAllPosts({super.key});

  @override
  State<AdminAllPosts> createState() => _AdminAllPostsState();
}

class _AdminAllPostsState extends State<AdminAllPosts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('createPosts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _updatePost(String productId, Post post) async {
    final GlobalKey<FormState> _updatePostKey = GlobalKey<FormState>();
    final TextEditingController _nameController =
        TextEditingController(text: post.postName);
    final TextEditingController _descriptionController =
        TextEditingController(text: post.postDescription);

    _selectedImage = null;

    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Product'),
              content: Form(
                key: _updatePostKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage(ImageSource.gallery);
                          setState(() {});
                        },
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade800, width: 2),
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_selectedImage!,
                                      fit: BoxFit.cover),
                                )
                              : post.postImage != null &&
                                      post.postImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(post.postImage!,
                                          fit: BoxFit.cover),
                                    )
                                  : Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Product Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the product name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                            InputDecoration(labelText: 'Product Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the product description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                CustomButton(
                  bgColor: Colors.teal,
                  fontSize: 12,
                  borderRadius: 3,
                  height: 25,
                  width: 70,
                  onTap: isUpdating
                      ? null
                      : () async {
                          if (_updatePostKey.currentState!.validate()) {
                            setState(() {
                              isUpdating = true;
                            });

                            String? imageUrl = post.postImage;

                            if (_selectedImage != null) {
                              try {
                                firebase_storage.Reference ref =
                                    firebase_storage
                                        .FirebaseStorage.instance
                                        .ref()
                                        .child('posts')
                                        .child(
                                            DateTime.now().toIso8601String());
                                firebase_storage.UploadTask uploadTask =
                                    ref.putFile(_selectedImage!);
                                await uploadTask.whenComplete(() => null);
                                imageUrl = await ref.getDownloadURL();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to upload image: $e')),
                                );
                              }
                            }

                            try {
                              await _firestore
                                  .collection('createPosts')
                                  .doc(productId)
                                  .update({
                                'postName': _nameController.text,
                                'postDescription': _descriptionController.text,
                                'postImage': imageUrl,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Post updated successfully')),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to update Post: $e')),
                              );
                            } finally {
                              setState(() {
                                isUpdating = false;
                              });
                            }
                          }
                        },
                  label: isUpdating ? 'Updating....' : 'Update',
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AppText(
          text: 'All Posts',
          textColor: Colors.white,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => AdminCreatePost());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('createPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nodata.webp',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No post found.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data!.docs.map((doc) {
            return Post(
              postName: doc['postName'],
              postDescription: doc['postDescription'],
              postImage: doc['postImage'],
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final post = posts[index];
              final postId = doc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                  color: Colors.grey.shade900,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    post.postImage != null && post.postImage!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        post.postImage!,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    )
                        : Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Icon(Icons.image, color: Colors.white, size: 80),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.postName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            AppText(
                              text: post.postDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textColor: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            _updatePost(postId, post);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deletePost(postId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );

            },
          );
        },
      ),
    );
  }
}
