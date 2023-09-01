import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/models/user_model.dart';
import 'package:lpu_app/models/article_model.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/add_article.dart';
import 'package:lpu_app/views/help.dart';

final getUser = FirebaseAuth.instance.currentUser!;
final userID = getUser.uid;
DatabaseReference? userRef;
dynamic userModel;

List<ArticleModel> listTiles = [];
List<List> usersNotif = [];

Future<void> getUserDetails() async {
  DataSnapshot snapshot = await userRef!.get();

  userModel = UserModel.fromMap(Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
}

Future getArticles() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    listTiles.clear();

    FirebaseDatabase.instance.ref().child('NewsAndEvents').get().then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          final tasks = ArticleModel.fromMap(Map<String, dynamic>.from(value));
          listTiles.add(tasks);
        });
      }
    });
  }
}

Widget listWidget(ArticleModel item) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 2.0,
    margin: const EdgeInsets.only(bottom: 24.0),
    color: AppConfig.appSecondaryTheme,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            AppConfig.appSecondaryTheme,
            Color(0xffD94141),
            AppConfig.appSecondaryTheme,
          ])),
      child: Row(
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(item.articleImage),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8.0), topLeft: Radius.circular(8.0)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  item.articleTitle,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  item.articleDescription,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Arial',
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFFFFFFFF),
                    ),
                    Text(
                      item.articleAuthor,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    const Icon(
                      Icons.event,
                      color: Color(0xFFFFFFFF),
                    ),
                    Text(
                      item.articlePublished,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    ),
  );
}

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  NewsState createState() => NewsState();
}

class NewsState extends State<News> {
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('Accounts').child(user.uid);
    }

    getUserDetails();
    getArticles();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
      floatingActionButton: userModel?.userType == 'Student' && userModel?.userType == 'Faculty'
          ? Visibility(
              visible: false,
              child: FloatingActionButton(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddArticle()));
                },
                backgroundColor: const Color(0xFFFFFFFF),
                child: const Icon(
                  Icons.add,
                  color: AppConfig.appSecondaryTheme,
                ),
              ),
            )
          : userModel?.userType == 'Admin'
              ? FloatingActionButton(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddArticle()));
                  },
                  backgroundColor: const Color(0xFFFFFFFF),
                  child: const Icon(
                    Icons.add,
                    color: AppConfig.appSecondaryTheme,
                  ),
                )
              : Visibility(
                  visible: false,
                  child: FloatingActionButton(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddArticle()));
                    },
                    backgroundColor: const Color(0xFFFFFFFF),
                    child: const Icon(
                      Icons.add,
                      color: AppConfig.appSecondaryTheme,
                    ),
                  ),
                ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    child: Image.asset(
                      'assets/images/news_event_header.png',
                      width: double.infinity,
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16)),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listTiles.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {},
                        child: listWidget(listTiles[index]),
                      );
                    }),
              ])),
        ),
      ));
}
