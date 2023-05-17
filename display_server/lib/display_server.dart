import 'dart:convert';
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

Future<String> getCommand(String path) async {
  String command = '';

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

      command +=
          'particle display:pixel_${r.toStringAsFixed(1)}_${g.toStringAsFixed(1)}_${b.toStringAsFixed(1)} ~${(x * 0.1).toStringAsFixed(2)} ~${(y * -0.1 + photo.height * 0.1).toStringAsFixed(2)} ~/';
    }
  }

  return command;
}

Map<String, String> envVars = Platform.environment;

final host = InternetAddress.loopbackIPv4;
final port = int.parse(envVars['MINECRAFT_DISPLAY_PORT'] ?? '8080');

List<HttpRequest> getChatRequests = [];

void startHttpServer() async {
  HttpServer server = await HttpServer.bind(host, port, shared: false);
  await for (HttpRequest request in server) {
    request.response.headers.contentType = ContentType.text;
    if (request.method == 'POST' && request.uri.path == '/minecraft/display') {
      print('POST request');
      String url = await utf8.decodeStream(request);
      if (url == "") {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('')
          ..close();
        continue;
      }
      int width = int.parse(url.split(' ')[0]);
      String extension = url.split(' ')[1];
      if (!(extension == 'png' ||
          extension == 'jpg' ||
          extension == 'jpeg' ||
          extension == 'ico')) continue;
      await downloadImageFromURL(url.split(' ')[2], extension);
      await pixelation(extension, width);
      final command = await getCommand('result.$extension');
      request.response
        ..statusCode = HttpStatus.ok
        ..write(command)
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('')
        ..close();
    }
  }
}
