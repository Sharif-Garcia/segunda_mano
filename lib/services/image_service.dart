import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Resultado de elegir o tomar fotos.
/// - [photos] vacío y [error] nulo significa que el usuario canceló.
/// - [error] con texto significa que falló o se negó el acceso.
class PickResult {
  final List<Uint8List> photos;
  final String? error;

  const PickResult({this.photos = const [], this.error});

  bool get cancelled => photos.isEmpty && error == null;
}

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Abre el selector de galería del sistema (Photo Picker en Android,
  /// PHPicker en iOS, selector de archivos en web). No pide permisos de
  /// almacenamiento. [remaining] es cuántas fotos más caben en la prenda.
  Future<PickResult> pickFromGallery(int remaining) async {
    if (remaining <= 0) {
      return const PickResult(error: 'Ya llegaste al máximo de fotos.');
    }
    try {
      final files = await _picker.pickMultiImage(imageQuality: 80);
      if (files.isEmpty) return const PickResult(); // el usuario canceló
      final selected = files.take(remaining);
      final photos = <Uint8List>[];
      for (final file in selected) {
        // Se leen los bytes para que funcione igual en las tres plataformas.
        photos.add(await file.readAsBytes());
      }
      return PickResult(photos: photos);
    } catch (_) {
      return const PickResult(
        error: 'No pudimos abrir la galería. Inténtalo de nuevo.',
      );
    }
  }

  /// Toma una foto con la cámara. Si el usuario deniega el permiso o la
  /// cámara no está disponible, devuelve un mensaje en lugar de bloquear la app.
  Future<PickResult> takePhoto(int remaining) async {
    if (remaining <= 0) {
      return const PickResult(error: 'Ya llegaste al máximo de fotos.');
    }
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (file == null) return const PickResult(); // el usuario canceló
      return PickResult(photos: [await file.readAsBytes()]);
    } catch (_) {
      return const PickResult(
        error:
            'No pudimos usar la cámara. Revisa que le diste permiso en los '
            'ajustes del dispositivo o del navegador. Mientras tanto, puedes '
            'elegir fotos de la galería.',
      );
    }
  }
}
