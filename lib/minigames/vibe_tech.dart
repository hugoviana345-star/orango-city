import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../dados/personagens.dart';

enum _TipoItem {
  barreira,
  drone,
  estrela,
  ima,
  turbo,
  escudo,
  sinal,
}

class _ItemRush {
  double x;
  final int pista;
  final _TipoItem tipo;
  bool removido = false;
  bool ultrapassado = false;

  _ItemRush(this.x, this.pista, this.tipo);
}

class _ParticulaRush {
  double x;
  double y;
  double vx;
  double vy;
  double vida = 1;
  final Color cor;

  _ParticulaRush(this.x, this.y, this.vx, this.vy, this.cor);
}

class VibeTech extends StatefulWidget {
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const VibeTech({
    super.key,
    required this.aoConcluir,
    required this.voltar,
  });

  @override
  State<VibeTech> createState() => _VibeTechState();
}

class _VibeTechState extends State<VibeTech>
    with SingleTickerProviderStateMixin {
  static const List<double> pistasY = [425, 530, 635];
  static const double tempoPartida = 55;
  static const List<String> descobertas = [
    'CURSOS GRATUITOS',
    'APRENDIZAGEM ONLINE',
    'APRENDA NO SEU RITMO',
    'CERTIFICADO AO CONCLUIR',
  ];

  final FocusNode foco = FocusNode();
  final math.Random sorteio = math.Random();
  final Set<LogicalKeyboardKey> teclas = {};
  final List<_ItemRush> itens = [];
  final List<_ParticulaRush> particulas = [];

  late final Ticker motor;
  Duration? ultimoFrame;

  bool iniciado = false;
  bool terminado = false;
  bool venceu = false;
  bool botaoDeslizar = false;

  int pista = 1;
  int vidas = 3;
  int pontos = 0;
  int combo = 0;
  int melhorCombo = 0;
  int estrelas = 0;
  int sinais = 0;
  int ondas = 0;

  double yPersonagem = pistasY[1];
  double salto = 0;
  double velocidadeSalto = 0;
  double mundo = 0;
  double tempo = tempoPartida;
  double proximaOnda = 0.9;
  double invencivel = 0;
  double ima = 0;
  double turbo = 0;
  double escudo = 0;
  double tremor = 0;
  double mensagemTempo = 0;
  double explosaoTela = 0;

  String mensagem = 'O PORTAL ORANGO ESTÁ À SUA ESPERA!';

  bool get deslizando =>
      salto == 0 &&
      (botaoDeslizar ||
          teclas.contains(LogicalKeyboardKey.controlLeft) ||
          teclas.contains(LogicalKeyboardKey.controlRight) ||
          teclas.contains(LogicalKeyboardKey.keyC));

  @override
  void initState() {
    super.initState();
    motor = createTicker(atualizar)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) foco.requestFocus();
    });
  }

  @override
  void dispose() {
    motor.dispose();
    foco.dispose();
    super.dispose();
  }

  void avisar(String texto) {
    mensagem = texto;
    mensagemTempo = 2.2;
  }

  void iniciar() {
    setState(() {
      iniciado = true;
      terminado = false;
      venceu = false;
      botaoDeslizar = false;
      pista = 1;
      yPersonagem = pistasY[1];
      vidas = 3;
      pontos = 0;
      combo = 0;
      melhorCombo = 0;
      estrelas = 0;
      sinais = 0;
      ondas = 0;
      salto = 0;
      velocidadeSalto = 0;
      mundo = 0;
      tempo = tempoPartida;
      proximaOnda = 0.95;
      invencivel = 0;
      ima = 0;
      turbo = 0;
      escudo = 0;
      tremor = 0;
      explosaoTela = 0;
      itens.clear();
      particulas.clear();
      teclas.clear();
      ultimoFrame = null;
      avisar('DESVIE, COLETE E DESCUBRA O ORANGO!');
    });
    foco.requestFocus();
  }

  void mudarPista(int delta) {
    if (!iniciado || terminado) return;
    setState(() {
      pista = (pista + delta).clamp(0, 2).toInt();
      soltarPoeira(212, yPersonagem, const Color(0xFF8EEBFF), 6);
    });
    foco.requestFocus();
  }

  void pular() {
    if (!iniciado || terminado || salto > 0 || deslizando) return;
    setState(() {
      velocidadeSalto = 790;
      salto = 0.01;
      soltarPoeira(225, yPersonagem, const Color(0xFFB6EEFF), 12);
    });
    foco.requestFocus();
  }

  void soltarPoeira(double x, double y, Color cor, int quantidade) {
    for (int i = 0; i < quantidade; i++) {
      final a = sorteio.nextDouble() * math.pi * 2;
      final forca = 65 + sorteio.nextDouble() * 210;
      particulas.add(
        _ParticulaRush(
          x,
          y,
          math.cos(a) * forca,
          math.sin(a) * forca,
          cor,
        ),
      );
    }
  }

  KeyEventResult teclado(FocusNode node, KeyEvent evento) {
    final tecla = evento.logicalKey;

    if (evento is KeyUpEvent) {
      teclas.remove(tecla);
      return KeyEventResult.handled;
    }

    if (evento is! KeyDownEvent) return KeyEventResult.ignored;

    if (tecla == LogicalKeyboardKey.escape) {
      widget.voltar();
      return KeyEventResult.handled;
    }

    if (!iniciado) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space) {
        iniciar();
      }
      return KeyEventResult.handled;
    }

    if (terminado) return KeyEventResult.handled;

    teclas.add(tecla);

    if (tecla == LogicalKeyboardKey.arrowUp ||
        tecla == LogicalKeyboardKey.keyW ||
        tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      mudarPista(-1);
    } else if (tecla == LogicalKeyboardKey.arrowDown ||
        tecla == LogicalKeyboardKey.keyS ||
        tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      mudarPista(1);
    } else if (tecla == LogicalKeyboardKey.space) {
      pular();
    }

    return KeyEventResult.handled;
  }

  void criarOnda() {
    ondas++;
    final dificuldade = 1 - tempo / tempoPartida;
    final bloqueada = sorteio.nextInt(3);
    final barreira = sorteio.nextDouble() < 0.65;

    itens.add(
      _ItemRush(
        1370,
        bloqueada,
        barreira ? _TipoItem.barreira : _TipoItem.drone,
      ),
    );

    final livres = [0, 1, 2]..remove(bloqueada);

    if (dificuldade > 0.44 && sorteio.nextDouble() < 0.26) {
      final outra = livres.removeAt(sorteio.nextInt(livres.length));
      itens.add(
        _ItemRush(1370, outra, _TipoItem.barreira),
      );
    }

    final premiada = livres[sorteio.nextInt(livres.length)];

    if (ondas % 5 == 0 && sinais < 4) {
      itens.add(_ItemRush(1420, premiada, _TipoItem.sinal));
    } else if (ondas % 8 == 0) {
      final poderes = [
        _TipoItem.ima,
        _TipoItem.turbo,
        _TipoItem.escudo,
      ];
      itens.add(
        _ItemRush(1410, premiada, poderes[sorteio.nextInt(3)]),
      );
    } else {
      itens.add(_ItemRush(1400, premiada, _TipoItem.estrela));
      if (ondas % 2 == 0) {
        itens.add(_ItemRush(1475, premiada, _TipoItem.estrela));
      }
    }
  }

  bool get perigoAtivo => invencivel <= 0;

  void dano(_ItemRush item) {
    item.removido = true;
    if (!perigoAtivo) return;

    tremor = 12;
    explosaoTela = 0.2;
    combo = 0;
    invencivel = 1.3;
    soltarPoeira(240, yPersonagem - 42, const Color(0xFFFF708D), 25);

    if (escudo > 0) {
      escudo = 0;
      avisar('O ESCUDO PROTEGEU VOCÊ!');
      return;
    }

    vidas--;
    avisar('QUASE! ESCOLHA OUTRA PISTA!');
    if (vidas <= 0) finalizar(false);
  }

  void coletar(_ItemRush item) {
    item.removido = true;
    final cy = pistasY[item.pista] - 77;

    switch (item.tipo) {
      case _TipoItem.estrela:
        estrelas++;
        combo++;
        melhorCombo = math.max(melhorCombo, combo);
        final multi = math.min(5, 1 + combo ~/ 4);
        pontos += 50 * multi * (turbo > 0 ? 2 : 1);
        if (combo % 5 == 0) avisar('SUPER COMBO x$multi!');
        soltarPoeira(item.x + 22, cy, const Color(0xFFFFD166), 15);
        break;
      case _TipoItem.sinal:
        if (sinais < 4) {
          sinais++;
          pontos += 200;
          avisar('ORANGO: ${descobertas[sinais - 1]}!');
          explosaoTela = 0.12;
          soltarPoeira(item.x + 22, cy, const Color(0xFFFFD166), 30);
        }
        break;
      case _TipoItem.ima:
        ima = 7;
        pontos += 80;
        avisar('ÍMÃ: ATRAIA ESTRELAS POR 7 SEGUNDOS!');
        soltarPoeira(item.x + 22, cy, const Color(0xFF73E4FF), 22);
        break;
      case _TipoItem.turbo:
        turbo = 6;
        pontos += 80;
        avisar('TURBO: XP DUPLICADO!');
        soltarPoeira(item.x + 22, cy, const Color(0xFFFFA963), 22);
        break;
      case _TipoItem.escudo:
        escudo = 1;
        pontos += 80;
        avisar('ESCUDO ATIVADO!');
        soltarPoeira(item.x + 22, cy, const Color(0xFF83F6C2), 22);
        break;
      default:
        break;
    }
  }

  void verificarItens() {
    for (final item in itens) {
      if (item.removido) continue;
      if (item.pista != pista) continue;

      final distancia = (item.x + 25 - 233).abs();
      final coleta = item.tipo.index >= _TipoItem.estrela.index;

      if (coleta) {
        if ((distancia < 53 && salto < 130) ||
            (ima > 0 && distancia < 195 &&
                (item.tipo == _TipoItem.estrela ||
                    item.tipo == _TipoItem.sinal))) {
          coletar(item);
        }
      } else if (distancia < 53 && invencivel <= 0) {
        if (item.tipo == _TipoItem.barreira && salto < 64) {
          dano(item);
        } else if (item.tipo == _TipoItem.drone &&
            !deslizando && salto < 120) {
          dano(item);
        }
      }
    }

    for (final item in itens) {
      if (item.removido || item.ultrapassado) continue;
      if (item.x < 170 && item.tipo.index < 2) {
        item.ultrapassado = true;
        pontos += 12;
      }
    }

    itens.removeWhere((e) => e.removido || e.x < -150);
  }

  void finalizar(bool sucesso) {
    if (terminado) return;
    terminado = true;
    venceu = sucesso;
    pontos += 100 + math.max(0, vidas) * 60 + sinais * 50;
    teclas.clear();
    botaoDeslizar = false;
    avisar('PORTAL ORANGO ENCONTRADO!');
  }

  void atualizar(Duration agora) {
    final anterior = ultimoFrame;
    ultimoFrame = agora;
    if (!mounted || anterior == null || !iniciado || terminado) return;

    final dt = ((agora - anterior).inMicroseconds / 1000000)
        .clamp(0.0, 0.034)
        .toDouble();
    if (dt <= 0) return;

    setState(() {
      tempo = math.max(0.0, tempo - dt);
      final dificuldade = 1 - tempo / tempoPartida;
      final velocidade = 460 + dificuldade * 220;
      mundo += velocidade * (turbo > 0 ? 1.25 : 1.0) * dt;
      proximaOnda -= dt;

      if (proximaOnda <= 0) {
        criarOnda();
        proximaOnda = 1.02 - dificuldade * 0.16 +
            sorteio.nextDouble() * 0.27;
      }

      yPersonagem += (pistasY[pista] - yPersonagem) *
          (1 - math.exp(-13 * dt));

      if (salto > 0 || velocidadeSalto > 0) {
        salto += velocidadeSalto * dt;
        velocidadeSalto -= 1950 * dt;
        if (salto <= 0) {
          salto = 0;
          velocidadeSalto = 0;
          soltarPoeira(222, yPersonagem, const Color(0xFF84DFFF), 8);
        }
      }

      invencivel = math.max(0.0, invencivel - dt);
      ima = math.max(0.0, ima - dt);
      turbo = math.max(0.0, turbo - dt);
      tremor = math.max(0.0, tremor - dt * 29);
      mensagemTempo = math.max(0.0, mensagemTempo - dt);
      explosaoTela = math.max(0.0, explosaoTela - dt);

      for (final item in itens) {
        item.x -= velocidade * (turbo > 0 ? 1.25 : 1) * dt;
      }

      for (final p in particulas) {
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.vy += 180 * dt;
        p.vida -= 1.8 * dt;
      }
      particulas.removeWhere((e) => e.vida <= 0);

      verificarItens();
      if (tempo <= 0 && !terminado) finalizar(true);
    });
  }

  Widget marcador(IconData icone, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xE3132041),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0x665EC8FF)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 12),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icone, color: cor, size: 19),
        const SizedBox(width: 6),
        Text(valor, style: TextStyle(
          color: cor, fontWeight: FontWeight.w900, fontSize: 14,
        )),
      ]),
    );
  }

  Widget controles() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _botao(Icons.keyboard_arrow_up_rounded, 'SUBIR', () => mudarPista(-1)),
        const SizedBox(width: 8),
        _botao(Icons.keyboard_arrow_down_rounded, 'DESCER', () => mudarPista(1)),
        const SizedBox(width: 8),
        _botao(Icons.arrow_upward_rounded, 'PULAR', pular, principal: true),
        const SizedBox(width: 8),
        Listener(
          onPointerDown: (_) => setState(() => botaoDeslizar = true),
          onPointerUp: (_) => setState(() => botaoDeslizar = false),
          onPointerCancel: (_) => setState(() => botaoDeslizar = false),
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF192B57),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF9DC7FF)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.south_rounded, color: Colors.white),
              SizedBox(width: 5),
              Text('DESLIZAR', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900,
                fontSize: 12,
              )),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _botao(
    IconData icone,
    String texto,
    VoidCallback acao, {
    bool principal = false,
  }) {
    return SizedBox(
      height: 49,
      child: FilledButton.icon(
        onPressed: acao,
        icon: Icon(icone, size: 20),
        label: Text(texto, style: const TextStyle(
          fontWeight: FontWeight.w900, fontSize: 12,
        )),
        style: FilledButton.styleFrom(
          backgroundColor: principal
              ? const Color(0xFFFFB34C)
              : const Color(0xFF5945AD),
          foregroundColor: principal
              ? const Color(0xFF1C2241)
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget telaInicioOuFim(bool resultado) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xE308112C),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF493C83), Color(0xFF182E55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: const Color(0xFFFFBC65), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x99000000), blurRadius: 32),
                  BoxShadow(color: Color(0x554F3FC8), blurRadius: 30),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bolt_rounded,
                    color: Color(0xFFFFCB68), size: 63),
                const SizedBox(height: 10),
                Text(resultado
                    ? (venceu ? 'PORTAL ORANGO ALCANÇADO!' : 'FIM DE PARTIDA!')
                    : 'ORANGO RUSH',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(resultado ? '$pontos XP' : 'CORRA. DESCUBRA. APRENDA.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: Color(0xFFFFCB68),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  resultado
                      ? 'Você encontrou $sinais de 4 descobertas do Orango, coletou $estrelas estrelas e alcançou combo $melhorCombo.\n\nO Orango por Senac reúne oportunidades de aprendizagem online. Acesse orango.senac.br para conhecer a plataforma e se cadastrar.'
                      : 'Corra pelas três pistas de uma cidade futurista. Desvie dos obstáculos e reúna quatro descobertas sobre a plataforma Orango.\n\nW/↑ ou A/←: subir pista\nS/↓ ou D/→: descer pista\nEspaço: pular barreiras\nCtrl ou C: deslizar sob drones',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15, color: Colors.white70, height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                for (int i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Icon(resultado && i < sinais
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                        color: resultado && i < sinais
                            ? const Color(0xFF84F3C3)
                            : const Color(0xFF7384A8),
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Text(descobertas[i], style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                    ]),
                  ),
                const SizedBox(height: 21),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: FilledButton.icon(
                    onPressed: resultado
                        ? () => widget.aoConcluir(pontos)
                        : iniciar,
                    icon: Icon(resultado
                        ? Icons.check_circle_rounded
                        : Icons.play_arrow_rounded),
                    label: Text(resultado
                        ? 'RECEBER XP E VOLTAR À CIDADE'
                        : 'INICIAR CORRIDA',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBF65),
                      foregroundColor: const Color(0xFF1B2342),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.voltar,
                  child: const Text('VOLTAR À CIDADE',
                    style: TextStyle(color: Colors.white70)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF11162E),
      child: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: teclado,
        child: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CenarioRush(
                mundo: mundo,
                tempoRestante: tempo,
                yPersonagem: yPersonagem,
                salto: salto,
                deslizando: deslizando,
                invencivel: invencivel,
                ima: ima,
                turbo: turbo,
                escudo: escudo,
                tremor: tremor,
                flash: explosaoTela,
                itens: itens,
                particulas: particulas,
                roupa: PersonagensOrango.escolhido.roupa,
                pele: PersonagensOrango.escolhido.pele,
                cabelo: PersonagensOrango.escolhido.cabelo,
              ),
            ),
          ),
          SafeArea(child: LayoutBuilder(builder: (context, constraints) {
            final compacto = constraints.maxWidth < 950;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xE31A2546),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      tooltip: 'Voltar à cidade',
                      onPressed: widget.voltar,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text('ORANGO RUSH', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: compacto ? 18 : 24,
                  )),
                  const Spacer(),
                  marcador(Icons.timer_rounded, '${tempo.ceil()}s',
                      const Color(0xFF87F4E1)),
                  const SizedBox(width: 7),
                  marcador(Icons.favorite_rounded, '$vidas',
                      const Color(0xFFFF8BA5)),
                  const SizedBox(width: 7),
                  marcador(Icons.bolt_rounded, '$pontos XP',
                      const Color(0xFFFFD166)),
                ]),
              ),
              if (iniciado && !terminado)
                Center(child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xE51C2453),
                    border: Border.all(color: const Color(0x8875DBF7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mensagemTempo > 0
                        ? mensagem
                        : 'CORRA ATÉ O PORTAL ORANGO • SINAIS $sinais/4',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD780),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                )),
              const Spacer(),
              if (iniciado && !terminado)
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        marcador(Icons.local_fire_department_rounded,
                            'COMBO $combo', const Color(0xFFFFB969)),
                        const SizedBox(height: 6),
                        marcador(Icons.stars_rounded,
                            'ORANGO $sinais/4', const Color(0xFF9DF7DA)),
                      ],
                    ),
                    const Spacer(),
                    if (!compacto) ...[
                      if (ima > 0) marcador(Icons.attractions_rounded,
                          'ÍMÃ ${ima.ceil()}s', const Color(0xFF8DEBFF)),
                      if (turbo > 0) ...[
                        const SizedBox(width: 5),
                        marcador(Icons.flash_on_rounded,
                            'TURBO ${turbo.ceil()}s',
                            const Color(0xFFFFD166)),
                      ],
                      if (escudo > 0) ...[
                        const SizedBox(width: 5),
                        marcador(Icons.shield_rounded, 'ESCUDO',
                            const Color(0xFF86FFBE)),
                      ],
                      const SizedBox(width: 12),
                    ],
                    controles(),
                  ]),
                ),
            ]);
          })),
          if (!iniciado) telaInicioOuFim(false),
          if (terminado)
            _RecompensaMinigame(
              jogo: 'ORANGO RUSH',
              pontos: pontos,
              aoConcluir: widget.aoConcluir,
              voltar: widget.voltar,
            ),
        ]),
      ),
    );
  }
}

