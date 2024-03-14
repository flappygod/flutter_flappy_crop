import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as assets;
import 'package:flutter/material.dart' as assets;
import 'package:flutter_flappy_crop/flutter_flappy_crop.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///create controller
  CropImageViewController? _controller;

  //assets bundle
  static assets.AssetBundle getAssetBundle() => assets.rootBundle;

  Uint8List? croppedImage;

  @override
  void initState() {
    loadImageFromAssets("assets/bg-hero-01.jpg").then((value) {
      _controller = CropImageViewController(image: value);
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  //load image from assets
  static Future<ui.Image?> loadImageFromAssets(String path) async {
    //get assets stream
    assets.ImageStream stream =
        assets.AssetImage(path, bundle: getAssetBundle())
            .resolve(assets.ImageConfiguration.empty);
    //complete
    Completer<ui.Image?> completer = Completer<ui.Image?>();
    //listener
    assets.ImageStreamListener listener = assets.ImageStreamListener(
        (assets.ImageInfo frame, bool synchronousCall) {
      final ui.Image image = frame.image;
      if (!completer.isCompleted) {
        completer.complete(image);
      }
    }, onError: (Object exception, StackTrace? stackTrace) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    completer.future.then((value) {
      stream.removeListener(listener);
    });
    //dd listener
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          _controller == null
              ? const SizedBox()
              : CropImageView(
                  controller: _controller!,
                  ratio: 1.0,
                ),
          Align(
            alignment: Alignment.topCenter,
            child: croppedImage != null
                ? Image.memory(
                    croppedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _controller?.cropImage().then((value) {
                  croppedImage = value;
                  setState(() {});
                });
              },
              child: Container(
                width: 100,
                height: 30,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: const Text(
                  'Crop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
