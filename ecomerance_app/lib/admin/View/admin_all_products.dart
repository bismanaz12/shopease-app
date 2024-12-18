import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/appText.dart';
import '../Model/add_product.dart';
import 'admin_add_products.dart'; // Make sure this import points to the correct file

class AdminAllProducts extends StatefulWidget {
  const AdminAllProducts({super.key});

  @override
  State<AdminAllProducts> createState() => _AdminAllProductsState();
}

class _AdminAllProductsState extends State<AdminAllProducts> {
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

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('addproducts').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  Future<void> _updateProduct(String productId, Product product) async {
    final GlobalKey<FormState> _updateProductKey = GlobalKey<FormState>();
    final TextEditingController _nameController =
        TextEditingController(text: product.productName);
    final TextEditingController _descriptionController =
        TextEditingController(text: product.productDescription);
    final TextEditingController _priceController = TextEditingController(text: product.productPrice);
    final TextEditingController _originalPriceController =
    TextEditingController(text: product.originalPrice);

    _selectedImage = null; // Reset selected image before opening dialog

    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Product'),
              content: Form(
                key: _updateProductKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage(ImageSource.gallery);
                          setState(() {}); // Update the dialog state
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
                              : product.productImage != null &&
                                      product.productImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                          product.productImage!,
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
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Product Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the product price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _originalPriceController,
                        decoration: InputDecoration(labelText: 'Original Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Original price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid price';
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
                  labelColor: Colors.white,
                  bgColor: Colors.teal,
                  fontSize: 12,
                  borderRadius: 5,
                  height: 25,
                  width: 70,
                  onTap: isUpdating
                      ? null
                      : () async {
                          if (_updateProductKey.currentState!.validate()) {
                            setState(() {
                              isUpdating = true;
                            });

                            String? imageUrl = product.productImage;

                            // If a new image is selected, upload it to Firebase Storage
                            if (_selectedImage != null) {
                              try {
                                firebase_storage.Reference ref =
                                    firebase_storage
                                        .FirebaseStorage.instance
                                        .ref()
                                        .child('products')
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
                                  .collection('addproducts')
                                  .doc(productId)
                                  .update({
                                'productName': _nameController.text,
                                'productDescription': _descriptionController.text,
                                'productPrice':_priceController.text,
                                'originalPrice':_originalPriceController.text,
                                'productImage': imageUrl,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Product updated successfully')),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to update product: $e')),
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: AppText(
          text: 'Admin All Products',
          textColor: Colors.white,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => AdminAddProducts());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('addproducts').snapshots(),
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
                    'No products found.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!.docs.map((doc) {
            return Product(
              productName: doc['productName'],
              productDescription: doc['productDescription'],
              productPrice: doc['productPrice'],
              productImage: doc['productImage'],
              originalPrice: doc['originalPrice'],
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final product = products[index];
              final productId = doc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                  color: Colors.grey.shade900,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    product.productImage != null &&
                        product.productImage!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.productImage!,
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
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10)),
                      ),
                      child: Icon(Icons.image,
                          color: Colors.white, size: 80),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              product.productDescription,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '\$${product.productPrice}',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '\$${product.originalPrice}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 3,
                                    decorationColor: Colors.red,
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            _updateProduct(productId, product);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteProduct(productId);
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
