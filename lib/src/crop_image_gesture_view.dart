import 'package:flutter/material.dart';
import 'crop_image_cover.dart';
import 'dart:math';

///rect
typedef CropImageRectChanged = Function(double width, double height, Rect rect);

///crop image area view
class CropImageGestureView extends StatefulWidget {
  ///on change
  final CropImageRectChanged? onChange;

  ///width
  final double width;

  ///height
  final double height;

  ///min width and height
  final double minWidth;
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

  const CropImageGestureView({
    super.key,
    required this.width,
    required this.height,
    this.borderColor = Colors.white70,
    this.threeLineColor = Colors.white70,
    this.cornerColor = Colors.white70,
    this.minWidth = 0,
    this.minHeight = 0,
    this.ratio = 1.0,
    this.initScale = 0.9,
    this.scrimColor = Colors.black54,
    this.cornerShow = true,
    this.cornerLength = 15,
    this.cornerWidth = 3,
    this.borderWidth = 1,
    this.borderShow = true,
    this.threeLineWidth = 1,
    this.threeLineShow = true,
    this.onChange,
  }) : assert(initScale <= 1.0);

  @override
  State<StatefulWidget> createState() {
    return _CropImageGestureViewState();
  }
}

///position type
enum PositionType {
  leftTop,
  rightTop,
  leftBottom,
  rightBottom,
  center,
}

///crop image area view state
class _CropImageGestureViewState extends State<CropImageGestureView> {
  ///left top width height
  double _left = 0;
  double _top = 0;
  double _width = 0;
  double _height = 0;

  ///start ratio，start scale

  Rect _startRect = const Rect.fromLTRB(0, 0, 0, 0);
  Offset _startCenter = const Offset(0, 0);

  PositionType _startPositionType = PositionType.center;
  Offset _startPosition = const Offset(0, 0);

  ///10
  final int dotSpaceArea = 15;

  ///init clip rect
  void _initClipRect() {
    double width = widget.width * widget.initScale;
    double height = widget.height * widget.initScale;
    double ratioContainer = widget.width / widget.height;
    if (widget.ratio != null) {
      width = widget.ratio! > ratioContainer ? width : height * widget.ratio!;
      height = widget.ratio! < ratioContainer ? height : width / widget.ratio!;
    }
    _width = width;
    _height = height;
    _left = (widget.width - width) / 2;
    _top = (widget.height - height) / 2;

    _notifyChanged();
  }

  void _notifyChanged() {
    ///on change
    if (widget.onChange != null) {
      widget.onChange!(widget.width, widget.height,
          Rect.fromLTWH(_left, _top, _width, _height));
    }
  }

