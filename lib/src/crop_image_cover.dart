import 'package:flutter/material.dart';

class CropImageCover extends StatelessWidget {
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

  ///center  rect
  final Rect rect;

  const CropImageCover({
    super.key,
    required this.rect,
    required this.borderColor,
    required this.threeLineColor,
    required this.cornerColor,
    this.scrimColor = Colors.black54,
    this.cornerShow = true,
    this.cornerLength = 15,
    this.cornerWidth = 3,
    this.borderWidth = 1,
    this.borderShow = true,
    this.threeLineWidth = 1,
    this.threeLineShow = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _CropImageCoverPainter(this),
        size: Size.infinite,
      ),
    );
  }
}

///cover painter
class _CropImageCoverPainter extends CustomPainter {
  ///cover
  final CropImageCover cover;

  ///painter
  _CropImageCoverPainter(this.cover);

  @override
  void paint(Canvas canvas, Size size) {
    ///paint create
    Paint paint = Paint()
      ..color = cover.scrimColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    ///draw shadows
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cover.rect.left, size.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cover.rect.left, 0, cover.rect.width, cover.rect.top),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          cover.rect.right, 0, size.width - cover.rect.right, size.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cover.rect.left, cover.rect.bottom, cover.rect.width,
          size.height - cover.rect.bottom),
      paint,
    );

    ///draw corners
    if (cover.cornerShow) {
      canvas.drawPath(
          Path()
            ..addPolygon([
              cover.rect.topLeft.translate(0, cover.cornerLength),
              cover.rect.topLeft,
              cover.rect.topLeft.translate(cover.cornerLength, 0)
            ], false)
            ..addPolygon([
              cover.rect.topRight.translate(0, cover.cornerLength),
              cover.rect.topRight,
              cover.rect.topRight.translate(-cover.cornerLength, 0)
            ], false)
            ..addPolygon([
              cover.rect.bottomLeft.translate(0, -cover.cornerLength),
              cover.rect.bottomLeft,
              cover.rect.bottomLeft.translate(cover.cornerLength, 0)
            ], false)
            ..addPolygon([
              cover.rect.bottomRight.translate(0, -cover.cornerLength),
              cover.rect.bottomRight,
              cover.rect.bottomRight.translate(-cover.cornerLength, 0)
            ], false),
          Paint()
            ..color = cover.cornerColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = cover.cornerWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.miter
            ..isAntiAlias = true);
    }

    ///draw rect lines
    if (cover.borderShow) {
      canvas.drawPath(
          Path()
            ..addPolygon(
              [
                cover.rect.topLeft.translate(cover.cornerLength, 0),
                cover.rect.topRight.translate(-cover.cornerLength, 0)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.bottomLeft.translate(cover.cornerLength, 0),
                cover.rect.bottomRight.translate(-cover.cornerLength, 0)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.topLeft.translate(0, cover.cornerLength),
                cover.rect.bottomLeft.translate(0, -cover.cornerLength)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.topRight.translate(0, cover.cornerLength),
                cover.rect.bottomRight.translate(0, -cover.cornerLength)
              ],
              false,
            ),
          Paint()
            ..color = cover.borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = cover.borderWidth
            ..strokeCap = StrokeCap.butt
            ..isAntiAlias = true);
    }

    ///draw third lines
    if (cover.threeLineShow) {
      final thirdHeight = cover.rect.height / 3.0;
      final thirdWidth = cover.rect.width / 3.0;
      canvas.drawPath(
          Path()
            ..addPolygon(
              [
                cover.rect.topLeft.translate(0, thirdHeight),
                cover.rect.topRight.translate(0, thirdHeight)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.bottomLeft.translate(0, -thirdHeight),
                cover.rect.bottomRight.translate(0, -thirdHeight)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.topLeft.translate(thirdWidth, 0),
                cover.rect.bottomLeft.translate(thirdWidth, 0)
              ],
              false,
            )
            ..addPolygon(
              [
                cover.rect.topRight.translate(-thirdWidth, 0),
                cover.rect.bottomRight.translate(-thirdWidth, 0)
              ],
              false,
            ),
          Paint()
            ..color = cover.threeLineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = cover.threeLineWidth
            ..strokeCap = StrokeCap.butt
            ..isAntiAlias = true);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
