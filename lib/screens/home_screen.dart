import 'package:flutter/material.dart';

import '../models/garment.dart';
import 'publish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Garment> _garments = [];

  Future<void> _openPublish() async {
    final garment = await Navigator.of(
      context,
    ).push<Garment>(MaterialPageRoute(builder: (_) => const PublishScreen()));
    if (garment != null && mounted) {
      setState(() => _garments.insert(0, garment));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el color principal del tema para acentos
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor:
          Colors.grey.shade50, // Fondo sutil para resaltar las tarjetas
      appBar: AppBar(
        title: const Text(
          'SegundaMano',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _garments.isEmpty
          ? _buildEmptyState(primaryColor)
          : _buildGarmentsGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPublish,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Publicar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Extraído en un método para mantener el build limpio y estructurado
  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_rounded,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu catálogo está vacío',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Anímate a publicar tu primera prenda y dale una segunda vida a tu ropa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Implementación de un GridView moderno
  Widget _buildGarmentsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dos columnas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Relación de aspecto para tarjetas más altas
      ),
      itemCount: _garments.length,
      itemBuilder: (context, index) {
        final garment = _garments[index];
        return _GarmentCard(garment: garment);
      },
    );
  }
}

// Widget independiente para la tarjeta, mejora el rendimiento y limpieza del código
class _GarmentCard extends StatelessWidget {
  const _GarmentCard({required this.garment});

  final Garment garment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen ocupando la mayor parte de la tarjeta
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(garment.photos.first, fit: BoxFit.cover),
                  // Opcional: Un pequeño indicador si tiene múltiples fotos
                  if (garment.photos.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${garment.photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Detalles de la prenda
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garment.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Talla ${garment.size}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  garment.formattedPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
