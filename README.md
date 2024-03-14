TODO: Crop the image by the rect your choose.

## Features

1.Crop image by ratio.
2.Clip area with gesture scale down and up.
3.Clip area draggable.

## Getting started

add flutter_flappy_crop to your yaml.

## Usage

///image data or imagePath
CropImageViewController controller = CropImageViewController(image: value);

///widget
CropImageView(
controller: controller,
ratio: null,
//ratio: 1.0,
)

///crop
_controller?.cropImage().then((value) {
croppedImage = value;
setState(() {});
});