  ///init state
  @override
  void initState() {
    _initClipRect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (ScaleStartDetails details) {
        ///this is for scales
        if (details.pointerCount > 1) {
          _startRect = Rect.fromLTWH(_left, _top, _width, _height);
          _startCenter = Offset(_left + _width / 2, _top + _height / 2);
          _startPosition = details.localFocalPoint;
        }

        ///just one position
        if (details.pointerCount == 1) {
          _startRect = Rect.fromLTWH(_left, _top, _width, _height);
          _startCenter = Offset(_left + _width / 2, _top + _height / 2);
          _startPosition = details.localFocalPoint;

          _startPositionType = PositionType.center;
          Offset leftTop = Offset(_left, _top);
          if ((details.localFocalPoint.dx - leftTop.dx).toInt().abs() <
                  dotSpaceArea &&
              (details.localFocalPoint.dy - leftTop.dy).toInt().abs() <
                  dotSpaceArea) {
            _startPositionType = PositionType.leftTop;
          }
          Offset leftBottom = Offset(_left, _top + _height);
          if ((details.localFocalPoint.dx - leftBottom.dx).toInt().abs() <
                  dotSpaceArea &&
              (details.localFocalPoint.dy - leftBottom.dy).toInt().abs() <
                  dotSpaceArea) {
            _startPositionType = PositionType.leftBottom;
          }
          Offset rightTop = Offset(_left + _width, _top);
          if ((details.localFocalPoint.dx - rightTop.dx).toInt().abs() <
                  dotSpaceArea &&
              (details.localFocalPoint.dy - rightTop.dy).toInt().abs() <
                  dotSpaceArea) {
            _startPositionType = PositionType.rightTop;
          }
          Offset rightBottom = Offset(_left + _width, _top + _height);
          if ((details.localFocalPoint.dx - rightBottom.dx).toInt().abs() <
                  dotSpaceArea &&
              (details.localFocalPoint.dy - rightBottom.dy).toInt().abs() <
                  dotSpaceArea) {
            _startPositionType = PositionType.rightBottom;
          }
        }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        if (details.pointerCount == 1) {
          _updatePosition(details);
        } else {
          _updateScale(details);
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        ///end
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            _buildChild(),
          ],
        ),
      ),
    );
  }

  ///update details
  void _updateScale(ScaleUpdateDetails details) {
    ///get scale
    double scale = details.scale;

    double startRatio = _startRect.width / _startRect.height;

    double newWidth = _startRect.width * scale;
    double newHeight = _startRect.height * scale;
    double newLeft = _startCenter.dx - newWidth / 2;
    double newTop = _startCenter.dy - newHeight / 2;

    ///width min boundary
    if (newWidth < widget.minWidth) {
      newWidth = min(widget.minWidth, max(_width, newWidth));
      newHeight = newWidth / startRatio;
      newLeft = _startCenter.dx - newWidth / 2;
      newTop = _startCenter.dy - newHeight / 2;
    }

    ///height min boundary
    if (newHeight < widget.minHeight) {
      newHeight = min(widget.minHeight, max(_height, newHeight));
      newWidth = newHeight * startRatio;
      newLeft = _startCenter.dx - newWidth / 2;
      newTop = _startCenter.dy - newHeight / 2;
    }

    ///right limit
    if (newLeft + newWidth > widget.width) {
      newLeft = widget.width - newWidth;
    }

    ///bottom limit
    if (newTop + newHeight > widget.height) {
      newTop = widget.height - newHeight;
    }

    ///left boundary
    if (newLeft < 0) {
      newLeft = 0;
    }

    ///top boundary
    if (newTop < 0) {
      newTop = 0;
    }

    Rect rectOne = Rect.zero;
    Rect rectTwo = Rect.zero;

    ///width limit
    if (newLeft + newWidth > widget.width) {
      double newLeftOne = 0;
      double newWidthOne = widget.width;
      double newHeightOne = newWidthOne / startRatio;
      double newTopOne = min(_top, widget.height - newHeightOne);
      rectOne = Rect.fromLTWH(newLeftOne, newTopOne, newWidthOne, newHeightOne);
    }

    ///height limit
    if (newTop + newHeight > widget.height) {
      double newTopTwo = 0;
      double newHeightTwo = widget.height;
      double newWidthTwo = newHeightTwo * startRatio;
      double newLeftTwo = min(_left, widget.width - newWidthTwo);
      rectTwo = Rect.fromLTWH(newLeftTwo, newTopTwo, newWidthTwo, newHeightTwo);
    }

    ///width limit
    if (rectOne != Rect.zero && rectTwo == Rect.zero) {
      _width = rectOne.width;
      _height = rectOne.height;
      _left = rectOne.left;
      _top = rectOne.top;
    }

    ///height limit
    if (rectOne == Rect.zero && rectTwo != Rect.zero) {
      _width = rectTwo.width;
      _height = rectTwo.height;
      _left = rectTwo.left;
      _top = rectTwo.top;
    }

    ///all limit,get the small one
    if (rectOne != Rect.zero && rectTwo != Rect.zero) {
      if (rectOne.width > rectTwo.width) {
        _width = rectTwo.width;
        _height = rectTwo.height;
        _left = rectTwo.left;
        _top = rectTwo.top;
      }
      if (rectOne.width < rectTwo.width) {
        _width = rectOne.width;
        _height = rectOne.height;
        _left = rectOne.left;
        _top = rectOne.top;
      }
    }

    ///no limit
    if (rectOne == Rect.zero && rectTwo == Rect.zero) {
      _width = newWidth;
      _height = newHeight;
      _left = newLeft;
      _top = newTop;
    }

    _notifyChanged();
    setState(() {});
  }

  ///update position
  void _updatePosition(ScaleUpdateDetails details) {
    switch (_startPositionType) {
      case PositionType.center:
        _moveCenter(details);
        break;
      case PositionType.leftTop:
        if (widget.ratio == null) {
          _moveTopLeft(details);
        } else {
          _moveTopLeftRatio(details);
        }
        break;
      case PositionType.rightTop:
        if (widget.ratio == null) {
          _moveTopRight(details);
        } else {
          _moveTopRightRatio(details);
        }
        break;
      case PositionType.leftBottom:
        if (widget.ratio == null) {
          _moveBottomLeft(details);
        } else {
          _moveBottomLeftRatio(details);
        }
        break;
      case PositionType.rightBottom:
        if (widget.ratio == null) {
          _moveBottomRight(details);
        } else {
          _moveBottomRightRatio(details);
        }
        break;
    }
  }

  ///move center
  void _moveCenter(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;
    double newLeft = _startCenter.dx + deltaX - _width / 2;
    double newTop = _startCenter.dy + deltaY - _height / 2;

    if (newLeft < 0) {
      newLeft = 0;
    }
    if (newLeft > widget.width - _width) {
      newLeft = widget.width - _width;
    }
    if (newTop < 0) {
      newTop = 0;
    }
    if (newTop > widget.height - _height) {
      newTop = widget.height - _height;
    }
    _left = newLeft;
    _top = newTop;
    _notifyChanged();
    setState(() {});
  }

  ///move top left
  void _moveTopLeft(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left + deltaX,
      _startRect.top + deltaY,
      _startRect.right,
      _startRect.bottom,
    );
    if (rect.left < 0) {
      rect = Rect.fromLTRB(0, rect.top, rect.right, rect.bottom);
    }
    if (rect.top < 0) {
      rect = Rect.fromLTRB(rect.left, 0, rect.right, rect.bottom);
    }
    double minWidth = min(min(widget.minWidth, _width), widget.width);
    if (rect.width < minWidth) {
      rect = Rect.fromLTRB(
          rect.right - minWidth, rect.top, rect.right, rect.bottom);
    }
    double minHeight = min(min(widget.minHeight, _height), widget.height);
    if (rect.height < minHeight) {
      rect = Rect.fromLTRB(
          rect.left, rect.bottom - minHeight, rect.right, rect.bottom);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move top left
  void _moveTopLeftRatio(ScaleUpdateDetails details) {
    ///deltaX and deltaY
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;
    if (_startRect.left + deltaX > _startRect.right) {
      return;
    }
    if (_startRect.top + deltaY > _startRect.bottom) {
      return;
    }

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left + deltaX,
      _startRect.top + deltaY,
      _startRect.right,
      _startRect.bottom,
    );

    ///ratio
    if (rect.width / rect.height >= widget.ratio!) {
      double width = rect.height * widget.ratio!;

      ///one and two
      double minWidthOne = widget.minHeight * widget.ratio!;
      double minWidthTwo = widget.minWidth;
      double minWidth = min(max(minWidthOne, minWidthTwo), _width);
      double maxWidth = min(rect.bottom * widget.ratio!, rect.right);

      ///width
      width = min(max(width, minWidth), maxWidth);

      rect = Rect.fromLTRB(rect.right - width,
          rect.bottom - width / widget.ratio!, rect.right, rect.bottom);
    }
    if (rect.width / rect.height < widget.ratio!) {
      double height = rect.width / widget.ratio!;

      ///one and two
      double minHeightOne = widget.minWidth / widget.ratio!;
      double minHeightTwo = widget.minHeight;
      double minHeight = min(max(minHeightOne, minHeightTwo), _height);
      double maxHeight = min(rect.right / widget.ratio!, rect.bottom);

      ///height
      height = min(max(height, minHeight), maxHeight);

      rect = Rect.fromLTRB(rect.right - height * widget.ratio!,
          rect.bottom - height, rect.right, rect.bottom);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move top right
  void _moveTopRight(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left,
      _startRect.top + deltaY,
      _startRect.right + deltaX,
      _startRect.bottom,
    );

    if (rect.right > widget.width) {
      rect = Rect.fromLTRB(rect.left, rect.top, widget.width, rect.bottom);
    }
    if (rect.top < 0) {
      rect = Rect.fromLTRB(rect.left, 0, rect.right, rect.bottom);
    }
    double minWidth = min(min(widget.minWidth, _width), widget.width);
    if (rect.right < minWidth + _startRect.left) {
      rect = Rect.fromLTRB(
          rect.left, rect.top, minWidth + _startRect.left, rect.bottom);
    }
    double minHeight = min(min(widget.minHeight, _height), widget.height);
    if (rect.top > _startRect.bottom - minHeight) {
      rect = Rect.fromLTRB(
          rect.left, _startRect.bottom - minHeight, rect.right, rect.bottom);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move top right
  void _moveTopRightRatio(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    if (_startRect.left > _startRect.right + deltaX) {
      return;
    }
    if (_startRect.top + deltaY > _startRect.bottom) {
      return;
    }

    /// top right
    Rect rect = Rect.fromLTRB(
      _startRect.left,
      _startRect.top + deltaY,
      _startRect.right + deltaX,
      _startRect.bottom,
    );

    ///ratio
    if (rect.width / rect.height >= widget.ratio!) {
      double width = rect.height * widget.ratio!;

      ///one and two
      double minWidthOne = widget.minHeight * widget.ratio!;
      double minWidthTwo = widget.minWidth;
      double minWidth = min(max(minWidthOne, minWidthTwo), _width);
      double maxWidth =
          min(rect.bottom * widget.ratio!, widget.width - rect.left);

      ///width
      width = min(max(width, minWidth), maxWidth);

      rect = Rect.fromLTRB(rect.left, rect.bottom - width / widget.ratio!,
          rect.left + width, rect.bottom);
    }
    if (rect.width / rect.height < widget.ratio!) {
      double height = rect.width / widget.ratio!;

      ///one and two
      double minHeightOne = widget.minWidth / widget.ratio!;
      double minHeightTwo = widget.minHeight;
      double minHeight = min(max(minHeightOne, minHeightTwo), _height);
      double maxHeight =
          min((widget.width - rect.left) / widget.ratio!, rect.bottom);

      ///height
      height = min(max(height, minHeight), maxHeight);

      rect = Rect.fromLTRB(rect.left, rect.bottom - height,
          rect.left + height * widget.ratio!, rect.bottom);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move bottom left
  void _moveBottomLeft(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left + deltaX,
      _startRect.top,
      _startRect.right,
      _startRect.bottom + deltaY,
    );

    if (rect.left < 0) {
      rect = Rect.fromLTRB(0, rect.top, rect.right, rect.bottom);
    }
    double minWidth = min(min(widget.minWidth, _width), widget.width);
    if (rect.width < minWidth) {
      rect = Rect.fromLTRB(
          rect.right - minWidth, rect.top, rect.right, rect.bottom);
    }
    if (rect.bottom > widget.height) {
      rect = Rect.fromLTRB(rect.left, rect.top, rect.right, widget.height);
    }
    double minHeight = min(min(widget.minHeight, _height), widget.height);
    if (rect.bottom < _startRect.top + minHeight) {
      rect = Rect.fromLTRB(
          rect.left, rect.top, rect.right, _startRect.top + minHeight);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move bottom left ratio
  void _moveBottomLeftRatio(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    if (_startRect.left + deltaX > _startRect.right) {
      return;
    }
    if (_startRect.top > _startRect.bottom + deltaY) {
      return;
    }

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left + deltaX,
      _startRect.top,
      _startRect.right,
      _startRect.bottom + deltaY,
    );

    ///ratio
    if (rect.width / rect.height >= widget.ratio!) {
      double width = rect.height * widget.ratio!;

      ///one and two
      double minWidthOne = widget.minHeight * widget.ratio!;
      double minWidthTwo = widget.minWidth;
      double minWidth = min(max(minWidthOne, minWidthTwo), _width);
      double maxWidth =
          min((widget.height - rect.top) * widget.ratio!, rect.right);

      ///width
      width = min(max(width, minWidth), maxWidth);

      rect = Rect.fromLTRB(rect.right - width, rect.top, rect.right,
          rect.top + width / widget.ratio!);
    }
    if (rect.width / rect.height < widget.ratio!) {
      double height = rect.width / widget.ratio!;

      ///one and two
      double minHeightOne = widget.minWidth / widget.ratio!;
      double minHeightTwo = widget.minHeight;
      double minHeight = min(max(minHeightOne, minHeightTwo), _height);
      double maxHeight =
          min(rect.right / widget.ratio!, widget.height - rect.top);

      ///height
      height = min(max(height, minHeight), maxHeight);
      rect = Rect.fromLTRB(rect.right - height * widget.ratio!, rect.top,
          rect.right, rect.top + height);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move bottom right
  void _moveBottomRight(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    ///left top
    Rect rect = Rect.fromLTRB(
      _startRect.left,
      _startRect.top,
      _startRect.right + deltaX,
      _startRect.bottom + deltaY,
    );

    if (rect.right > widget.width) {
      rect = Rect.fromLTRB(rect.left, rect.top, widget.width, rect.bottom);
    }
    if (rect.bottom > widget.height) {
      rect = Rect.fromLTRB(rect.left, rect.top, rect.right, widget.height);
    }
    double minWidth = min(min(widget.minWidth, _width), widget.width);
    if (rect.right < _startRect.left + minWidth) {
      rect = Rect.fromLTRB(
          rect.left, rect.top, _startRect.left + minWidth, rect.bottom);
    }
    double minHeight = min(min(widget.minHeight, _height), widget.height);
    if (rect.bottom < _startRect.top + minHeight) {
      rect = Rect.fromLTRB(
          rect.left, rect.top, rect.right, _startRect.top + minHeight);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///move bottom right ratio
  void _moveBottomRightRatio(ScaleUpdateDetails details) {
    double deltaX = details.localFocalPoint.dx - _startPosition.dx;
    double deltaY = details.localFocalPoint.dy - _startPosition.dy;

    if (_startRect.left > _startRect.right + deltaX) {
      return;
    }
    if (_startRect.top > _startRect.bottom + deltaY) {
      return;
    }

    ///bottom right
    Rect rect = Rect.fromLTRB(
      _startRect.left,
      _startRect.top,
      _startRect.right + deltaX,
      _startRect.bottom + deltaY,
    );

    ///ratio
    if (rect.width / rect.height >= widget.ratio!) {
      double width = rect.height * widget.ratio!;

      ///one and two
      double minWidthOne = widget.minHeight * widget.ratio!;
      double minWidthTwo = widget.minWidth;
      double minWidth = min(max(minWidthOne, minWidthTwo), _width);
      double maxWidth = min(
          (widget.height - rect.top) * widget.ratio!, widget.width - rect.left);

      ///width
      width = min(max(width, minWidth), maxWidth);

      rect = Rect.fromLTRB(rect.left, rect.top, rect.left + width,
          rect.top + width / widget.ratio!);
    }
    if (rect.width / rect.height < widget.ratio!) {
      double height = rect.width / widget.ratio!;

      ///one and two
      double minHeightOne = widget.minWidth / widget.ratio!;
      double minHeightTwo = widget.minHeight;
      double minHeight = min(max(minHeightOne, minHeightTwo), _height);
      double maxHeight = min((widget.width - rect.left) / widget.ratio!,
          widget.height - _startRect.top);

      ///height
      height = min(max(height, minHeight), maxHeight);
      rect = Rect.fromLTRB(rect.left, rect.top,
          rect.left + height * widget.ratio!, rect.top + height);
    }
    _left = rect.left;
    _top = rect.top;
    _width = rect.width;
    _height = rect.height;
    _notifyChanged();
    setState(() {});
  }

  ///build child
  Widget _buildChild() {
    return CropImageCover(
      rect: Rect.fromLTWH(_left, _top, _width, _height),
      borderColor: widget.borderColor,
      threeLineColor: widget.threeLineColor,
      cornerColor: widget.cornerColor,
      scrimColor: widget.scrimColor,
      cornerShow: widget.cornerShow,
      cornerLength: widget.cornerLength,
      cornerWidth: widget.cornerWidth,
      borderWidth: widget.borderWidth,
      borderShow: widget.borderShow,
      threeLineWidth: widget.threeLineWidth,
      threeLineShow: widget.threeLineShow,
    );
  }
}
