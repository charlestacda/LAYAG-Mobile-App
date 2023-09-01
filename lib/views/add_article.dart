import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/models/article_model.dart';
import 'package:lpu_app/views/news.dart';

dynamic publishedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

class AddArticle extends StatefulWidget {
  const AddArticle({Key? key}) : super(key: key);

  @override
  AddArticleState createState() => AddArticleState();
}

class AddArticleState extends State<AddArticle> {
  String? department;

  DatabaseReference articleReference = FirebaseDatabase.instance.ref().child('NewsAndEvents');
  TextEditingController articleTitle = TextEditingController();
  TextEditingController articleBody = TextEditingController();
  TextEditingController articleDepartment = TextEditingController();

  File? articleImagePath;
  File? articleImageFilename;

  List<ArticleModel> listTiles = [];

  pickImage(ImageSource gallery) async {
    try {
      final articleImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (articleImage == null) {
        return;
      }

      setState(() {
        articleImagePath = File(articleImage.path);
        articleImageFilename = File(articleImage.name);
      });
    } on PlatformException catch (exception) {
      Fluttertoast.showToast(
        msg: 'Something went wrong... ${exception.details}',
        fontSize: 16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
          color: AppConfig.appSecondaryTheme,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => pickImage(ImageSource.gallery),
                      child: articleImagePath != null
                          ? Image.file(
                              articleImagePath!,
                              height: 360,
                            )
                          : Column(
                              children: const [
                                Icon(
                                  Icons.upload_outlined,
                                  color: Color(0xFF606060),
                                  size: 48,
                                ),
                                Text('Upload Article Image',
                                    style: TextStyle(
                                      color: Color(0xFF606060),
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(0, 48, 0, 48),
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFD0D0D0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Article Title'),
                    onChanged: (value) => articleTitle.text = value,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          hint: const Text('Department/Organization'),
                          value: department,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 30,
                          items: ListConfig.colleges.map((String item) {
                            return DropdownMenuItem(value: item, child: Text(item));
                          }).toList(),
                          onChanged: (String? newDepartment) {
                            setState(() {
                              department = newDepartment!;
                              articleDepartment.text = department!;
                            });
                          }),
                    ),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Article Body'),
                    onChanged: (value) => articleBody.text = value,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (articleTitle.text.isEmpty && articleBody.text.isEmpty && articleDepartment.text.isEmpty) {
                        Fluttertoast.showToast(msg: 'Fill all the fields please.');
                      } else {
                        UploadTask uploadTask = FirebaseStorage.instance.ref().child(articleImageFilename.toString()).putFile(articleImagePath!);
                        TaskSnapshot snapshot = await uploadTask;
                        String articleImageUrl = await snapshot.ref.getDownloadURL();

                        await articleReference.child(articleTitle.text).set({
                          'ArticleAuthor': userModel!.userFirstName + ' ' + userModel!.userLastName,
                          'ArticleTitle': articleTitle.text,
                          'ArticleDepartment': articleDepartment.text,
                          'ArticleDescription': articleBody.text,
                          'ArticleImage': articleImageUrl,
                          'ArticlePublished': publishedDate.toString(),
                        });

                        Navigator.pop(context, MaterialPageRoute(builder: (context) => const News()));

                        setState(() {
                          listTiles.add(ArticleModel(
                            articleAuthor: userModel!.userFirstName + ' ' + userModel!.userLastName,
                            articleTitle: articleTitle.text,
                            articleDepartment: articleDepartment.text,
                            articleDescription: articleBody.text,
                            articleImage: articleImageUrl,
                            articlePublished: publishedDate.toString(),
                          ));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: AppConfig.appSecondaryTheme,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'PUBLISH',
                        style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
