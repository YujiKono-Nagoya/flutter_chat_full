// import 'dart:typed_data';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'sample_page.dart';

// class ImagePage extends StatefulWidget {
//   const ImagePage({Key? key}) : super(key: key);

//   @override
//   State<ImagePage> createState() => _ImagePageState();
// }

// class _ImagePageState extends State<ImagePage> {
//   bool imageAvailable = false;
//   late Uint8List imageFile;

//   Future<void> _uploadImage() async {
//     final image = await ImagePickerWeb.getImageAsBytes();

//     if (image != null) {
//       final storage = FirebaseStorage.instance;
//       final Reference storageReference =
//           storage.ref().child('image/${DateTime.now()}.png');

//       final UploadTask uploadTask = storageReference.putData(image);

//       await uploadTask.whenComplete(() async {
//         String imageUrl = await storageReference.getDownloadURL();

//         setState(() {
//           imageFile = image;
//           imageAvailable = true;
//         });

//         print('画像がFirebase Storageにアップロードされました。');
//         print('ダウンロードURL: $imageUrl');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('画像アップロード'),
//       ),
//       body: Column(
//         children: [
//           if (imageAvailable)
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: MemoryImage(imageFile!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           Container(
//             margin: EdgeInsets.symmetric(vertical: 20),
//             child: TextButton(
//               onPressed: _uploadImage,
//               child: Text('画像を選択してアップロード'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
