SegundaMano

Aplicación móvil hecha con Flutter para crear y consultar un catálogo de prendas de segunda mano. Permite publicar prendas con nombre, precio, talla y hasta cinco fotografías tomadas con la cámara o seleccionadas de la galería.

## Funcionalidades

- Catálogo de prendas en una cuadrícula de tarjetas.
- Formulario de publicación con nombre, precio, talla y fotos.
- Hasta cinco imágenes por prenda, con opción de quitarlas antes de publicar.
- Captura en vivo y selección de imágenes del sistema.
- Validación de campos obligatorios, precio positivo y al menos una foto.
- Interfaz en español basada en Material 3.

## Requisitos

- Flutter instalado y configurado para la plataforma de destino.
- Dart compatible con la restricción del proyecto (`^3.12.2`).
- Android Studio, Xcode o un navegador, según el destino elegido.

## Cómo ejecutar

Desde la raíz del proyecto:

```bash
flutter pub get
flutter run
```

Para elegir un dispositivo disponible:

```bash
flutter devices
flutter run -d <id-del-dispositivo>
```

## Plataformas y permisos

El proyecto incluye carpetas para Android, iOS y web. La selección de imágenes usa `image_picker`. La captura en vivo se implementa con `camera` (en particular, para web, donde el selector de imágenes abre un selector de archivos). En otras plataformas, el selector del sistema puede ofrecer la cámara.

En un dispositivo físico, concede acceso a la cámara cuando el sistema lo solicite. Si la cámara no está disponible o no se concede el permiso, la app muestra un mensaje y permite usar la galería.

## Estructura principal

```text
lib/
├── main.dart                 # Configuración de la app y tema
├── models/
│   └── garment.dart          # Modelo y validación de prendas
├── screens/
│   ├── home_screen.dart      # Catálogo principal
│   ├── publish_screen.dart   # Formulario de publicación
│   └── camera_screen.dart    # Vista previa y captura en vivo
└── services/
    └── image_service.dart    # Selección de fotos y captura del sistema
```

## Dependencias principales

- [`image_picker`](https://pub.dev/packages/image_picker): selección de fotos y captura con la cámara del sistema.
- [`camera`](https://pub.dev/packages/camera): vista previa y captura en vivo.
- Flutter y Material 3: interfaz y ejecución multiplataforma.

## Alcance actual

Las prendas se guardan en memoria mientras la aplicación está abierta. El proyecto aún no incluye persistencia local o en la nube, cuentas de usuario, backend ni flujo de compra.
