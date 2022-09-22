
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/viewModel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CupertinoButton(
          minSize: 15,
          padding: EdgeInsets.all(0),
          child: CircleAvatar(
            backgroundColor: colorScheme.onSurface,
            child: Icon(
              CupertinoIcons.chevron_back,
              size: 24,
              color: colorScheme.onSecondary,
            ),
            radius: 15,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<PostViewModel>(
          builder: (context, value, child) => ListView(
            padding: EdgeInsets.all(10),
            children: [
              GestureDetector(
                onTap: (){
                  value.getImage(ImageSource.camera);
                },
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: MemoryImage(value.image),
                        fit: BoxFit.cover
                      ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  height: MediaQuery.of(context).size.width*0.5,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SizedBox(height: 15,),
              SizedBox(
                height: 50,
                child: CupertinoTextField(
                  controller: value.textEditingController,
                  placeholder: "Title",
                  textInputAction: TextInputAction.done,
                ),
              ),
              SizedBox(height: 15,),
              CupertinoButton(child: value.isLoading ? CupertinoActivityIndicator() : Text("Save Post"), onPressed: value.isLoading ? null : () async {
                value.postBlog();
              }, color: Colors.blue,)
            ],
          ),
        ),
      ),
    );
  }
}
