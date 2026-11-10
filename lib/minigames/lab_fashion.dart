import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class LabFashion extends StatefulWidget {
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const LabFashion({
    super.key,
    required this.aoConcluir,
    required this.voltar,
  });

  @override
  State<LabFashion> createState() => _LabFashionState();
}

class _FaseRede {
  final String titulo;
  final String missao;
  final List<List<int>> rotas;
  final List<int> reles;
  final List<int> saidas;
  final List<int> bloqueios;

  const _FaseRede({
    required this.titulo,
    required this.missao,
    required this.rotas,
    required this.reles,
    required this.saidas,
    required this.bloqueios,
  });
}

class _PecaRede {
  final int mascaraBase;
  final bool bloqueada;
  final bool principal;
  final bool origem;
  final bool saida;
  final bool rele;
  int giros;

  _PecaRede({
    required this.mascaraBase,
    required this.bloqueada,
    required this.principal,
    required this.origem,
    required this.saida,
    required this.rele,
    required this.giros,
  });

  int get mascara {
    int resultado = mascaraBase;

    for (int i = 0; i < giros % 4; i++) {
      resultado = ((resultado << 1) | (resultado >> 3)) & 15;
    }

    return resultado;
  }

  bool get fixa => bloqueada || origem || saida;
}

enum _SituacaoRede { abertura, jogando, encerrado }

