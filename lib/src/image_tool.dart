import 'package:flutter/material.dart' as assets;
import 'package:flutter/widgets.dart' as assets;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'dart:ui';

class ImageCropTool {
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
    //check exists
    if (!file.existsSync()) {
      throw Exception("file does not exist: ${file.path}");
    }

    //create stream
    assets.ImageStream stream = assets.FileImage(file).resolve(
      assets.ImageConfiguration.empty,
    );
    Completer<ui.Image?> completer = Completer<ui.Image?>();

    //add listener
    assets.ImageStreamListener listener = assets.ImageStreamListener(
      (assets.ImageInfo frame, bool synchronousCall) {
        final ui.Image image = frame.image;
        if (!completer.isCompleted) {
          completer.complete(image);
        }
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
      },
    );
    try {
      stream.addListener(listener);
      return await completer.future;
    } finally {
      stream.removeListener(listener);
    }
  }
}
