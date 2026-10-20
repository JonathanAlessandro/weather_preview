import 'dart:typed_data';
import 'dart:ui';

/// Registra cada pose pela coleira, sem alterar a imagem original.
/// A coleira fica imóvel; somente a passada muda entre os quadros.
List<Offset> collarAnchors(Uint8List rgba, int width, int height) {
  final cellWidth = (width / 4).ceil();
  final cellHeight = (height / 4).ceil();
  return List.generate(16, (frame) {
    final sourceLeft = (frame % 4) * width / 4;
    final sourceTop = (frame ~/ 4) * height / 4;
    final left = sourceLeft.floor();
    final top = sourceTop.floor();
    double xTotal = 0;
    double yTotal = 0;
    var count = 0;
    for (var y = 0; y < cellHeight; y += 2) {
      for (var x = 0; x < cellWidth; x += 2) {
        final index = ((top + y) * width + left + x) * 4;
        final r = rgba[index];
        final g = rgba[index + 1];
        final b = rgba[index + 2];
        if (rgba[index + 3] > 128 && r > 60 && r > g * 1.7 && r > b * 1.4) {
          xTotal += x;
          yTotal += y;
          count++;
        }
      }
    }
    return count == 0
        ? Offset(cellWidth * .73, cellHeight * .45)
        : Offset(
            xTotal / count + left - sourceLeft,
            yTotal / count + top - sourceTop,
          );
  });
}