class _LabFashionState extends State<LabFashion>
    with SingleTickerProviderStateMixin {
  static const int colunas = 7;
  static const int linhas = 5;
  static const int origem = 14;

  static const List<_FaseRede> fases = [
    _FaseRede(
      titulo: 'PRIMEIRA CONEXÃO',
      missao: 'Conecte o celular à plataforma Orango.',
      rotas: [
        [14, 15, 16, 17, 18, 19, 20],
      ],
      reles: [],
      saidas: [20],
      bloqueios: [0, 6, 28, 34],
    ),
    _FaseRede(
      titulo: 'SINAL ONLINE',
      missao: 'Faça a energia passar pelo relé ONLINE.',
      rotas: [
        [14, 15, 8, 9, 10, 17, 18, 19, 20],
      ],
      reles: [9],
      saidas: [20],
      bloqueios: [0, 4, 28, 34],
    ),
    _FaseRede(
      titulo: 'REDE INTELIGENTE',
      missao: 'Ative dois relés desviando dos firewalls.',
      rotas: [
        [14, 15, 22, 29, 30, 31, 24, 17, 18, 19, 20],
      ],
      reles: [29, 24],
      saidas: [20],
      bloqueios: [2, 4, 10, 12, 34],
    ),
    _FaseRede(
      titulo: 'CAMINHO AVANÇADO',
      missao: 'Conecte uma rota longa, com dois relés.',
      rotas: [
        [14, 15, 8, 9, 10, 11, 18, 25, 26, 27, 20],
      ],
      reles: [9, 25],
      saidas: [20],
      bloqueios: [0, 3, 5, 21, 28, 34],
    ),
    _FaseRede(
      titulo: 'CONEXÃO TOTAL',
      missao: 'Divida o sinal e alimente DOIS portais Orango!',
      rotas: [
        [14, 15, 16, 17, 18, 19, 20],
        [14, 15, 16, 17, 24, 31, 32, 33, 34],
      ],
      reles: [19, 33],
      saidas: [20, 34],
      bloqueios: [0, 6, 13, 28, 29],
    ),
  ];

  final FocusNode foco = FocusNode();
  final math.Random sorteio = math.Random();
  final List<_PecaRede> pecas = [];
  final Map<int, int> solucao = {};

  late final AnimationController brilho;
  late final Timer relogio;

  _SituacaoRede situacao = _SituacaoRede.abertura;
  DateTime? limite;

  int fase = 0;
  int segundos = 170;
  int pontos = 0;
  int dicas = 5;
  int movimentos = 0;
  int concluidas = 0;
  int cursor = origem;

  bool transicao = false;

  String aviso = 'RESTABELEÇA A CONEXÃO COM O ORANGO';

  _FaseRede get atual => fases[fase];

  @override
  void initState() {
    super.initState();

    brilho = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();

    prepararFase();

    relogio = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => atualizarTempo(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) foco.requestFocus();
    });
  }

  @override
  void dispose() {
    relogio.cancel();
    brilho.dispose();
    foco.dispose();
    super.dispose();
  }

  int direcao(int a, int b) {
    if (b == a - colunas) return 0;
    if (b == a + colunas) return 2;

    if (a ~/ colunas == b ~/ colunas) {
      if (b == a + 1) return 1;
      if (b == a - 1) return 3;
    }

    throw StateError('Caminho não adjacente: $a, $b');
  }

  void prepararFase() {
    solucao.clear();
    pecas.clear();

    for (final rota in atual.rotas) {
      for (int i = 0; i < rota.length; i++) {
        final indice = rota[i];

        int mascara = solucao[indice] ?? 0;

        mascara |= i == 0
            ? 8
            : 1 << direcao(indice, rota[i - 1]);

        mascara |= i == rota.length - 1
            ? 2
            : 1 << direcao(indice, rota[i + 1]);

        solucao[indice] = mascara;
      }
    }

    const bases = [3, 5, 6, 9, 10, 12, 7, 11, 13, 14];

    for (int i = 0; i < colunas * linhas; i++) {
      final bloqueada = atual.bloqueios.contains(i);
      final principal = solucao.containsKey(i);
      final fixa =
          bloqueada || i == origem || atual.saidas.contains(i);

      pecas.add(
        _PecaRede(
          mascaraBase: bloqueada
              ? 0
              : principal
                  ? solucao[i]!
                  : bases[sorteio.nextInt(bases.length)],
          bloqueada: bloqueada,
          principal: principal,
          origem: i == origem,
          saida: atual.saidas.contains(i),
          rele: atual.reles.contains(i),
          giros: fixa ? 0 : sorteio.nextInt(4),
        ),
      );
    }

    if (vitoria()) {
      final indice = atual.rotas.first.firstWhere(
        (i) => !pecas[i].fixa,
      );

      pecas[indice].giros++;
    }

    movimentos = 0;
    cursor = origem;
    transicao = false;
    aviso = atual.missao;
  }

  void iniciar() {
    setState(() {
      fase = 0;
      segundos = 170;
      pontos = 0;
      dicas = 5;
      movimentos = 0;
      concluidas = 0;

      situacao = _SituacaoRede.jogando;

      limite = DateTime.now().add(
        const Duration(seconds: 170),
      );

      prepararFase();
    });

    foco.requestFocus();
  }

  Set<int> energizadas() {
    if ((pecas[origem].mascara & 8) == 0) return {};

    final visitadas = <int>{origem};
    final fila = <int>[origem];

    const deslocamentos = [
      [-1, 0],
      [0, 1],
      [1, 0],
      [0, -1],
    ];

    while (fila.isNotEmpty) {
      final indice = fila.removeLast();
      final linha = indice ~/ colunas;
      final coluna = indice % colunas;

      for (int d = 0; d < 4; d++) {
        if ((pecas[indice].mascara & (1 << d)) == 0) {
          continue;
        }

        final nl = linha + deslocamentos[d][0];
        final nc = coluna + deslocamentos[d][1];

        if (nl < 0 ||
            nl >= linhas ||
            nc < 0 ||
            nc >= colunas) {
          continue;
        }

        final vizinho = nl * colunas + nc;

        if (pecas[vizinho].bloqueada) continue;

        if ((pecas[vizinho].mascara &
                (1 << ((d + 2) % 4))) ==
            0) {
          continue;
        }

        if (visitadas.add(vizinho)) {
          fila.add(vizinho);
        }
      }
    }

    return visitadas;
  }

  bool vitoria() {
    final energia = energizadas();

    for (final rele in atual.reles) {
      if (!energia.contains(rele)) return false;
    }

    for (final saida in atual.saidas) {
      if (!energia.contains(saida)) return false;

      if ((pecas[saida].mascara & 2) == 0) {
        return false;
      }
    }

    return true;
  }

  void concluirFase() {
    if (transicao ||
        situacao != _SituacaoRede.jogando) {
      return;
    }

    transicao = true;
    concluidas++;

    final ganho =
        260 + math.max(0, 65 - movimentos) * 3;

    pontos += ganho;
    aviso = 'CONEXÃO ATIVADA! +$ganho XP';

    limite = limite?.add(
      const Duration(seconds: 9),
    );

    Future.delayed(
      const Duration(milliseconds: 1050),
      () {
        if (!mounted ||
            situacao != _SituacaoRede.jogando) {
          return;
        }

        setState(() {
          if (fase < fases.length - 1) {
            fase++;

            if (fase == 2 || fase == 4) {
              dicas++;
            }

            prepararFase();
          } else {
            pontos += segundos * 3;
            situacao = _SituacaoRede.encerrado;
            transicao = false;
            aviso = 'O ORANGO ESTÁ CONECTADO!';
          }
        });
      },
    );
  }

  void girar(int indice) {
    if (situacao != _SituacaoRede.jogando ||
        transicao ||
        pecas[indice].fixa) {
      return;
    }

    setState(() {
      pecas[indice].giros++;
      cursor = indice;
      movimentos++;

      if (vitoria()) {
        concluirFase();
      }
    });
  }

  void dica() {
    if (situacao != _SituacaoRede.jogando ||
        transicao ||
        dicas <= 0) {
      return;
    }

    for (final rota in atual.rotas) {
      for (final indice in rota) {
        final peca = pecas[indice];

        if (peca.fixa ||
            peca.mascara == solucao[indice]) {
          continue;
        }

        setState(() {
          dicas--;
          cursor = indice;

          for (int i = 0; i < 4; i++) {
            if (peca.mascara == solucao[indice]) {
              break;
            }

            peca.giros++;
          }

          aviso = 'UMA CONEXÃO FOI CORRIGIDA!';

          if (vitoria()) {
            concluirFase();
          }
        });

        return;
      }
    }

    setState(() {
      aviso = 'OS FIOS DA ROTA ESTÃO CORRETOS!';
    });
  }

  void atualizarTempo() {
    if (!mounted ||
        situacao != _SituacaoRede.jogando ||
        limite == null) {
      return;
    }

    if (transicao) return;

    final novo = math.max(
      0,
      (limite!
                  .difference(DateTime.now())
                  .inMilliseconds /
              1000)
          .ceil(),
    );

    if (novo == segundos) return;

    setState(() {
      segundos = novo;

      if (segundos == 0) {
        situacao = _SituacaoRede.encerrado;
        aviso = 'TEMPO ESGOTADO!';
      }
    });
  }

  KeyEventResult teclado(
    FocusNode node,
    KeyEvent evento,
  ) {
    if (evento is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final tecla = evento.logicalKey;

    if (tecla == LogicalKeyboardKey.escape) {
      widget.voltar();
      return KeyEventResult.handled;
    }

    if (situacao == _SituacaoRede.abertura) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space) {
        iniciar();
      }

      return KeyEventResult.handled;
    }

    if (situacao != _SituacaoRede.jogando) {
      return KeyEventResult.handled;
    }

    int novo = cursor;

    if (tecla == LogicalKeyboardKey.arrowLeft &&
        cursor % colunas > 0) {
      novo--;
    } else if (tecla == LogicalKeyboardKey.arrowRight &&
        cursor % colunas < colunas - 1) {
      novo++;
    } else if (tecla == LogicalKeyboardKey.arrowUp &&
        cursor >= colunas) {
      novo -= colunas;
    } else if (tecla == LogicalKeyboardKey.arrowDown &&
        cursor < colunas * (linhas - 1)) {
      novo += colunas;
    } else if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.space) {
      girar(cursor);
      return KeyEventResult.handled;
    } else if (tecla == LogicalKeyboardKey.keyH) {
      dica();
      return KeyEventResult.handled;
    }

    if (novo != cursor) {
      setState(() => cursor = novo);
    }

    return KeyEventResult.handled;
  }

  Widget indicador(
    IconData icone,
    String titulo,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xDD142641),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            color: cor,
            size: 20,
          ),
          const SizedBox(width: 7),
          Text(
            titulo,
            style: TextStyle(
              color: cor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget cartaLateral(
    bool origemLado,
    Set<int> iluminadas,
  ) {
    final completos =
        atual.saidas.where(iluminadas.contains).length;

    return SizedBox(
      width: 166,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: const Color(0xFF182E4C),
              shape: BoxShape.circle,
              border: Border.all(
                color: origemLado ||
                        completos == atual.saidas.length
                    ? const Color(0xFF78F4D8)
                    : const Color(0xFF8191B1),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x5575EED8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(
              origemLado
                  ? Icons.smartphone_rounded
                  : Icons.auto_awesome_rounded,
              color: const Color(0xFFFFD166),
              size: 48,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            origemLado ? 'DISPOSITIVO' : 'PLATAFORMA',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            origemLado
                ? 'FONTE DE ENERGIA'
                : '$completos/${atual.saidas.length} SAÍDAS',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget pecaVisual(
    int indice,
    Set<int> iluminadas,
  ) {
    final peca = pecas[indice];
    final acesa = iluminadas.contains(indice);
    final selecionada = indice == cursor;

    final cor = acesa
        ? const Color(0xFF8AFFF0)
        : peca.principal && fase == 0
            ? const Color(0xFFFFC777)
            : const Color(0xFF8EA6D3);

    return InkWell(
      onTap: () => girar(indice),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: peca.bloqueada
                ? [
                    const Color(0xFF1D233A),
                    const Color(0xFF202A42),
                  ]
                : acesa
                    ? [
                        const Color(0xFF286F7A),
                        const Color(0xFF1C3C5A),
                      ]
                    : [
                        const Color(0xFF263E63),
                        const Color(0xFF192B49),
                      ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: selecionada ? 2.7 : 1.3,
            color: selecionada
                ? const Color(0xFFFFD166)
                : acesa
                    ? const Color(0xFF79EEDB)
                    : Colors.white12,
          ),
          boxShadow: acesa
              ? const [
                  BoxShadow(
                    color: Color(0x5575F0DC),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: peca.bloqueada
            ? const Center(
                child: Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF6F7790),
                  size: 27,
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedRotation(
                    turns: peca.giros / 4,
                    duration:
                        const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: CustomPaint(
                      painter: _FioNetwork(
                        mascara: peca.mascaraBase,
                        ligado: acesa,
                        cor: cor,
                        brilho: brilho,
                      ),
                    ),
                  ),
                  if (peca.origem ||
                      peca.saida ||
                      peca.rele)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: peca.origem
                              ? const Color(0xFFFFBF69)
                              : acesa
                                  ? const Color(0xFF8DFBE4)
                                  : const Color(0xFF344F75),
                          border: Border.all(
                            color: Colors.white70,
                            width: 1.3,
                          ),
                        ),
                        child: Icon(
                          peca.origem
                              ? Icons.bolt_rounded
                              : peca.saida
                                  ? Icons.flag_rounded
                                  : Icons.diamond_rounded,
                          size: 21,
                          color: peca.origem || acesa
                              ? const Color(0xFF162B42)
                              : const Color(0xFFFFE096),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget painel(bool fim) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xDD09152B),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              constraints:
                  const BoxConstraints(maxWidth: 510),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF334F77),
                    Color(0xFF152741),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF8CF2E0),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fim
                        ? Icons.emoji_events_rounded
                        : Icons.hub_rounded,
                    color: const Color(0xFFFFD166),
                    size: 64,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    fim
                        ? 'CONEXÃO ENCERRADA!'
                        : 'ORANGO NETWORK',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fim
                        ? '$pontos XP'
                        : 'REATIVE A REDE DO CONHECIMENTO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fim
                        ? 'Você concluiu $concluidas de 5 missões!\n\n'
                          'O Orango por Senac é uma plataforma de '
                          'aprendizagem online gratuita. '
                          'Sua próxima missão é acessar '
                          'orango.senac.br e conhecer o cadastro.'
                        : 'Você é responsável por conectar '
                          'dispositivos ao Orango!\n\n'
                          'Clique nos fios para girar. Leve a energia '
                          'da fonte até todos os portais e passe '
                          'pelos relés (diamantes). '
                          'Evite os firewalls.\n\n'
                          'Cada nova fase exige mais estratégia.\n\n'
                          'Mouse: girar • Setas: selecionar • '
                          'Enter: girar • H: dica.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 23),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: fim
                          ? () => widget.aoConcluir(pontos)
                          : iniciar,
                      icon: Icon(
                        fim
                            ? Icons.check_circle_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        fim
                            ? 'RECEBER XP E VOLTAR'
                            : 'INICIAR MISSÃO',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFFBF62),
                        foregroundColor:
                            const Color(0xFF172740),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: widget.voltar,
                    child: const Text(
                      'VOLTAR À CIDADE',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ligadas = energizadas();

    final relesAtivos =
        atual.reles.where(ligadas.contains).length;

    final saidasAtivas =
        atual.saidas.where(ligadas.contains).length;

    return Material(
      color: const Color(0xFF0C1D34),
      child: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: teclado,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FundoNetwork(brilho),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: widget.voltar,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'ORANGO NETWORK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        indicador(
                          Icons.layers_rounded,
                          '${fase + 1}/5',
                          const Color(0xFF8AF5E2),
                        ),
                        const SizedBox(width: 8),
                        indicador(
                          Icons.timer_rounded,
                          '${segundos}s',
                          segundos <= 30
                              ? const Color(0xFFFF839C)
                              : const Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 8),
                        indicador(
                          Icons.bolt_rounded,
                          '$pontos XP',
                          const Color(0xFF93D7FF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    atual.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFFFFD166),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    transicao ? aviso : atual.missao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final amplo =
                            constraints.maxWidth >= 1210;

                        final disponivel =
                            constraints.maxWidth -
                                (amplo ? 370 : 25);

                        final celula = math.min(
                          disponivel / colunas,
                          (constraints.maxHeight - 20) /
                              linhas,
                        ).toDouble();

                        final larguraTabuleiro =
                            celula * colunas;

                        final alturaTabuleiro =
                            celula * linhas;

                        return Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              if (amplo)
                                cartaLateral(
                                  true,
                                  ligadas,
                                ),
                              Container(
                                width: larguraTabuleiro + 12,
                                height: alturaTabuleiro + 12,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xE8152B48),
                                  borderRadius:
                                      BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        const Color(0xFF6F9CBC),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 25,
                                    ),
                                  ],
                                ),
                                child: GridView.builder(
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: colunas,
                                  ),
                                  itemCount: colunas * linhas,
                                  itemBuilder:
                                      (context, indice) =>
                                          pecaVisual(
                                    indice,
                                    ligadas,
                                  ),
                                ),
                              ),
                              if (amplo)
                                cartaLateral(
                                  false,
                                  ligadas,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      4,
                      15,
                      15,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      spacing: 14,
                      runSpacing: 9,
                      children: [
                        indicador(
                          Icons.diamond_rounded,
                          'RELÉS $relesAtivos/${atual.reles.length}',
                          const Color(0xFFFFD166),
                        ),
                        indicador(
                          Icons.flag_rounded,
                          'PORTAIS $saidasAtivas/${atual.saidas.length}',
                          const Color(0xFF8CF2D5),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              situacao == _SituacaoRede.jogando &&
                                      dicas > 0 &&
                                      !transicao
                                  ? dica
                                  : null,
                          icon: const Icon(
                            Icons.lightbulb_rounded,
                          ),
                          label: Text('DICA ($dicas)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFFFFD166),
                            side: const BorderSide(
                              color: Color(0xFFFFD166),
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const Text(
                          'CLIQUE PARA GIRAR • SETAS + ENTER',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (transicao)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: const Color(0x990A2035),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF8BFFE3),
                            size: 84,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'CONEXÃO ESTABELECIDA!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aviso,
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (situacao == _SituacaoRede.abertura)
              painel(false),
            if (situacao == _SituacaoRede.encerrado)
              _RecompensaMinigame(
                jogo: 'ORANGO NETWORK',
                pontos: pontos,
                aoConcluir: widget.aoConcluir,
                voltar: widget.voltar,
              ),
          ],
        ),
      ),
    );
  }
}

class _FioNetwork extends CustomPainter {
  final int mascara;
  final bool ligado;
  final Color cor;
  final Animation<double> brilho;

  _FioNetwork({
    required this.mascara,
    required this.ligado,
    required this.cor,
    required this.brilho,
  }) : super(repaint: brilho);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(
      size.width / 2,
      size.height / 2,
    );

    final espessura =
        math.min(size.width, size.height) * 0.13;

    const direcoes = [
      Offset(0, -1),
      Offset(1, 0),
      Offset(0, 1),
      Offset(-1, 0),
    ];

    for (int d = 0; d < 4; d++) {
      if ((mascara & (1 << d)) == 0) continue;

      final vetor = direcoes[d];

      final ponto = Offset(
        centro.dx + vetor.dx * size.width / 2,
        centro.dy + vetor.dy * size.height / 2,
      );

      canvas.drawLine(
        centro,
        ponto,
        Paint()
          ..color = cor.withValues(
            alpha: ligado ? 0.28 : 0.13,
          )
          ..strokeWidth = espessura * 2.5
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawLine(
        centro,
        ponto,
        Paint()
          ..color = cor
          ..strokeWidth = espessura
          ..strokeCap = StrokeCap.round,
      );

      if (ligado) {
        final p = (brilho.value + d * 0.17) % 1.0;

        final moving =
            Offset.lerp(centro, ponto, p)!;

        canvas.drawCircle(
          moving,
          espessura * 0.46,
          Paint()..color = Colors.white,
        );
      }
    }

    canvas.drawCircle(
      centro,
      espessura * 0.8,
      Paint()..color = cor,
    );

    canvas.drawCircle(
      centro,
      espessura * 0.30,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(
    covariant _FioNetwork old,
  ) {
    return old.mascara != mascara ||
        old.ligado != ligado ||
        old.cor != cor;
  }
}

class _FundoNetwork extends CustomPainter {
  final Animation<double> brilho;

  _FundoNetwork(this.brilho)
      : super(repaint: brilho);

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.4,
          colors: [
            Color(0xFF304C72),
            Color(0xFF192C49),
            Color(0xFF0C172B),
          ],
        ).createShader(area),
    );

    final linha = Paint()
      ..color = const Color(0x167DD2E9)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linha,
      );
    }

    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linha,
      );
    }

    final random = math.Random(21);

    for (int i = 0; i < 55; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final alpha = 0.13 +
          (math.sin(
                    brilho.value * 2 * math.pi + i,
                  ) +
                  1) *
              0.14;

      canvas.drawCircle(
        Offset(x, y),
        1.5 + i % 3,
        Paint()
          ..color = const Color(0xFF8CF9E9)
              .withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FundoNetwork old,
  ) {
    return true;
  }
}

