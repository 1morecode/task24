import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/view/newPost/new_post.dart';
import 'package:message_app/view/settings/setting_page.dart';
import 'package:message_app/viewModel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class BlogApp extends StatelessWidget {
  const BlogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: CustomScrollView(
        shrinkWrap: false,
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          //2
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            snap: false,
            floating: true,
            centerTitle: true,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Blogs",
                style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold),
              ),
              // titlePadding: EdgeInsets.all(10),
              collapseMode: CollapseMode.parallax,
              centerTitle: true,
            ),
            actions: [
              CupertinoButton(
                  // padding: EdgeInsets.all(5),
                  // minSize: 30,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingPage(),
                        ));
                  },
                  child: Icon(
                    CupertinoIcons.settings_solid,
                    color: colorScheme.onSecondary,
                  ))
            ],
          ),
          //3
          Consumer<PostViewModel>(
            builder: (context, value, child) => SliverFillRemaining(
              child: StreamBuilder(
                stream: value.getPostList(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    List<DocumentSnapshot> userDoc = snapshot.data!.docs;
                    print(userDoc);
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        var data =
                            userDoc[index].data()! as Map<String, dynamic>;
                        return blogWidget(data, context);
                      },
                      itemCount: userDoc.length,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPost(),
              ));
        },
        backgroundColor: colorScheme.primary,
        child: Icon(
          CupertinoIcons.add,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget blogWidget(data, context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(data['image']), fit: BoxFit.cover),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(5),
            height: MediaQuery.of(context).size.width * 0.5,
            width: MediaQuery.of(context).size.width,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [Expanded(child: Text(data['title']))],
            ),
          )
        ],
      ),
    );
  }
}
