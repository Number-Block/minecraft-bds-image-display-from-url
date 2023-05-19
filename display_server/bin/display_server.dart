import 'dart:convert';
import 'dart:io';

import 'package:display_server/display_server.dart';

void main() async {
  Map<String, String> envVars = Platform.environment;

  final host = InternetAddress.loopbackIPv4;
  final port = int.parse(envVars['MINECRAFT_DISPLAY_PORT'] ?? '8080');

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
      final colors = await getColors('result.$extension');
      request.response
        ..statusCode = HttpStatus.ok
        ..write(colors)
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('')
        ..close();
    }
  }
}