class _RecompensaMinigame extends StatelessWidget {
  final String jogo;
  final int pontos;
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const _RecompensaMinigame({
    super.key,
    required this.jogo,
    required this.pontos,
    required this.aoConcluir,
    required this.voltar,
  });

  static const String site = 'https://orango.senac.br/';

  Future<void> _abrirOrango(BuildContext context) async {
    try {
      final abriu = await launchUrl(
        Uri.parse(site),
        mode: LaunchMode.externalApplication,
      );
      if (!abriu) throw StateError('Nao foi possivel abrir o site');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acesse orango.senac.br')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xF20B162C),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 490),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF344D71), Color(0xFF20223E)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFFFC56B),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD166),
                        size: 49,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'DESAFIO FINALIZADO!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        jogo.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFCED9E8),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$pontos XP',
                        style: const TextStyle(
                          color: Color(0xFFFFD166),
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C3550),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF89EABA)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.card_giftcard_rounded,
                              color: Color(0xFF94F0C0),
                              size: 36,
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'SUA RECOMPENSA ESTÁ NO ORANGO!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF94F0C0),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Explore cursos gratuitos e continue sua jornada.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: QrImageView(
                                data: site,
                                size: 174,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'orango.senac.br',
                              style: TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: () => _abrirOrango(context),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text(
                                  'CONHECER CURSOS GRATUITOS',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF91EABB),
                                  foregroundColor: const Color(0xFF183149),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: FilledButton.icon(
                          onPressed: () => aoConcluir(pontos),
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text(
                            'RECEBER XP E VOLTAR',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBD5B),
                            foregroundColor: const Color(0xFF192B45),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: voltar,
                        child: const Text(
                          'VOLTAR À CIDADE',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
