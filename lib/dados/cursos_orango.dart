
import 'package:flutter/material.dart';

class CursoOrango {
  final String nome;
  final String descricao;
  final String duracao;
  final String url;

  const CursoOrango({
    required this.nome,
    required this.descricao,
    required this.duracao,
    required this.url,
  });
}

class TrilhaCursos {
  final String nome;
  final String area;
  final String mensagem;
  final IconData icone;
  final Color cor;
  final String categoriaUrl;
  final List<CursoOrango> cursos;

  const TrilhaCursos({
    required this.nome,
    required this.area,
    required this.mensagem,
    required this.icone,
    required this.cor,
    required this.categoriaUrl,
    required this.cursos,
  });
}

const List<TrilhaCursos> cursosOrango = [
  TrilhaCursos(
    nome: 'VIBE TECH',
    area: 'TECNOLOGIA',
    mensagem: 'Crie soluções e explore o universo digital.',
    icone: Icons.memory_rounded,
    cor: Color(0xFF5ABEFF),
    categoriaUrl:
        'https://orango.senac.br/categoria/tecnologia/',
    cursos: [
      CursoOrango(
        nome: 'Lógica de programação descomplicada',
        descricao: 'Algoritmos, lógica e resolução de problemas.',
        duracao: '10 horas',
        url:
            'https://orango.senac.br/inicio/cursos/logica-de-programacao-descomplicada/',
      ),
      CursoOrango(
        nome: 'Acelere com Cloud Computing',
        descricao: 'Descubra os fundamentos da computação em nuvem.',
        duracao: '16 horas',
        url:
            'https://orango.senac.br/inicio/cursos/acelere-com-cloud-computing/',
      ),
    ],
  ),
  TrilhaCursos(
    nome: 'LAB FASHION',
    area: 'MODA E CRIATIVIDADE',
    mensagem: 'Transforme ideias em combinações criativas.',
    icone: Icons.checkroom_rounded,
    cor: Color(0xFFDA89FF),
    categoriaUrl:
        'https://orango.senac.br/categoria/moda/',
    cursos: [
      CursoOrango(
        nome: 'Psicologia das cores na moda',
        descricao: 'Aprenda a combinar cores com criatividade.',
        duracao: '2 horas',
        url:
            'https://orango.senac.br/inicio/cursos/psicologia-das-cores-na-moda-dicas-rapidas-para-usar-e-combinar/',
      ),
      CursoOrango(
        nome: 'Multiplicando looks',
        descricao: 'Crie looks funcionais e versáteis.',
        duracao: '2 horas',
        url:
            'https://orango.senac.br/inicio/cursos/multiplicando-looks-a-criacao-de-looks-funcionais/',
      ),
    ],
  ),
  TrilhaCursos(
    nome: 'BORA EMPREENDER',
    area: 'EMPREENDEDORISMO',
    mensagem: 'Descubra novas possibilidades de negócio.',
    icone: Icons.storefront_rounded,
    cor: Color(0xFF60E5B0),
    categoriaUrl:
        'https://orango.senac.br/categoria/empreendedorismo/',
    cursos: [
      CursoOrango(
        nome: 'E-commerce e Dropshipping descomplicado',
        descricao: 'Conheça modelos de negócio digital.',
        duracao: '4 horas',
        url:
            'https://orango.senac.br/inicio/cursos/e-commerce-e-dropshipping-descomplicado/',
      ),
      CursoOrango(
        nome: 'Empreenda com propósito',
        descricao: 'Explore soluções sustentáveis na prática.',
        duracao: '4 horas',
        url:
            'https://orango.senac.br/inicio/cursos/empreenda-com-proposito-solucoes-sustentaveis-na-pratica/',
      ),
    ],
  ),
  TrilhaCursos(
    nome: 'EXPLORADORES DO SABOR',
    area: 'GASTRONOMIA',
    mensagem: 'Explore sabores, receitas e novas criações.',
    icone: Icons.restaurant_menu_rounded,
    cor: Color(0xFFFFB65F),
    categoriaUrl:
        'https://orango.senac.br/categoria/gastronomia/',
    cursos: [
      CursoOrango(
        nome: 'Técnicas de culinária para receitas rápidas',
        descricao: 'Organização e preparo de refeições práticas.',
        duracao: '4 horas',
        url:
            'https://orango.senac.br/inicio/cursos/tecnicas-culinarias-receitas-rapidas/',
      ),
      CursoOrango(
        nome: 'Sabores criativos',
        descricao: 'Transforme ingredientes comuns em novos pratos.',
        duracao: '4 horas',
        url:
            'https://orango.senac.br/inicio/cursos/sabores-criativos-a-arte-de-transformar-ingredientes-comuns/',
      ),
    ],
  ),
];
