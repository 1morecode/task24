import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:painter/painter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ImageEditorPage extends StatefulWidget {
  final File file;
  final Function function;

  ImageEditorPage({required this.file, required this.function});

  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {

  PainterController _controller = _newController();
  GlobalKey _globalKey = new GlobalKey();
  late File file;

  @override
  void initState() {
    file = widget.file;
    super.initState();
  }

  static PainterController _newController() {
    PainterController controller = new PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  Future<Uint8List?> _captureImage() async {
    try {
      print('inside');
      RenderObject? boundary =
      _globalKey.currentContext!.findRenderObject();
      ui.Image image = await (boundary as OffsetLayer).toImage(boundary!.paintBounds, pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    List<Widget> actions = <Widget>[
      new IconButton(
          icon: new Icon(
            Icons.undo,
            color: colorScheme.onSecondary,
          ),
          tooltip: 'Undo',
          onPressed: () {
            if (_controller.isEmpty) {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) =>
                  new Text('Nothing to undo'));
            } else {
              _controller.undo();
            }
          }),
      new IconButton(
          icon: new Icon(Icons.delete, color: colorScheme.onSecondary,),
          tooltip: 'Clear',
          onPressed: _controller.clear),
      new IconButton(
          icon: new Icon(Icons.check, color: colorScheme.onSecondary,),
          onPressed: () async{
            Uint8List? base = await _captureImage();
            // String ss = await _createFileFromString(base!);
            File f = File.fromRawPath(base!);
            // print("File path $ss");
            widget.function(f);
            Navigator.of(context).pop();
          }),
    ];
    return new Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: new AppBar(
        elevation: 1,
          backgroundColor: colorScheme.onPrimary,
          actions: actions,
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
      bottomSheet: Container(
        height: 45,
        color: colorScheme.onSurface,
        width: MediaQuery.of(context).size.width,
        child: DrawBar(_controller),
      ),
      body: SafeArea(child: new Center(
          child: RepaintBoundary(
            key: _globalKey,
            child: new Container(
              height: MediaQuery.of(context).size.height*0.75,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(file),
                  new Painter(_controller)
                ],
              ),
            ),
          )),),
    );
  }

}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return IconButton(
                  icon: new Icon(_controller.eraseMode ? Icons.view_stream: Icons.create, color: colorScheme.onSecondary,),
                  tooltip: (_controller.eraseMode ? 'Disable' : 'Enable') +
                      ' eraser',
                  onPressed: () {
                    setState(() {
                      _controller.eraseMode = !_controller.eraseMode;
                    });
                  });
            }),
        new Expanded(child: new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return new Container(
                  child: new Slider(
                    value: _controller.thickness,
                    onChanged: (double value) => setState(() {
                      _controller.thickness = value;
                    }),
                    min: 1.0,
                    max: 20.0,
                    activeColor: colorScheme.onSecondary,
                  ));
            })),
      ],
    );
  }
}
