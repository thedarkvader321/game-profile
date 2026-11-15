# GameTracker — Guía de setup

## 1. Prerrequisitos

| Herramienta | Versión mínima |
|-------------|----------------|
| Flutter | 3.10+ |
| Dart | 3.0+ |
| Firebase CLI | `npm i -g firebase-tools` |
| FlutterFire CLI | `dart pub global activate flutterfire_cli` |

---

## 2. Conectar Firebase (proyecto: `game-profile-4608f`)

```bash
# Inicia sesión en Firebase
firebase login

# Genera firebase_options.dart — sobreescribe el placeholder
flutterfire configure --project=game-profile-4608f
```

Esto genera `lib/firebase_options.dart` con las claves reales para
Android, iOS y Web. **No hagas commit de este archivo si el repo es público.**

---

## 3. Instalar dependencias

```bash
flutter pub get
```

---

## 4. Configurar plataformas

### Android
El `minSdk` ya está fijado en **21** en `android/app/build.gradle`.
Asegúrate de que `android/app/google-services.json` existe
(lo genera `flutterfire configure`).

### iOS
En `ios/Runner/Info.plist` ya están declaradas las claves de
permisos de galería y cámara.
Asegúrate de que `ios/Runner/GoogleService-Info.plist` existe
(lo genera `flutterfire configure`).

### Web
Firebase ya está configurado para web en `firebase_options.dart`.

---

## 5. Desplegar reglas de Firestore

```bash
firebase deploy --only firestore:rules
```

Regla clave: cada usuario solo puede leer/escribir
`users/{su_uid}` y `users/{su_uid}/juegos/*`.

---

## 6. Crear índice en Firestore (solo si aparece error de índice)

Si la consola Flutter muestra un error de índice faltante,
abre el enlace incluido en el error. El índice requerido es:

| Colección | Campo | Orden |
|-----------|-------|-------|
| `juegos` | `createdAt` | Descendente |

---

## 7. Ejecutar la app

```bash
flutter run
```

---

## 8. Modelo de datos (referencia)

```
users/{uid}
  displayName : string
  email       : string
  photoBase64 : string   ← avatar en base64
  createdAt   : timestamp
  updatedAt   : timestamp

users/{uid}/juegos/{gameId}
  nombre      : string
  categoria   : "to-play" | "in-progress" | "completed"
  imageBase64 : string   ← portada en base64
  createdAt   : timestamp
  updatedAt   : timestamp
```

---

## 9. Diseño del sistema (Design Tokens)

| Token | Valor |
|-------|-------|
| Background | `#080C18` |
| Surface | `#131A2E` |
| Primary | `#4A7DFF` |
| Jugando | `#F59E0B` (amber) |
| Pendientes | `#8B5CF6` (purple) |
| Completado | `#10B981` (emerald) |
| Fuente display | Orbitron (Google Fonts) |
| Fuente body | Nunito Sans (Google Fonts) |