class _CenarioRush extends CustomPainter {
  final double mundo;
  final double tempoRestante;
  final double yPersonagem;
  final double salto;
  final double invencivel;
  final double ima;
  final double turbo;
  final double escudo;
  final double tremor;
  final double flash;
  final bool deslizando;
  final List<_ItemRush> itens;
  final List<_ParticulaRush> particulas;
  final Color roupa;
  final Color pele;
  final Color cabelo;

  _CenarioRush({
    required this.mundo,
    required this.tempoRestante,
    required this.yPersonagem,
    required this.salto,
    required this.deslizando,
    required this.invencivel,
    required this.ima,
    required this.turbo,
    required this.escudo,
    required this.tremor,
    required this.flash,
    required this.itens,
    required this.particulas,
    required this.roupa,
    required this.pele,
    required this.cabelo,
  });

  static const List<double> pistas = [425, 530, 635];

  void retangulo(Canvas c, Rect r, Color cor, [double raio = 0]) {
    c.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(raio)),
      Paint()..color = cor,
    );
  }

  void rotulo(
    Canvas canvas,
    String texto,
    Offset centro,
    double tamanho,
    Color cor, {
    double? larguraMax,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: cor,
          fontSize: tamanho,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
    )..layout(maxWidth: larguraMax ?? double.infinity);
    p.paint(canvas, centro - Offset(p.width / 2, p.height / 2));
  }

  void predios(Canvas c, double velocidade, Color cor, double base, int camada) {
    final deslocamento = (mundo * velocidade) % 210;
    for (int n = -1; n < 9; n++) {
      final index = n + 50;
      final xx = n * 210.0 - deslocamento;
      final altura = 100.0 + (index * 37 % 105);
      final r = Rect.fromLTWH(xx, base - altura, 166, altura);
      retangulo(c, r, cor, 5);
      retangulo(c, Rect.fromLTWH(xx + 8, r.top - 7, 60, 7),
          const Color(0xFF182956), 2);
      for (int col = 0; col < 4; col++) {
        for (int linha = 0; linha < 3; linha++) {
          if ((index + col * 3 + linha * 7) % 5 == 0) continue;
          retangulo(
            c,
            Rect.fromLTWH(xx + 17 + col * 33,
                r.top + 24 + linha * 31, 13, 17),
            camada == 0
                ? const Color(0xFFFEBC88)
                : const Color(0xFFFFCE8A),
            2,
          );
        }
      }
      if (index % 4 == 0 && camada == 2) {
        retangulo(c, Rect.fromLTWH(xx + 19, r.top + 30, 126, 64),
            const Color(0xFF291F6C), 5);
        retangulo(c, Rect.fromLTWH(xx + 24, r.top + 35, 116, 54),
            const Color(0xFF5136AB), 3);
        rotulo(c, index % 8 == 0 ? 'ORANGO' : 'APRENDA\nONLINE',
            Offset(xx + 82, r.top + 61), 14,
            const Color(0xFFFFE7A9), larguraMax: 112);
      }
    }
  }

  void desenharItem(Canvas c, _ItemRush item) {
    final base = pistas[item.pista];
    final x = item.x;
    final p = Offset(x + 25, base - 80 + math.sin(mundo * 0.012 + x) * 5);
    if (item.tipo == _TipoItem.barreira) {
      retangulo(c, Rect.fromLTWH(x, base - 69, 62, 69),
          const Color(0xFF292443), 9);
      retangulo(c, Rect.fromLTWH(x + 5, base - 65, 52, 57),
          const Color(0xFFFD6A82), 7);
      for (int j = 0; j < 3; j++) {
        retangulo(c, Rect.fromLTWH(x + 9 + j * 15, base - 63, 8, 14),
            const Color(0xFFFFD07A), 2);
      }
      rotulo(c, '!', Offset(x + 31, base - 28), 29, Colors.white);
      retangulo(c, Rect.fromLTWH(x - 5, base - 6, 72, 9),
          const Color(0xFF17213D), 4);
    } else if (item.tipo == _TipoItem.drone) {
      c.drawCircle(Offset(x + 10, base - 74), 14,
          Paint()..color = const Color(0xFF6EDAFF));
      c.drawCircle(Offset(x + 67, base - 74), 14,
          Paint()..color = const Color(0xFF6EDAFF));
      retangulo(c, Rect.fromLTWH(x, base - 112, 79, 43),
          const Color(0xFF253158), 14);
      retangulo(c, Rect.fromLTWH(x + 11, base - 98, 57, 10),
          const Color(0xFFFF7797), 4);
      rotulo(c, '↓', Offset(x + 39, base - 83), 22, Colors.white);
    } else {
      final cor = switch (item.tipo) {
        _TipoItem.estrela => const Color(0xFFFFC65B),
        _TipoItem.ima => const Color(0xFF65DAF5),
        _TipoItem.turbo => const Color(0xFFFF9A6B),
        _TipoItem.escudo => const Color(0xFF77E5B1),
        _TipoItem.sinal => const Color(0xFFDFA2FF),
        _ => const Color(0xFFFFD166),
      };
      c.drawCircle(p, 34, Paint()
        ..color = cor.withValues(alpha: 0.23)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      c.drawCircle(p, 26, Paint()..color = cor);
      c.drawCircle(p, 20, Paint()..color = const Color(0xFF423466));
      final simbolo = switch (item.tipo) {
        _TipoItem.estrela => '★',
        _TipoItem.ima => 'U',
        _TipoItem.turbo => '⚡',
        _TipoItem.escudo => '◆',
        _TipoItem.sinal => 'O',
        _ => '',
      };
      rotulo(c, simbolo, p, 25, Colors.white);
      c.drawOval(Rect.fromCenter(center: Offset(p.dx, base - 2),
          width: 37, height: 8),
          Paint()..color = const Color(0x55000000));
    }
  }

  void desenharJogador(Canvas c) {
    final base = yPersonagem;
    final altura = deslizando ? 42.0 : 93.0;
    final topo = base - altura - salto;
    final passo = math.sin(mundo * 0.070) * 8;

    c.drawOval(Rect.fromLTWH(190, base - 3, 91, 12),
        Paint()..color = const Color(0x66071A2C));

    if (escudo > 0 || ima > 0) {
      c.drawCircle(Offset(237, topo + 43), 62,
          Paint()
            ..color = (escudo > 0
                    ? const Color(0xFF7EFDC1)
                    : const Color(0xFF8BEAFF))
                .withValues(alpha: 0.48)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
    }

    if (invencivel > 0 && (invencivel * 11).floor().isOdd) return;

    if (turbo > 0) {
      for (int i = 0; i < 4; i++) {
        c.drawLine(
          Offset(205 - i * 15.0, topo + 36 + i * 13),
          Offset(139 - i * 18.0, topo + 36 + i * 13),
          Paint()
            ..color = const Color(0xFFFFAE68).withValues(alpha: 0.65)
            ..strokeWidth = 3,
        );
      }
    }

    if (deslizando) {
      retangulo(c, Rect.fromLTWH(198, topo + 10, 80, 32), roupa, 14);
      c.drawCircle(Offset(228, topo + 17), 19, Paint()..color = pele);
      retangulo(c, Rect.fromLTWH(250, topo + 31, 30, 11),
          const Color(0xFF172846), 6);
    } else {
      retangulo(c, Rect.fromLTWH(213, topo + 66 + passo, 15, 25),
          const Color(0xFF1A294B), 6);
      retangulo(c, Rect.fromLTWH(244, topo + 66 - passo, 15, 25),
          const Color(0xFF1A294B), 6);
      retangulo(c, Rect.fromLTWH(205, topo + 39, 61, 39), roupa, 15);
      retangulo(c, Rect.fromLTWH(203, topo + 50 + passo * 0.7, 11, 24),
          pele, 6);
      retangulo(c, Rect.fromLTWH(258, topo + 50 - passo * 0.7, 11, 24),
          pele, 6);
      c.drawCircle(Offset(236, topo + 26), 27, Paint()..color = pele);
      c.drawArc(
        Rect.fromCircle(center: Offset(236, topo + 22), radius: 26),
        math.pi, math.pi, false,
        Paint()
          ..color = cabelo
          ..strokeWidth = 15
          ..style = PaintingStyle.stroke,
      );
      c.drawCircle(Offset(247, topo + 28), 3.4,
          Paint()..color = const Color(0xFF20223C));
      retangulo(c, Rect.fromLTWH(226, topo + 47, 20, 8),
          const Color(0xFFFFD779), 4);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1280, size.height / 720);
    const area = Rect.fromLTWH(0, 0, 1280, 720);
    canvas.drawRect(area, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF221C60),
          Color(0xFF72468C),
          Color(0xFFDE7882),
          Color(0xFF327EAB),
        ],
        stops: [0, 0.39, 0.70, 1],
      ).createShader(area));

    final estrelas = math.Random(53);
    for (int i = 0; i < 45; i++) {
      canvas.drawCircle(
        Offset(estrelas.nextDouble() * 1280,
            estrelas.nextDouble() * 250),
        i % 7 == 0 ? 2 : 1,
        Paint()..color = const Color(0xCCFFEBCC),
      );
    }

    canvas.drawCircle(const Offset(1050, 165), 104,
        Paint()..color = const Color(0x44FFE4A6));
    canvas.drawCircle(const Offset(1050, 165), 66,
        Paint()..color = const Color(0xFFFFD597));

    predios(canvas, 0.10, const Color(0xFF323671), 320, 0);
    predios(canvas, 0.23, const Color(0xFF303F79), 358, 1);
    predios(canvas, 0.38, const Color(0xFF234C79), 376, 2);

    canvas.translate(
      math.sin(mundo * 0.04) * tremor,
      math.cos(mundo * 0.03) * tremor * 0.45,
    );

    retangulo(canvas, const Rect.fromLTWH(0, 336, 1280, 384),
        const Color(0xFF122442));

    for (int lane = 0; lane < 3; lane++) {
      final y = pistas[lane];
      retangulo(canvas, Rect.fromLTWH(0, y - 90, 1280, 108),
          lane.isEven ? const Color(0xFF263459) : const Color(0xFF202F52));
      retangulo(canvas, Rect.fromLTWH(0, y + 8, 1280, 8),
          const Color(0xFFFCB961));
      retangulo(canvas, Rect.fromLTWH(0, y - 90, 1280, 3),
          const Color(0xFF59D8F4));

      for (double xx = -(mundo % 145); xx < 1400; xx += 145) {
        retangulo(canvas, Rect.fromLTWH(xx, y - 46, 77, 6),
            const Color(0xFFBEDAF8), 3);
      }

      for (int q = 0; q < 17; q++) {
        final xx = q * 85.0 - (mundo * 0.80) % 85;
        retangulo(canvas, Rect.fromLTWH(xx, y + 22, 32, 2),
            const Color(0x663FD9F2));
      }
    }

    retangulo(canvas, const Rect.fromLTWH(0, 333, 1280, 6),
        const Color(0xFFFFB65B));

    if (tempoRestante <= 8) {
      final energia = (8 - tempoRestante) / 8;
      final portal = Offset(1100, 335);
      canvas.drawOval(
        Rect.fromCenter(center: portal, width: 220, height: 285),
        Paint()
          ..color = const Color(0xFFFFC46A)
              .withValues(alpha: 0.15 + energia * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
      );
      canvas.drawOval(
        Rect.fromCenter(center: portal, width: 170, height: 238),
        Paint()..color = const Color(0xFFFFB449),
      );
      canvas.drawOval(
        Rect.fromCenter(center: portal, width: 146, height: 213),
        Paint()..color = const Color(0xFF382C7B),
      );
      for (int i = 0; i < 4; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: portal, radius: 27 + i * 16.0),
          mundo * 0.006 * (i.isEven ? 1 : -1),
          math.pi * 1.3,
          false,
          Paint()
            ..color = const Color(0xFF95F8FF)
                .withValues(alpha: 0.65)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
      rotulo(canvas, 'PORTAL ORANGO',
          const Offset(1100, 181), 20,
          const Color(0xFFFFDF8E));
    }

    for (final item in itens) {
      if (!item.removido) desenharItem(canvas, item);
    }

    for (final p in particulas) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        5 * p.vida.clamp(0.0, 1.0).toDouble(),
        Paint()..color = p.cor.withValues(
          alpha: p.vida.clamp(0.0, 1.0).toDouble(),
        ),
      );
    }

    desenharJogador(canvas);

    if (flash > 0) {
      canvas.drawRect(area, Paint()..color = const Color(0x22FFFFFF));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CenarioRush old) => true;
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
