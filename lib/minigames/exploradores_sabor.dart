import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class BoraEmpreender extends StatefulWidget {
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const BoraEmpreender({
    super.key,
    required this.aoConcluir,
    required this.voltar,
  });

  @override
  State<BoraEmpreender> createState() => _BoraEmpreenderState();
}

enum _EstadoMix { inicio, jogando, fim }

class _Fragmento {
  final int indice;
  final Color cor;
  final double ox;
  final double oy;
  final double vx;
  final double vy;
  final double tamanho;
  final double giro;

  const _Fragmento({
    required this.indice,
    required this.cor,
    required this.ox,
    required this.oy,
    required this.vx,
    required this.vy,
    required this.tamanho,
    required this.giro,
  });
}

class _BoraEmpreenderState extends State<BoraEmpreender>
    with TickerProviderStateMixin {
  static const int lado = 7;
  static const int total = lado * lado;

  static const icones = <IconData>[
    Icons.auto_awesome_rounded,
    Icons.devices_rounded,
    Icons.lightbulb_rounded,
    Icons.school_rounded,
    Icons.explore_rounded,
    Icons.workspace_premium_rounded,
  ];

  static const cores = <Color>[
    Color(0xFFFFCC70),
    Color(0xFF73CFFF),
    Color(0xFFD7A1FA),
    Color(0xFF77DFA9),
    Color(0xFFFF9B90),
    Color(0xFFA5B4FF),
  ];

  final foco = FocusNode();
  final random = math.Random();
  late final Timer relogio;
  late final AnimationController quebra;
  late final AnimationController queda;
  late final AnimationController estilhacos;
  late final AnimationController ambiente;

  late List<int> pecas;
  late List<int> especiais;
  List<double> origens = List<double>.generate(
    total, (i) => (i ~/ lado).toDouble(),
  );
  Set<int> quebrando = {};
  List<_Fragmento> fragmentos = [];
  List<int> dicaAtual = [];

  _EstadoMix estado = _EstadoMix.inicio;
  DateTime? fim;
  int tempo = 55;
  int xp = 0;
  int combinacoes = 0;
  int maiorCascata = 0;
  int dicas = 2;
  int embaralhamentos = 1;
  int cursor = 0;
  int? selecionado;
  bool resolvendo = false;
  Offset arraste = Offset.zero;
  String mensagem = 'FAÇA COMBINAÇÕES E DESCUBRA O ORANGO!';

  @override
  void initState() {
    super.initState();
    quebra = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    queda = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 410),
      value: 1,
    );
    estilhacos = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 770),
    );
    ambiente = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    gerarTabuleiro();
    relogio = Timer.periodic(
      const Duration(milliseconds: 170),
      (_) => atualizarRelogio(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) foco.requestFocus();
    });
  }

  @override
  void dispose() {
    relogio.cancel();
    quebra.dispose();
    queda.dispose();
    estilhacos.dispose();
    ambiente.dispose();
    foco.dispose();
    super.dispose();
  }

  void gerarTabuleiro() {
    int tentativas = 0;
    do {
      pecas = List<int>.filled(total, -1);
      especiais = List<int>.filled(total, 0);
      for (int i = 0; i < total; i++) {
        int valor;
        final linha = i ~/ lado;
        final coluna = i % lado;
        do {
          valor = random.nextInt(icones.length);
        } while ((coluna >= 2 &&
                pecas[i - 1] == valor &&
                pecas[i - 2] == valor) ||
            (linha >= 2 &&
                pecas[i - lado] == valor &&
                pecas[i - lado * 2] == valor));
        pecas[i] = valor;
      }
      tentativas++;
    } while (encontrarJogada() == null && tentativas < 100);
    origens = List<double>.generate(total, (i) => (i ~/ lado).toDouble());
    queda.value = 1;
  }

  void iniciar() {
    setState(() {
      estado = _EstadoMix.jogando;
      tempo = 55;
      xp = 0;
      combinacoes = 0;
      maiorCascata = 0;
      dicas = 2;
      embaralhamentos = 1;
      cursor = 0;
      selecionado = null;
      resolvendo = false;
      quebrando.clear();
      fragmentos.clear();
      dicaAtual.clear();
      mensagem = 'TROQUE DUAS PEÇAS E FORME 3 IGUAIS!';
      gerarTabuleiro();
      fim = DateTime.now().add(const Duration(seconds: 55));
    });
    foco.requestFocus();
  }

  void trocar(int a, int b) {
    final t = pecas[a];
    pecas[a] = pecas[b];
    pecas[b] = t;
    final e = especiais[a];
    especiais[a] = especiais[b];
    especiais[b] = e;
  }

  bool vizinhos(int a, int b) {
    return ((a ~/ lado) - (b ~/ lado)).abs() +
            ((a % lado) - (b % lado)).abs() ==
        1;
  }

  List<Set<int>> buscarGrupos() {
    final resultado = <Set<int>>[];
    for (int linha = 0; linha < lado; linha++) {
      int coluna = 0;
      while (coluna < lado) {
        final inicio = coluna;
        final tipo = pecas[linha * lado + coluna];
        while (coluna < lado && pecas[linha * lado + coluna] == tipo) {
          coluna++;
        }
        if (tipo >= 0 && coluna - inicio >= 3) {
          resultado.add({
            for (int c = inicio; c < coluna; c++) linha * lado + c,
          });
        }
      }
    }
    for (int coluna = 0; coluna < lado; coluna++) {
      int linha = 0;
      while (linha < lado) {
        final inicio = linha;
        final tipo = pecas[linha * lado + coluna];
        while (linha < lado && pecas[linha * lado + coluna] == tipo) {
          linha++;
        }
        if (tipo >= 0 && linha - inicio >= 3) {
          resultado.add({
            for (int l = inicio; l < linha; l++) l * lado + coluna,
          });
        }
      }
    }
    return resultado;
  }

  List<int>? encontrarJogada() {
    for (int i = 0; i < total; i++) {
      final proximos = <int>[];
      if (i % lado < lado - 1) proximos.add(i + 1);
      if (i ~/ lado < lado - 1) proximos.add(i + lado);
      for (final j in proximos) {
        trocar(i, j);
        final formaGrupo = buscarGrupos().isNotEmpty;
        trocar(i, j);
        if (formaGrupo) return [i, j];
      }
    }
    return null;
  }

  Set<int> expandirExplosoes(Set<int> iniciais) {
    final eliminadas = <int>{...iniciais};
    final fila = <int>[...iniciais];
    final vistas = <int>{};
    while (fila.isNotEmpty) {
      final i = fila.removeLast();
      if (!vistas.add(i)) continue;
      final extra = <int>{};
      if (especiais[i] == 1) {
        final linha = i ~/ lado;
        for (int c = 0; c < lado; c++) extra.add(linha * lado + c);
      } else if (especiais[i] == 2) {
        final linha = i ~/ lado;
        final coluna = i % lado;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final l = linha + dy;
            final c = coluna + dx;
            if (l >= 0 && l < lado && c >= 0 && c < lado) {
              extra.add(l * lado + c);
            }
          }
        }
      }
      for (final j in extra) {
        if (eliminadas.add(j)) fila.add(j);
      }
    }
    return eliminadas;
  }

  List<_Fragmento> criarFragmentos(Set<int> indices) {
    final lista = <_Fragmento>[];
    for (final indice in indices) {
      final cor = cores[pecas[indice]];
      for (int i = 0; i < 8; i++) {
        final angulo = random.nextDouble() * math.pi * 2;
        final forca = 0.8 + random.nextDouble() * 2.1;
        lista.add(_Fragmento(
          indice: indice,
          cor: Color.lerp(cor, Colors.white, random.nextDouble() * 0.35)!,
          ox: (random.nextDouble() - 0.5) * 0.65,
          oy: (random.nextDouble() - 0.5) * 0.65,
          vx: math.cos(angulo) * forca,
          vy: math.sin(angulo) * forca - 0.9,
          tamanho: 0.09 + random.nextDouble() * 0.15,
          giro: random.nextDouble() * math.pi * 2,
        ));
      }
    }
    return lista;
  }

  void aplicarGravidade(Set<int> removidos) {
    for (final i in removidos) {
      pecas[i] = -1;
      especiais[i] = 0;
    }
    final novasOrigens = List<double>.filled(total, 0);
    for (int coluna = 0; coluna < lado; coluna++) {
      final sobreviventes = <(int, int, int)>[];
      for (int linha = lado - 1; linha >= 0; linha--) {
        final i = linha * lado + coluna;
        if (pecas[i] >= 0) {
          sobreviventes.add((pecas[i], especiais[i], linha));
        }
      }
      int k = 0;
      int nascimento = 0;
      for (int linha = lado - 1; linha >= 0; linha--) {
        final i = linha * lado + coluna;
        if (k < sobreviventes.length) {
          final (tipo, poder, origem) = sobreviventes[k++];
          pecas[i] = tipo;
          especiais[i] = poder;
          novasOrigens[i] = origem.toDouble();
        } else {
          pecas[i] = random.nextInt(icones.length);
          especiais[i] = 0;
          novasOrigens[i] = (-1 - nascimento++).toDouble();
        }
      }
    }
    origens = novasOrigens;
  }

  Future<void> resolver(int destino, {Set<int>? poderes}) async {
    if (resolvendo) return;
    resolvendo = true;
    for (int cascata = 1; cascata <= 14; cascata++) {
      if (!mounted || estado != _EstadoMix.jogando) break;
      final grupos = buscarGrupos();
      final marcadas = <int>{...grupos.expand((g) => g)};
      if (cascata == 1 && poderes != null) marcadas.addAll(poderes);
      if (marcadas.isEmpty) break;

      int? manter;
      int novoPoder = 0;
      if (cascata == 1 && grupos.isNotEmpty) {
        final maior = grupos.reduce((a, b) => a.length >= b.length ? a : b);
        if (maior.length >= 4) {
          manter = maior.contains(destino) ? destino : maior.first;
          novoPoder = maior.length >= 5 ? 2 : 1;
        }
      }

      final destruidas = expandirExplosoes(marcadas);
      if (manter != null) destruidas.remove(manter);

      setState(() {
        combinacoes++;
        maiorCascata = math.max(maiorCascata, cascata);
        xp += destruidas.length * 25 * math.min(5, cascata);
        if (novoPoder == 2) {
          mensagem = 'SUPER BOMBA CRIADA!';
        } else if (novoPoder == 1) {
          mensagem = 'PODER DE LINHA DESBLOQUEADO!';
        } else if (cascata >= 3) {
          mensagem = 'MEGA CASCATA x$cascata!';
        } else if (cascata == 2) {
          mensagem = 'COMBO DUPLO!';
        } else {
          mensagem = 'QUEBROU! +${destruidas.length * 25} XP';
        }
        quebrando = destruidas;
        fragmentos = criarFragmentos(destruidas);
      });

      estilhacos.forward(from: 0);
      await quebra.forward(from: 0);
      if (!mounted || estado != _EstadoMix.jogando) break;

      setState(() {
        if (manter != null) especiais[manter] = novoPoder;
        aplicarGravidade(destruidas);
        quebrando = {};
      });
      await queda.forward(from: 0);
    }

    if (!mounted) return;
    setState(() {
      resolvendo = false;
      quebrando = {};
      if (estado == _EstadoMix.jogando) {
        if (buscarGrupos().isNotEmpty || encontrarJogada() == null) {
          gerarTabuleiro();
          mensagem = 'NOVAS PEÇAS, NOVAS DESCOBERTAS!';
        }
      }
    });
  }

  void selecionar(int indice) {
    if (estado != _EstadoMix.jogando || resolvendo) return;
    if (selecionado == null) {
      setState(() {
        selecionado = indice;
        cursor = indice;
      });
      return;
    }
    final primeira = selecionado!;
    if (primeira == indice) {
      setState(() => selecionado = null);
      return;
    }
    if (!vizinhos(primeira, indice)) {
      setState(() {
        selecionado = indice;
        cursor = indice;
      });
      return;
    }
    final primeiroPoder = especiais[primeira] > 0;
    final segundoPoder = especiais[indice] > 0;
    trocar(primeira, indice);
    final formaGrupo = buscarGrupos().isNotEmpty;
    if (!formaGrupo && !primeiroPoder && !segundoPoder) {
      trocar(primeira, indice);
      setState(() {
        selecionado = null;
        mensagem = 'TROQUE DUAS PEÇAS PARA FORMAR 3 IGUAIS!';
      });
      return;
    }
    final ativar = <int>{};
    if (primeiroPoder) ativar.add(indice);
    if (segundoPoder) ativar.add(primeira);
    setState(() {
      selecionado = null;
      dicaAtual = [];
      cursor = indice;
    });
    resolver(indice, poderes: ativar);
  }

  void dica() {
    if (estado != _EstadoMix.jogando || resolvendo || dicas <= 0) return;
    final jogada = encontrarJogada();
    if (jogada == null) {
      setState(gerarTabuleiro);
      return;
    }
    setState(() {
      dicas--;
      selecionado = null;
      dicaAtual = jogada;
      mensagem = 'TROQUE AS DUAS PEÇAS ILUMINADAS!';
    });
  }

  void embaralhar() {
    if (estado != _EstadoMix.jogando ||
        resolvendo ||
        embaralhamentos <= 0) return;
    setState(() {
      embaralhamentos--;
      selecionado = null;
      dicaAtual = [];
      gerarTabuleiro();
      mensagem = 'UM NOVO DESAFIO COMEÇOU!';
    });
  }

  void atualizarRelogio() {
    if (!mounted || estado != _EstadoMix.jogando || fim == null) return;
    final novo = math.max(0, (fim!.difference(DateTime.now()).inMilliseconds / 1000).ceil());
    if (novo == tempo) return;
    setState(() {
      tempo = novo;
      if (tempo <= 0) {
        estado = _EstadoMix.fim;
        selecionado = null;
      }
    });
  }

  KeyEventResult teclado(FocusNode node, KeyEvent evento) {
    if (evento is! KeyDownEvent) return KeyEventResult.ignored;
    final tecla = evento.logicalKey;
    if (tecla == LogicalKeyboardKey.escape) {
      widget.voltar();
      return KeyEventResult.handled;
    }
    if (estado == _EstadoMix.inicio) {
      if (tecla == LogicalKeyboardKey.enter || tecla == LogicalKeyboardKey.space) iniciar();
      return KeyEventResult.handled;
    }
    if (estado != _EstadoMix.jogando || resolvendo) return KeyEventResult.handled;
    int proximo = cursor;
    if (tecla == LogicalKeyboardKey.arrowLeft && cursor % lado > 0) {
      proximo--;
    } else if (tecla == LogicalKeyboardKey.arrowRight && cursor % lado < lado - 1) {
      proximo++;
    } else if (tecla == LogicalKeyboardKey.arrowUp && cursor >= lado) {
      proximo -= lado;
    } else if (tecla == LogicalKeyboardKey.arrowDown && cursor < total - lado) {
      proximo += lado;
    } else if (tecla == LogicalKeyboardKey.space || tecla == LogicalKeyboardKey.enter) {
      selecionar(cursor);
    } else if (tecla == LogicalKeyboardKey.keyH) {
      dica();
    } else if (tecla == LogicalKeyboardKey.keyR) {
      embaralhar();
    }
    if (proximo != cursor) setState(() => cursor = proximo);
    return KeyEventResult.handled;
  }

  Widget bloco(int indice, double tamanhoCelula) {
    return AnimatedBuilder(
      animation: Listenable.merge([quebra, queda]),
      builder: (context, _) {
        final tipo = pecas[indice];
        final cor = cores[tipo];
        final rachando = quebrando.contains(indice);
        final q = rachando ? quebra.value : 0.0;
        final rachadura = q.clamp(0.0, 1.0).toDouble();
        final sumir = rachando
            ? (1 - ((q - 0.60) / 0.30).clamp(0.0, 1.0)).toDouble()
            : 1.0;
        final escalaImpacto = rachando
            ? q < 0.45
                ? 1 + math.sin(q * math.pi / 0.45) * 0.075
                : 1 - ((q - 0.45) / 0.45).clamp(0.0, 1.0) * 0.35
            : 1.0;
        final linha = indice ~/ lado;
        final deslocamento = (origens[indice] - linha) *
            tamanhoCelula *
            (1 - Curves.easeOutBack.transform(queda.value));
        final tremida = rachando
            ? math.sin(q * math.pi * 18) * 3 * (1 - q)
            : 0.0;
        final selecionada = selecionado == indice;
        final sugerida = dicaAtual.contains(indice);
        final poder = especiais[indice];

        return Transform.translate(
          offset: Offset(tremida, deslocamento),
          child: Transform.scale(
            scale: escalaImpacto,
            child: Opacity(
              opacity: sumir,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => selecionar(indice),
                onPanStart: (_) => arraste = Offset.zero,
                onPanUpdate: (d) => arraste += d.delta,
                onPanEnd: (_) {
                  if (arraste.distance < 16) return;
                  final horizontal = arraste.dx.abs() > arraste.dy.abs();
                  int destino = indice;
                  if (horizontal) {
                    if (arraste.dx > 0 && indice % lado < lado - 1) destino++;
                    if (arraste.dx < 0 && indice % lado > 0) destino--;
                  } else {
                    if (arraste.dy > 0 && indice < total - lado) destino += lado;
                    if (arraste.dy < 0 && indice >= lado) destino -= lado;
                  }
                  if (destino != indice && !resolvendo) {
                    selecionado = indice;
                    selecionar(destino);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(cor, Colors.white, 0.16)!,
                        Color.lerp(cor, const Color(0xFF182944), 0.46)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionada
                          ? Colors.white
                          : sugerida
                              ? const Color(0xFFFFF29B)
                              : poder > 0
                                  ? const Color(0xFFFFE2A0)
                                  : cursor == indice
                                      ? const Color(0xFFCCEDFF)
                                      : cor.withValues(alpha: 0.60),
                      width: selecionada || sugerida || poder > 0 ? 3 : 1,
                    ),
                    boxShadow: selecionada || poder > 0
                        ? [
                            BoxShadow(
                              color: cor.withValues(alpha: 0.40),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Icon(
                          icones[tipo],
                          color: Colors.white,
                          size: tamanhoCelula * 0.34,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 7),
                          ],
                        ),
                      ),
                      if (poder > 0)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              poder == 1
                                  ? Icons.flash_on_rounded
                                  : Icons.brightness_7_rounded,
                              color: const Color(0xFFFFE79B),
                              size: tamanhoCelula * 0.23,
                            ),
                          ),
                        ),
                      if (rachando)
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _RachaduraPintor(rachadura, indice),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget informacao(IconData icone, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xE21D2B4C),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 19),
          const SizedBox(width: 5),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget painelLateral(bool esquerda) {
    return SizedBox(
      width: 185,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: esquerda
            ? [
                informacao(
                  Icons.stars_rounded,
                  '$combinacoes COMBOS',
                  const Color(0xFFFFD166),
                ),
                const SizedBox(height: 14),
                informacao(
                  Icons.local_fire_department_rounded,
                  'CASCATA x$maiorCascata',
                  const Color(0xFFFFA37F),
                ),
                const SizedBox(height: 25),
                const Text(
                  'QUEBRE, COMBINE E DESCUBRA NOVAS POSSIBILIDADES NO ORANGO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.6,
                  ),
                ),
              ]
            : [
                OutlinedButton.icon(
                  onPressed: estado == _EstadoMix.jogando && !resolvendo && dicas > 0
                      ? dica
                      : null,
                  icon: const Icon(Icons.lightbulb_rounded),
                  label: Text('DICA ($dicas)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD166),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: estado == _EstadoMix.jogando &&
                          !resolvendo &&
                          embaralhamentos > 0
                      ? embaralhar
                      : null,
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('EMBARALHAR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFAAD9FF),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  '4 IGUAIS: PODER DE LINHA\n5 IGUAIS: BOMBA\nCOMBOS: MAIS XP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
      ),
    );
  }

  Widget painelInicioFim(bool resultado) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xDF0B152B),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(27),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF503D7C), Color(0xFF1B2B49)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE0A5FF), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 30),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD166),
                    size: 66,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resultado ? 'COMBINAÇÕES CONCLUÍDAS!' : 'ORANGO MIX',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resultado ? '$xp XP' : 'QUEBRE OS BLOCOS!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    resultado
                        ? 'Você conquistou $combinacoes combinações e uma cascata máxima de x$maiorCascata.\n\nSua próxima descoberta pode acontecer na plataforma Orango por Senac. Conheça o site e saiba como se cadastrar!'
                        : 'Troque peças vizinhas para formar 3 ou mais ícones iguais.\n\nAgora os blocos racham, se quebram em fragmentos e outras peças caem para criar novas cascatas!\n\n4 peças: poder de linha. 5 ou mais: bomba especial.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: resultado
                          ? () => widget.aoConcluir(xp)
                          : iniciar,
                      icon: Icon(resultado
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(
                        resultado ? 'RECEBER XP' : 'INICIAR DESAFIO',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBA6D),
                        foregroundColor: const Color(0xFF24223F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: widget.voltar,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF181E3D),
      child: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: teclado,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: ambiente,
              builder: (context, _) => CustomPaint(
                painter: _FundoPintor(ambiente.value),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: widget.voltar,
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        const Text(
                          'ORANGO MIX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        informacao(
                          Icons.timer_rounded,
                          '${tempo}s',
                          const Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 8),
                        informacao(
                          Icons.bolt_rounded,
                          '$xp XP',
                          const Color(0xFFAAD8FF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 190),
                    child: Text(
                      mensagem,
                      key: ValueKey(mensagem),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final amplo = constraints.maxWidth >= 1090;
                        final espaco = constraints.maxWidth - (amplo ? 420 : 22);
                        final tamanho = math.max(
                          100.0,
                          math.min(constraints.maxHeight * 0.98, espaco),
                        ).toDouble();
                        final celula = (tamanho - 18) / lado;
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (amplo) ...[
                                painelLateral(true),
                                const SizedBox(width: 20),
                              ],
                              Container(
                                width: tamanho,
                                height: tamanho,
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: const Color(0xF01C294A),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFAC89D9),
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x704B3278),
                                      blurRadius: 27,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      GridView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        clipBehavior: Clip.none,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: lado,
                                        ),
                                        itemCount: total,
                                        itemBuilder: (context, i) => bloco(i, celula),
                                      ),
                                      AnimatedBuilder(
                                        animation: estilhacos,
                                        builder: (context, _) => IgnorePointer(
                                          child: CustomPaint(
                                            painter: _EstilhacosPintor(
                                              fragmentos,
                                              estilhacos.value,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (amplo) ...[
                                const SizedBox(width: 20),
                                painelLateral(false),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width < 1090)
                    Wrap(
                      spacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: estado == _EstadoMix.jogando && !resolvendo && dicas > 0
                              ? dica
                              : null,
                          icon: const Icon(Icons.lightbulb_rounded),
                          label: Text('DICA ($dicas)'),
                        ),
                        OutlinedButton.icon(
                          onPressed: estado == _EstadoMix.jogando &&
                                  !resolvendo && embaralhamentos > 0
                              ? embaralhar
                              : null,
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('EMBARALHAR'),
                        ),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'CLIQUE OU ARRASTE • FORME 3 OU MAIS • VEJA OS BLOCOS QUEBRAREM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (estado == _EstadoMix.inicio) painelInicioFim(false),
            if (estado == _EstadoMix.fim)
              _RecompensaMinigame(
                jogo: 'ORANGO MIX',
                pontos: xp,
                aoConcluir: widget.aoConcluir,
                voltar: widget.voltar,
              ),
          ],
        ),
      ),
    );
  }
}

