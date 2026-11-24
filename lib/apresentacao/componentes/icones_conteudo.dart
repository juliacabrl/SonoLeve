import 'package:flutter/material.dart';

/// Traduz o campo `icone` do catálogo (texto vindo do banco) em um ícone.
///
/// Mantém o catálogo independente do Flutter: o Firestore guarda apenas o nome
/// e o app decide como desenhá-lo. Nomes desconhecidos recebem um ícone neutro,
/// então um item novo no catálogo nunca quebra a tela.
abstract final class IconesConteudo {
  static IconData de(String nome) {
    switch (nome) {
      case 'chuva':
        return Icons.water_drop_outlined;
      case 'ondas':
        return Icons.waves;
      case 'vento':
        return Icons.air;
      case 'respiracao':
        return Icons.air;
      case 'lareira':
        return Icons.local_fire_department_outlined;
      case 'noite':
        return Icons.nights_stay_outlined;
      default:
        return Icons.music_note_outlined;
    }
  }
}
