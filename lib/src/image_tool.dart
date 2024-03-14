import 'package:flutter/material.dart' as assets;
import 'package:flutter/widgets.dart' as assets;
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'dart:ui';

class ImageTool {
  ///image to Uint8List
  static Future<Uint8List> changeImageToData(ui.Image image) async {
    //get byte data
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    //to List
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    //return
    return pngBytes;
  }

  ///load image form file
  static Future<ui.Image?> loadImageFromFile(File file) async {
    //read
    assets.ImageStream stream =
        assets.FileImage(file).resolve(assets.ImageConfiguration.empty);
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
    //complete
    completer.future.then((value) {
      stream.removeListener(listener);
    });
    //add listener
    stream.addListener(listener);
    //return the future
    return completer.future;
  }

  ///get image's width and height
  static Future<Size?> getImageWH(String path) {
    Completer<Size?> completer = Completer<Size?>();
    assets.FileImage(File(path))
        .resolve(const assets.ImageConfiguration())
        .addListener(
          assets.ImageStreamListener(
            (assets.ImageInfo info, bool flag) {
              if (!completer.isCompleted) {
                completer.complete(
                  assets.Size(
                    info.image.width.toDouble(),
                    info.image.height.toDouble(),
                  ),
                );
              }
            },
            onError: (Object exception, StackTrace? stackTrace) {
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            },
          ),
        );
    return completer.future;
  }
}
