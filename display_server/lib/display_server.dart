import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:http/http.dart';

Future downloadImageFromURL(String url, String extension) async {
  return File('image.$extension')
      .writeAsBytesSync((await get(Uri.parse(url))).bodyBytes);
}

Future pixelation(String extension, int width) async {
  final cmd = img.Command()
    ..decodeImageFile('image.$extension')
    ..copyResize(width: width)
    ..writeToFile('result.$extension');
  return await cmd.executeThread();
}

Future<String> getColors(String path) async {
  String colors = '';

  final photo = await img.decodeImageFile(path);
  for (int y = 0; y < photo!.height; y++) {
    for (int x = 0; x < photo.width; x++) {
      final pixel = photo.getPixelSafe(x.toInt(), y.toInt());

      double colorSeparation(color) {
        return color / 255;
      }

      double r = colorSeparation(pixel.r);
      double g = colorSeparation(pixel.g);
      double b = colorSeparation(pixel.b);

      colors +=
          '${r.toStringAsFixed(8)},${g.toStringAsFixed(8)},${b.toStringAsFixed(8)},${(x * 0.1).toStringAsFixed(2)},${(y * -0.1 + photo.height * 0.1).toStringAsFixed(2)}/';
    }
  }

  return colors;
}
