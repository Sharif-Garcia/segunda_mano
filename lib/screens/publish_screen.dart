import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/garment.dart';
import '../services/image_service.dart';
import 'camera_screen.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _imageService = ImageService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final List<Uint8List> _photos = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _addFromGallery() async {
    final result = await _imageService.pickFromGallery(
      Garment.maxPhotos - _photos.length,
    );
    _handleResult(result);
  }

  Future<void> _addFromSystemCamera() async {
    final result = await _imageService.takePhoto(
      Garment.maxPhotos - _photos.length,
    );
    _handleResult(result);
  }

  Future<void> _addFromLiveCamera() async {
    final bytes = await Navigator.of(
      context,
    ).push<Uint8List>(MaterialPageRoute(builder: (_) => const CameraScreen()));
    if (!mounted || bytes == null) return;
    setState(() => _photos.add(bytes));
  }

  void _handleResult(PickResult result) {
    if (!mounted) return;
    if (result.error != null) {
      _showMessage(result.error!);
      return;
    }
    if (result.cancelled) return;
    setState(() => _photos.addAll(result.photos));
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _publish() {
    final error = Garment.validate(
      name: _nameController.text,
      priceText: _priceController.text,
      size: _sizeController.text,
      photoCount: _photos.length,
    );
    if (error != null) {
      _showMessage(error);
      return;
    }
    final garment = Garment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      size: _sizeController.text.trim(),
      photos: _photos,
    );
    Navigator.of(context).pop(garment);
  }

  // --- NUEVO: Modal Bottom Sheet para elegir origen de foto ---

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Añadir foto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Seleccionar imágenes existentes
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.photo_library_rounded),
                  ),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _addFromGallery();
                  },
                ),

                // En web, image_picker solicita una foto
                if (kIsWeb)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.photo_camera_rounded),
                    ),
                    title: const Text('Tomar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _addFromSystemCamera();
                    },
                  ),

                // En Android e iOS, cámara del sistema
                if (!kIsWeb)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.photo_camera_rounded),
                    ),
                    title: const Text('Cámara del sistema'),
                    onTap: () {
                      Navigator.pop(context);
                      _addFromSystemCamera();
                    },
                  ),

                // Cámara personalizada solo en móviles
                if (!kIsWeb)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.videocam_rounded),
                    ),
                    title: const Text('Cámara en vivo (interna)'),
                    onTap: () {
                      Navigator.pop(context);
                      _addFromLiveCamera();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = _photos.length < Garment.maxPhotos;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nueva Prenda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      // Mueve el botón principal abajo para que flote
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _publish,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Publicar prenda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN DE FOTOS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_photos.length}/${Garment.maxPhotos}',
                  style: TextStyle(
                    color: canAddMore ? theme.colorScheme.primary : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_photos.isEmpty)
              _buildEmptyPhotoState(theme)
            else
              _buildPhotoCarousel(canAddMore),

            const SizedBox(height: 32),

            // --- SECCIÓN DE DETALLES ---
            Text(
              'Detalles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildCustomTextField(
              controller: _nameController,
              label: '¿Qué estás vendiendo?',
              hint: 'Ej. Chaqueta de mezclilla vintage',
              icon: Icons.sell_outlined,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCustomTextField(
                    controller: _priceController,
                    label: 'Precio',
                    hint: '0',
                    prefixText: '\$ ',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildCustomTextField(
                    controller: _sizeController,
                    label: 'Talla',
                    hint: 'Ej. M',
                    icon: Icons.straighten_rounded,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),

            // Espacio extra para que el teclado no tape el último campo
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Widget: Estado vacío de fotos con estilo de borde punteado/sutil
  Widget _buildEmptyPhotoState(ThemeData theme) {
    return InkWell(
      onTap: _showPhotoOptions,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Toca para añadir fotos',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Añade hasta ${Garment.maxPhotos} fotos para mostrar los detalles',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Carrusel horizontal de fotos
  Widget _buildPhotoCarousel(bool canAddMore) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length + (canAddMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // Botón extra al final para seguir añadiendo fotos
          if (index == _photos.length) {
            return GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _photos[index],
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Indicador de foto principal
              if (index == 0)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Widget Helper para los TextField
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixText: prefixText,
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
