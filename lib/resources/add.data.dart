import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final String currentUserId = _auth.currentUser!.uid;
final String? currentUserEmail = _auth.currentUser!.email;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String name,
    required Uint8List file,
  }) async {
    String resp = 'Some Error Occurred';
    try {
      if (name.isNotEmpty) {
        String imageUrl =
            await uploadImageToStorage('profileImage + $currentUserId', file);
        await _firestore.collection('users').doc(currentUserId).update({
          'email': currentUserEmail,
          'name': name,
          'image': imageUrl,
          'uid': currentUserId
        });
        resp = 'success';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
