import 'package:cloud_firestore/cloud_firestore.dart';

enum GameCategory {
  all,
  inProgress,
  toPlay,
  completed;

  String get firestoreValue {
    switch (this) {
      case GameCategory.inProgress:
        return 'in-progress';
      case GameCategory.toPlay:
        return 'to-play';
      case GameCategory.completed:
        return 'completed';
      case GameCategory.all:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case GameCategory.all:
        return 'Todos';
      case GameCategory.inProgress:
        return 'Jugando';
      case GameCategory.toPlay:
        return 'Pendientes';
      case GameCategory.completed:
        return 'Completado';
    }
  }

  static GameCategory fromFirestore(String value) {
    switch (value) {
      case 'in-progress':
        return GameCategory.inProgress;
      case 'to-play':
        return GameCategory.toPlay;
      case 'completed':
        return GameCategory.completed;
      default:
        return GameCategory.toPlay;
    }
  }
}

class GameModel {
  final String id;
  final String nombre;
  final GameCategory categoria;
  final String imageBase64;
  final DateTime? createdAt;

  const GameModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.imageBase64 = '',
    this.createdAt,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GameModel(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      categoria: GameCategory.fromFirestore(d['categoria'] as String? ?? ''),
      imageBase64: d['imageBase64'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
