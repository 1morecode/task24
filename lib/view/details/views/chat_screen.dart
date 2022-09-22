import 'dart:async';
import 'dart:io';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:message_app/viewModel/auth_util.dart';
import 'package:message_app/viewModel/database.dart';
import 'package:message_app/res/global_data.dart';
import 'package:message_app/res/user_token.dart';
import 'package:message_app/view/details/views/image_editor_page.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerAvatar;

  ChatScreen(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerName})
      : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  late String groupChatId;

  late File imageFile;
  late bool isLoading;
  late bool isShowSticker;
  late String imageUrl;
  late String id;
  bool imageSending = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  CustomPopupMenuController _controller = CustomPopupMenuController();
  late List<ItemModel> menuItems;

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    menuItems = [
      ItemModel('Delete', Icons.delete),
      ItemModel('Report', Icons.report),
    ];
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    id = AuthUtil.firebaseAuth.currentUser!.uid;
    if (id.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$id-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$id';
    }

    FirebaseFirestore.instance
        .collection('allUsers')
        .doc(id)
        .update({'chattingWith': widget.peerId});

    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = (await imagePicker.getImage(source: ImageSource.gallery))!;
    imageFile = File(pickedFile.path);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorPage(
            file: imageFile,
            function: uploadFile,
          ),
        ));
  }

  Future uploadFile(File file) async {
    setState(() {
      isLoading = true;
      imageSending = true;
    });
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask.then((res) async {
      res.ref.getDownloadURL();
      imageUrl = await res.ref.getDownloadURL();
      setState(() {
        onSendMessage(imageUrl, 1);
      });
    });
  }

  // Send Messages
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      final DocumentReference messageDoc = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          messageDoc,
          {
            'idFrom': id,
            'idTo': widget.peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'read': false,
            'type': type,
            'deleted': false
          },
        );
      }).then((dynamic success) {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        final DocumentReference documentReference =
            FirebaseFirestore.instance.collection('messages').doc(groupChatId);

        documentReference.set(<String, dynamic>{
          'hiddenBy': [],
          'lastMessage': <String, dynamic>{
            'idFrom': id,
            'idTo': widget.peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'read': false,
            'type': type,
            'deleted': false
          },
          'users': <String>[id, widget.peerId]
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print("Nothing to send!");
    }
    listScrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {
      isLoading = false;
    });
  }

  _buildUploadingImage() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            child: Container(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(colorScheme.onSurface),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(0)),
              ),
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(0)),
            clipBehavior: Clip.hardEdge,
          ),
          new Container(
            height: 25,
          )
        ],
      ),
    );
  }

  // Message item
  Widget buildItem(int index, DocumentSnapshot document) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (data['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 20,
                    maxWidth:
                    MediaQuery.of(context).size.width * 0.7),
                child: Container(
                  child: Text(
                    data['content'],
                    style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(0))),
                ),
              ),
              new Container(
                child: new Row(
                  children: [
                    getTime(data['timestamp']),
                    new SizedBox(
                      width: 5,
                    ),
                    data['read']
                        ? new Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 10,
                    )
                        : new Icon(
                      Icons.check_circle_outline,
                      color: colorScheme.secondaryVariant,
                      size: 10,
                    )
                  ],
                ),
                margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 10.0 : 5.0,
                    right: 0.0,
                    top: 5.0),
              ),
            ],
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      Database.updateMessageRead(document, groupChatId);
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 20,
                          maxWidth:
                          MediaQuery.of(context).size.width *
                              0.7),
                      child: Container(
                        child: Text(
                          data['content'],
                          style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: colorScheme.secondaryVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(0),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                      ),
                    ),
                    Container(
                      child: getTime(data['timestamp']),
                      margin: EdgeInsets.only(
                          bottom:
                          isLastMessageRight(index) ? 10.0 : 5.0,
                          right: 0.0,
                          top: 5.0),
                    ),
                  ],
                )
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  getTime(time) {
    return Text(
      DateFormat('dd MMM h:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(int.parse(time)),
      ),
      style: TextStyle(
          fontSize: 8, color: Theme.of(context).colorScheme.secondaryVariant),
    );
  }

  bool isLastMessageLeft(int index) {
    Map<String, dynamic> data = listMessage[index - 1].data()! as Map<String, dynamic>;
    if ((index > 0 &&
            data['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    Map<String, dynamic> data = listMessage[index].data()! as Map<String, dynamic>;
    if ((index > 0 &&
            data['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('allUsers')
          .doc(id)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Column(
        children: <Widget>[
          // List of messages
          buildListMessage(),
          // Sticker
          // (isShowSticker ? buildSticker() : Container()),
          new Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: isLoading || imageSending
                ? _buildUploadingImage()
                : Container(),
          ),
          // Input content
          buildInput()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildInput() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      // constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 40,
                ),
                child: CupertinoTextField(
                  autocorrect: true,
                  maxLines: 6,
                  minLines: 1,
                  placeholder: "Enter message...",
                  showCursor: true,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  cursorColor: colorScheme.onSecondary,
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (val){
                    UserToken.updateTypingTime();
                  },
                  style:
                      TextStyle(fontSize: 16, color: colorScheme.onSecondary),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          new SizedBox(
            width: 5,
          ),
          // Button send message
          CupertinoButton(
            child: Icon(
              Icons.send,
              color: colorScheme.onSecondary,
            ),
            onPressed: () => onSendMessage(textEditingController.text, 0),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          ),
        ],
      ),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: colorScheme.onSurface,
                  width: 0.5),
              ),
          color: colorScheme.onPrimary),
    );
  }

  // Messages List
  Widget buildListMessage() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.onSurface)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onSurface)));
                } else {
                  listMessage.addAll(snapshot.data!.docs);
                  imageSending = false;
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: false,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data!.docs[index]),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
