
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResultadoRanking {
  final String id;
  final String apelido;
  final String personagemId;
  final int pontos;
  final int trilhas;
  final int data;

  const ResultadoRanking({
    required this.id,
    required this.apelido,
    required this.personagemId,
    required this.pontos,
    required this.trilhas,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apelido': apelido,
      'personagemId': personagemId,
      'pontos': pontos,
      'trilhas': trilhas,
      'data': data,
    };
  }

  factory ResultadoRanking.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResultadoRanking(
      id: json['id'] as String? ?? '',
      apelido: json['apelido'] as String? ?? 'JOGADOR',
      personagemId:
          json['personagemId'] as String? ?? 'pixel',
      pontos: (json['pontos'] as num?)?.toInt() ?? 0,
      trilhas: (json['trilhas'] as num?)?.toInt() ?? 0,
      data: (json['data'] as num?)?.toInt() ?? 0,
    );
  }
}

class RankingOrango {
  static const String chave = 'orango_city_ranking_v1';

  final SharedPreferencesAsync preferencias =
      SharedPreferencesAsync();

  Future<List<ResultadoRanking>> carregar() async {
    final texto = await preferencias.getString(chave);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    final dados = jsonDecode(texto);

    if (dados is! List) {
      return [];
    }

    final resultados = <ResultadoRanking>[];

    for (final item in dados) {
      try {
        if (item is Map) {
          resultados.add(
            ResultadoRanking.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }

    resultados.sort(comparar);
    return resultados.take(10).toList();
  }

  int comparar(ResultadoRanking a, ResultadoRanking b) {
    final pontos = b.pontos.compareTo(a.pontos);

    if (pontos != 0) {
      return pontos;
    }

    return a.data.compareTo(b.data);
  }

  Future<bool> registrar(ResultadoRanking novo) async {
    final resultados = await carregar();

    resultados.add(novo);
    resultados.sort(comparar);

    final melhores = resultados.take(10).toList();

    await preferencias.setString(
      chave,
      jsonEncode(
        melhores.map((e) => e.toJson()).toList(),
      ),
    );

    return melhores.any((e) => e.id == novo.id);
  }

  Future<void> limpar() async {
    await preferencias.remove(chave);
  }
}
