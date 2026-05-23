// Generuje ikonę 512x512 dla Google Play (z icon_1024.png).
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source = File('assets/branding/icon_1024.png');
  if (!source.existsSync()) {
    stderr.writeln('Brak assets/branding/icon_1024.png — odpal najpierw '
        '`dart run tool/generate_icon.dart`');
    exit(1);
  }
  final src = img.decodePng(source.readAsBytesSync())!;
  final resized = img.copyResize(
    src,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.cubic,
  );
  File('assets/branding/icon_512.png')
      .writeAsBytesSync(img.encodePng(resized));
  stdout.writeln('Wygenerowano assets/branding/icon_512.png');
}
