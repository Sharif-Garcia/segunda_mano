import 'dart:typed_data';

class Garment {
  static const int maxPhotos = 5;

  final String id;
  final String name;
  final int price;
  final String size;
  final List<Uint8List> photos;

  Garment({
    required this.id,
    required this.name,
    required this.price,
    required this.size,
    required List<Uint8List> photos,
  }) : photos = List.unmodifiable(photos);

  static String? validate({
    required String name,
    required String priceText,
    required String size,
    required int photoCount,
  }) {
    if (name.trim().isEmpty) return 'Escribe el nombre de la prenda.';
    final price = int.tryParse(priceText.trim());
    if (price == null || price <= 0) {
      return 'Escribe un precio válido, mayor que cero.';
    }
    if (size.trim().isEmpty) return 'Escribe la talla.';
    if (photoCount == 0) return 'Agrega al menos una foto de la prenda.';
    if (photoCount > maxPhotos) {
      return 'Solo puedes publicar hasta $maxPhotos fotos.';
    }
    return null;
  }

  String get formattedPrice {
    final digits = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return '\$ $buffer';
  }
}
