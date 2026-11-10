
import 'package:flutter/material.dart';

class PersonagemModelo {
  final String id;
  final String nome;
  final String titulo;
  final Color roupa;
  final Color detalhe;
  final Color cabelo;
  final Color pele;
  final Color calca;
  final Color acessorio;
  final IconData simbolo;
  final int estiloCabelo;

  const PersonagemModelo({
    required this.id,
    required this.nome,
    required this.titulo,
    required this.roupa,
    required this.detalhe,
    required this.cabelo,
    required this.pele,
    required this.calca,
    required this.acessorio,
    required this.simbolo,
    required this.estiloCabelo,
  });
}

class PersonagensOrango {
  static const List<PersonagemModelo> opcoes = [
    PersonagemModelo(
      id: 'pixel',
      nome: 'PIXEL',
      titulo: 'Mestre da tecnologia',
      roupa: Color(0xFF3888F5),
      detalhe: Color(0xFF8AE6FF),
      cabelo: Color(0xFF29243D),
      pele: Color(0xFFE6AE78),
      calca: Color(0xFF303D68),
      acessorio: Color(0xFF64DDFF),
      simbolo: Icons.computer_rounded,
      estiloCabelo: 0,
    ),
    PersonagemModelo(
      id: 'faisca',
      nome: 'FAÍSCA',
      titulo: 'Energia e criatividade',
      roupa: Color(0xFFFF9138),
      detalhe: Color(0xFFFFD66E),
      cabelo: Color(0xFF6E3B2E),
      pele: Color(0xFFC78758),
      calca: Color(0xFF37465F),
      acessorio: Color(0xFFFFE16B),
      simbolo: Icons.bolt_rounded,
      estiloCabelo: 1,
    ),
    PersonagemModelo(
      id: 'brisa',
      nome: 'BRISA',
      titulo: 'Exploradora de ideias',
      roupa: Color(0xFF37B996),
      detalhe: Color(0xFFB7FAD7),
      cabelo: Color(0xFF453041),
      pele: Color(0xFFF0BC96),
      calca: Color(0xFF42536A),
      acessorio: Color(0xFF91F49B),
      simbolo: Icons.eco_rounded,
      estiloCabelo: 2,
    ),
    PersonagemModelo(
      id: 'turbo',
      nome: 'TURBO',
      titulo: 'Sempre em movimento',
      roupa: Color(0xFFA460E8),
      detalhe: Color(0xFFFF94D5),
      cabelo: Color(0xFF20263C),
      pele: Color(0xFFB77652),
      calca: Color(0xFF293754),
      acessorio: Color(0xFFFF8BB8),
      simbolo: Icons.rocket_launch_rounded,
      estiloCabelo: 3,
    ),
  ];

  static PersonagemModelo escolhido = opcoes[0];

  static String apelido = 'JOGADOR';
}