class _RachaduraPintor extends CustomPainter {
  final double progresso;
  final int indice;
  const _RachaduraPintor(this.progresso, this.indice);

  @override
  void paint(Canvas canvas, Size size) {
    if (progresso <= 0.03 || progresso >= 0.91) return;
    final centro = Offset(size.width * 0.5, size.height * 0.5);
    final alcance = (progresso / 0.58).clamp(0.0, 1.0).toDouble();
    final path = Path();
    for (int i = 0; i < 7; i++) {
      final angulo = i * math.pi * 2 / 7 + indice * 0.32;
      final ponta = Offset(
        centro.dx + math.cos(angulo) * size.width * 0.65 * alcance,
        centro.dy + math.sin(angulo) * size.height * 0.65 * alcance,
      );
      final desvio = Offset(
        centro.dx + math.cos(angulo + 0.32) * size.width * 0.27 * alcance,
        centro.dy + math.sin(angulo + 0.32) * size.height * 0.27 * alcance,
      );
      path.moveTo(centro.dx, centro.dy);
      path.lineTo(desvio.dx, desvio.dy);
      path.lineTo(ponta.dx, ponta.dy);
      final bifurcacao = Offset(
        desvio.dx + math.cos(angulo - 0.62) * size.width * 0.19 * alcance,
        desvio.dy + math.sin(angulo - 0.62) * size.height * 0.19 * alcance,
      );
      path.moveTo(desvio.dx, desvio.dy);
      path.lineTo(bifurcacao.dx, bifurcacao.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF312949)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    final flash = ((progresso - 0.52) / 0.25).clamp(0.0, 1.0).toDouble();
    if (flash > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
        Paint()..color = Colors.white.withValues(alpha: 0.28 * (1 - flash)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RachaduraPintor old) =>
      old.progresso != progresso || old.indice != indice;
}

class _EstilhacosPintor extends CustomPainter {
  final List<_Fragmento> fragmentos;
  final double progresso;
  const _EstilhacosPintor(this.fragmentos, this.progresso);

  @override
  void paint(Canvas canvas, Size size) {
    if (fragmentos.isEmpty || progresso < 0.20) return;
    final celula = size.width / 7;
    final p = ((progresso - 0.20) / 0.80).clamp(0.0, 1.0).toDouble();
    final opacidade = (1.0 - p).clamp(0.0, 1.0).toDouble();
    for (final f in fragmentos) {
      final origem = Offset(
        ((f.indice % 7) + 0.5) * celula,
        ((f.indice ~/ 7) + 0.5) * celula,
      );
      final pos = origem + Offset(
        (f.ox + f.vx * p) * celula,
        (f.oy + f.vy * p + p * p * 1.7) * celula,
      );
      final r = f.tamanho * celula * (1 - p * 0.6);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.giro + p * 8);
      final triangulo = Path()
        ..moveTo(-r, -r * 0.8)
        ..lineTo(r, 0)
        ..lineTo(-r * 0.55, r)
        ..close();
      canvas.drawPath(
        triangulo,
        Paint()..color = f.cor.withValues(alpha: opacidade),
      );
      canvas.drawLine(
        Offset(-r, -r * 0.8),
        Offset(r, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: opacidade * 0.60)
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EstilhacosPintor old) =>
      old.progresso != progresso || old.fragmentos != fragmentos;
}

class _FundoPintor extends CustomPainter {
  final double tempo;
  const _FundoPintor(this.tempo);

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.5,
          colors: [
            Color(0xFF4A3A78),
            Color(0xFF282A52),
            Color(0xFF10172E),
          ],
        ).createShader(area),
    );
    final gerador = math.Random(28);
    const cores = [
      Color(0xFFFFD166),
      Color(0xFFD7A1FF),
      Color(0xFF85DAFF),
      Color(0xFF82E9BA),
    ];
    for (int i = 0; i < 42; i++) {
      final x = gerador.nextDouble() * size.width;
      final y = gerador.nextDouble() * size.height +
          math.sin(tempo * math.pi * 2 + i) * 17;
      canvas.drawCircle(
        Offset(x, y),
        3 + i % 4 * 2,
        Paint()
          ..color = cores[i % cores.length].withValues(alpha: 0.16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FundoPintor old) => old.tempo != tempo;
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
