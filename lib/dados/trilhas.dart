
import 'package:flutter/material.dart';

class Trilha {
  final String nome;
  final String area;
  final String descricao;
  final Color cor;
  final IconData icone;
  final Rect posicao;
  final List<String> temas;

  const Trilha({
    required this.nome,
    required this.area,
    required this.descricao,
    required this.cor,
    required this.icone,
    required this.posicao,
    required this.temas,
  });
}

const List<Trilha> trilhasOrango = [
  Trilha(
    nome: 'ORANGO RUSH',
    area: 'MISSÃO 01 • ACESSO GRATUITO',
    descricao:
        'Corra pela cidade do conhecimento, desvie dos obstáculos '
        'e colete emblemas. Descubra que o Orango é uma plataforma '
        'de cursos gratuitos do Senac.',
    cor: Color(0xFFFF974A),
    icone: Icons.directions_run_rounded,
    posicao: Rect.fromLTWH(90, 105, 245, 145),
    temas: [
      'Corrida arcade',
      'Reflexos e combos',
      'Cursos 100% gratuitos',
    ],
  ),
  Trilha(
    nome: 'ORANGO CONNECT',
    area: 'MISSÃO 02 • APRENDIZAGEM ONLINE',
    descricao:
        'Conecte dispositivos ao Portal Orango. Descubra uma '
        'plataforma de aprendizagem que você pode acessar pela '
        'internet, usando seu próprio dispositivo.',
    cor: Color(0xFF4FBCD9),
    icone: Icons.hub_rounded,
    posicao: Rect.fromLTWH(625, 105, 245, 145),
    temas: [
      'Circuitos interativos',
      'Conexão digital',
      'Aprendizagem online',
    ],
  ),
  Trilha(
    nome: 'ORANGO MIX',
    area: 'MISSÃO 03 • APRENDA DO SEU JEITO',
    descricao:
        'Combine possibilidades e conquiste pontos em cascata. '
        'No Orango, você pode explorar interesses diferentes '
        'e aprender no seu ritmo.',
    cor: Color(0xFFB77AF4),
    icone: Icons.auto_awesome_rounded,
    posicao: Rect.fromLTWH(90, 355, 245, 145),
    temas: [
      'Combinações',
      'Estratégia e combos',
      'Seu próprio ritmo',
    ],
  ),
  Trilha(
    nome: 'ORANGO PORTAL',
    area: 'MISSÃO 04 • CONQUISTE SEU CERTIFICADO',
    descricao:
        'Uma aventura de plataformas para reunir emblemas e '
        'ativar o portal. Conheça a possibilidade de receber '
        'um certificado gratuito ao concluir um curso no Orango.',
    cor: Color(0xFFFFC15E),
    icone: Icons.rocket_launch_rounded,
    posicao: Rect.fromLTWH(625, 355, 245, 145),
    temas: [
      'Aventura e exploração',
      'Quatro emblemas',
      'Certificado gratuito',
    ],
  ),
];
