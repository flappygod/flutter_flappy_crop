import 'package:flutter/material.dart';
import 'crop_image_gesture_view.dart';
import 'image_tool.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

///controller
class CropImageViewController {
  ///image path
  final String? imagePath;

  ///just image
  final ui.Image? image;

  ///image width and height
  ui.Image? _imageUi;
  Uint8List? _imageData;
  double _imageWidth = 0;
  double _imageHeight = 0;

  ///widget width and height
  double _widgetWidth = 0;
  double _widgetHeight = 0;
  Rect _cropRect = Rect.zero;

  ///crop image
  Future<Uint8List?> cropImage() async {
    if (_imageUi == null || _imageWidth == 0 || _imageHeight == 0) {
      return null;
    }

    ///get width height and position
    double width = (_cropRect.width / _widgetWidth) * _imageWidth;
    double height = (_cropRect.height / _widgetHeight) * _imageHeight;
    double left = (_cropRect.left / _widgetWidth) * _imageWidth;
    double top = (_cropRect.top / _widgetHeight) * _imageHeight;

    ///total image
    Rect cropRect = Rect.fromLTWH(left, top, width, height);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawImageRect(
      _imageUi!,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );
    final ui.Image croppedImage = await recorder.endRecording().toImage(
          cropRect.width.toInt(),
          cropRect.height.toInt(),
        );
    final ByteData? byteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  CropImageViewController({
    this.imagePath,
    this.image,
  }) : assert(imagePath != null || image != null);
}

///crop image view
class CropImageView extends StatefulWidget {
  ///controller
  final CropImageViewController controller;

  ///min width
  final double minWidth;

  ///min height
  final double minHeight;

  ///init scale
  final double initScale;

  ///ratio
  final double? ratio;

  ///corner show
  final bool cornerShow;

  ///corner length
  final double cornerLength;

  ///corner color
  final Color cornerColor;

  ///corner width
  final double cornerWidth;

  ///border show
  final bool borderShow;

  ///border width
  final double borderWidth;

  ///border color
  final Color borderColor;

  ///three line show
  final bool threeLineShow;

  ///three line width
  final double threeLineWidth;

  ///three line color
  final Color threeLineColor;

  ///scrimColor
  final Color scrimColor;

  ///loading widget
  final Widget? loading;

  const CropImageView({
    super.key,
    required this.controller,
    this.minWidth = 50,
    this.minHeight = 50,
    this.borderColor = Colors.white70,
    this.threeLineColor = Colors.white70,
    this.cornerColor = Colors.white70,
    this.ratio,
    this.initScale = 0.9,
    this.scrimColor = Colors.black54,
    this.cornerShow = true,
    this.cornerLength = 15,
    this.cornerWidth = 3,
    this.borderWidth = 1,
    this.borderShow = true,
    this.threeLineWidth = 1,
    this.threeLineShow = true,
    this.loading,
  });

  @override
  State<StatefulWidget> createState() {
    return _CropImageViewState();
  }
}

///crop image view state
class _CropImageViewState extends State<CropImageView> {
  ///resolve image
  void _resolveImage() {
    if (widget.controller.image != null) {
      ImageCropTool.changeImageToData(widget.controller.image!).then((value) {
        assert(widget.controller._imageUi == null);
        widget.controller._imageUi = widget.controller.image;
        widget.controller._imageData = value;
        widget.controller._imageWidth =
            widget.controller.image!.width.toDouble();
        widget.controller._imageHeight =
            widget.controller.image!.height.toDouble();
        if (mounted) {
          setState(() {});
        }
      });
      return;
    }
    if (widget.controller.imagePath != null) {
      ImageCropTool.loadImageFromFile(File(widget.controller.imagePath!))
          .then((value) {
        if (value != null) {
          ImageCropTool.changeImageToData(value).then((data) {
            assert(widget.controller._imageUi == null);
            widget.controller._imageUi = value;
            widget.controller._imageData = data;
            widget.controller._imageWidth = value.width.toDouble();
            widget.controller._imageHeight = value.height.toDouble();
            if (mounted) {
              setState(() {});
            }
          });
        }
      });
      return;
    }
  }

  @override
  void initState() {
    _resolveImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _buildImage(),
          _buildClip(),
        ],
      ),
    );
  }

  ///build image
  Widget _buildImage() {
    if (widget.controller._imageData != null) {
      return Image.memory(
        widget.controller._imageData!,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox();
  }

  ///build loading
  Widget _buildClip() {
    if (widget.controller._imageData == null) {
      return widget.loading ?? const SizedBox();
    }
    return _buildClipArea();
  }

  ///build clip area
  Widget _buildClipArea() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double ratioImage =
            widget.controller._imageWidth / widget.controller._imageHeight;
        double ratioBox = constraints.maxWidth / constraints.maxHeight;
        double width = ratioImage > ratioBox
            ? constraints.maxWidth
            : constraints.maxHeight * ratioImage;
        double height = ratioImage < ratioBox
            ? constraints.maxHeight
            : constraints.maxWidth / ratioImage;
        return CropImageGestureView(
          width: width,
          height: height,
          borderColor: widget.borderColor,
          threeLineColor: widget.threeLineColor,
          cornerColor: widget.cornerColor,
          minWidth: widget.minWidth,
          minHeight: widget.minHeight,
          ratio: widget.ratio,
          initScale: widget.initScale,
          scrimColor: widget.scrimColor,
          cornerShow: widget.cornerShow,
          cornerLength: widget.cornerLength,
          cornerWidth: widget.cornerWidth,
          borderWidth: widget.borderWidth,
          borderShow: widget.borderShow,
          threeLineWidth: widget.threeLineWidth,
          threeLineShow: widget.threeLineShow,
          onChange: (width, height, rect) {
            ///set width and height
            widget.controller._widgetWidth = width;
            widget.controller._widgetHeight = height;
            widget.controller._cropRect = rect;
          },
        );
      },
    );
  }
}
