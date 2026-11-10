import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados/personagens.dart';

class ExploradoresSabor extends StatefulWidget {
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const ExploradoresSabor({
    super.key,
    required this.aoConcluir,
    required this.voltar,
  });

  @override
  State<ExploradoresSabor> createState() => _ExploradoresSaborState();
}

class _Moeda {
  final Offset posicao;
  bool coletada = false;

  _Moeda(this.posicao);
}

class _Bloco {
  final Rect area;
  bool usado = false;
  bool especial = false;
  double impacto = 0;

  _Bloco(
    this.area, {
    this.especial = false,
  });
}

class _Inimigo {
  final double inicio;
  final double alcance;
  final double velocidade;
  final bool especial;

  double x;
  int direcao = 1;
  bool derrotado = false;

  _Inimigo(
    this.inicio,
    this.alcance,
    this.velocidade, {
    this.especial = false,
  }) : x = inicio;
}

class _Plataforma {
  final Rect area;
  final bool movel;
  final double fase;
  final double amplitudeX;
  final double amplitudeY;

  const _Plataforma(
    this.area, {
    this.movel = false,
    this.fase = 0,
    this.amplitudeX = 0,
    this.amplitudeY = 0,
  });

  Rect posicao(double tempo) {
    if (!movel) return area;

    return area.shift(
      Offset(
        math.sin(tempo * 1.4 + fase) * amplitudeX,
        math.cos(tempo * 1.1 + fase) * amplitudeY,
      ),
    );
  }
}

class _Particula {
  double x;
  double y;
  double vx;
  double vy;
  double vida = 1;
  final Color cor;

  _Particula(
    this.x,
    this.y,
    this.vx,
    this.vy,
    this.cor,
  );
}

class _PainelMundo {
  final double x;
  final double y;
  final double largura;
  final double altura;
  final Color cor;
  final String texto;
  final IconData icone;

  const _PainelMundo({
    required this.x,
    required this.y,
    required this.largura,
    required this.altura,
    required this.cor,
    required this.texto,
    required this.icone,
  });

  Rect get area => Rect.fromLTWH(x, y, largura, altura);
}

class _ExploradoresSaborState extends State<ExploradoresSabor>
    with SingleTickerProviderStateMixin {
  static const double larguraMundo = 5200;
  static const double alturaMundo = 720;
  static const double chao = 625;

  static const double larguraHeroi = 43;
  static const double alturaHeroi = 59;
  static const double portalX = 5030;

  static const String urlOrango = 'https://orango.senac.br/';

  final foco = FocusNode();
  final teclas = <LogicalKeyboardKey>{};

  final moedas = <_Moeda>[];
  final blocos = <_Bloco>[];
  final plataformas = <_Plataforma>[];
  final inimigos = <_Inimigo>[];
  final particulas = <_Particula>[];
  final espinhos = <Rect>[];
  final paineis = <_PainelMundo>[];
  final checkpoints = <double>[];

  final random = math.Random();

  final List<String> catalogoCursos = [
    'Programacao Web',
    'Design Digital',
    'Logica de Programacao',
    'Empreendedorismo',
    'Inteligencia Artificial',
    'Marketing Digital',
    'Excel Profissional',
    'Criacao de Games',
  ];

  final List<String> cursosDescobertos = [];

  late final Ticker motor;
  Duration? ultimoFrame;

  bool iniciou = false;
  bool terminou = false;
  bool venceu = false;
  bool pausado = false;
  bool direita = true;
  bool noChao = true;

  bool solicitarPulo = false;
  bool solicitarDash = false;

  int vidas = 3;
  int pontos = 0;
  int combo = 0;
  int moedasColetadas = 0;
  int selosOrango = 0;
  int saltos = 0;
  int blocosAtingidos = 0;
  int inimigosDerrotados = 0;

  double x = 90;
  double y = chao - alturaHeroi;
  double vx = 0;
  double vy = 0;

  double camera = 0;
  double larguraVisivel = 1200;

  double tempo = 100;
  double animacao = 0;
  double invencivel = 0;
  double dashAtivo = 0;
  double dashRecarga = 0;
  double coyote = 0;
  double tremor = 0;
  double tempoMensagem = 0;
  double renascimento = 90;

  String mensagem = 'COMECE SUA JORNADA NO ORANGO!';

  @override
  void initState() {
    super.initState();
    prepararMundo();
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

  void prepararMundo() {
    moedas.clear();
    blocos.clear();
    plataformas.clear();
    inimigos.clear();
    particulas.clear();
    espinhos.clear();
    paineis.clear();
    checkpoints.clear();

    paineis.addAll([
      const _PainelMundo(
        x: 170,
        y: 120,
        largura: 320,
        altura: 92,
        cor: Color(0xFF1E3557),
        texto: 'ORANGO',
        icone: Icons.auto_awesome_rounded,
      ),
      const _PainelMundo(
        x: 980,
        y: 105,
        largura: 400,
        altura: 92,
        cor: Color(0xFF23406B),
        texto: 'CURSOS GRATUITOS',
        icone: Icons.school_rounded,
      ),
      const _PainelMundo(
        x: 1880,
        y: 100,
        largura: 420,
        altura: 92,
        cor: Color(0xFF20436A),
        texto: 'JOGUE • DESCUBRA • APRENDA',
        icone: Icons.sports_esports_rounded,
      ),
      const _PainelMundo(
        x: 2880,
        y: 102,
        largura: 360,
        altura: 92,
        cor: Color(0xFF1F3D64),
        texto: 'GANHE XP',
        icone: Icons.bolt_rounded,
      ),
      const _PainelMundo(
        x: 3950,
        y: 105,
        largura: 420,
        altura: 92,
        cor: Color(0xFF22436C),
        texto: 'SEU FUTURO NO ORANGO',
        icone: Icons.rocket_launch_rounded,
      ),
    ]);

    plataformas.addAll([
      const _Plataforma(Rect.fromLTWH(280, 520, 210, 24)),
      const _Plataforma(Rect.fromLTWH(740, 470, 220, 24)),
      const _Plataforma(Rect.fromLTWH(1120, 520, 240, 24)),
      const _Plataforma(
        Rect.fromLTWH(1500, 455, 180, 24),
        movel: true,
        fase: 0.7,
        amplitudeX: 70,
        amplitudeY: 10,
      ),
      const _Plataforma(Rect.fromLTWH(1860, 490, 200, 24)),
      const _Plataforma(Rect.fromLTWH(2190, 450, 170, 24)),
      const _Plataforma(Rect.fromLTWH(2510, 520, 220, 24)),
      const _Plataforma(
        Rect.fromLTWH(2860, 438, 170, 24),
        movel: true,
        fase: 2.5,
        amplitudeX: 85,
        amplitudeY: 8,
      ),
      const _Plataforma(Rect.fromLTWH(3250, 500, 210, 24)),
      const _Plataforma(Rect.fromLTWH(3560, 450, 190, 24)),
      const _Plataforma(Rect.fromLTWH(3890, 510, 220, 24)),
      const _Plataforma(
        Rect.fromLTWH(4230, 450, 170, 24),
        movel: true,
        fase: 3.8,
        amplitudeX: 65,
        amplitudeY: 12,
      ),
      const _Plataforma(Rect.fromLTWH(4550, 500, 200, 24)),
      const _Plataforma(Rect.fromLTWH(4780, 420, 160, 24)),
    ]);

    blocos.addAll([
      _Bloco(const Rect.fromLTWH(820, 385, 58, 54), especial: true),
      _Bloco(const Rect.fromLTWH(900, 385, 58, 54)),
      _Bloco(const Rect.fromLTWH(1680, 372, 58, 54), especial: true),
      _Bloco(const Rect.fromLTWH(1760, 372, 58, 54)),
      _Bloco(const Rect.fromLTWH(2610, 395, 58, 54), especial: true),
      _Bloco(const Rect.fromLTWH(2690, 395, 58, 54)),
      _Bloco(const Rect.fromLTWH(3650, 368, 58, 54), especial: true),
      _Bloco(const Rect.fromLTWH(3730, 368, 58, 54)),
      _Bloco(const Rect.fromLTWH(4700, 350, 58, 54), especial: true),
    ]);

    inimigos.addAll([
      _Inimigo(610, 120, 75),
      _Inimigo(1320, 110, 82),
      _Inimigo(2050, 120, 88, especial: true),
      _Inimigo(2780, 115, 90),
      _Inimigo(3400, 125, 94, especial: true),
      _Inimigo(4100, 110, 98),
      _Inimigo(4630, 95, 104, especial: true),
    ]);

    espinhos.addAll([
      const Rect.fromLTWH(540, 600, 68, 25),
      const Rect.fromLTWH(1000, 600, 68, 25),
      const Rect.fromLTWH(1570, 600, 72, 25),
      const Rect.fromLTWH(2310, 600, 70, 25),
      const Rect.fromLTWH(3050, 600, 70, 25),
      const Rect.fromLTWH(3810, 600, 72, 25),
      const Rect.fromLTWH(4460, 600, 72, 25),
    ]);

    checkpoints.addAll([1240, 2520, 3880]);

    for (double grupo = 180; grupo < 4950; grupo += 270) {
      for (int i = 0; i < 4; i++) {
        moedas.add(
          _Moeda(
            Offset(
              grupo + i * 40,
              535 - math.sin(i * math.pi / 3) * 36,
            ),
          ),
        );
      }
    }

    for (final plataforma in plataformas) {
      final rect = plataforma.area;
      moedas.add(_Moeda(Offset(rect.center.dx, rect.top - 48)));
    }
  }

  void avisar(String texto) {
    mensagem = texto;
    tempoMensagem = 2.8;
  }

  void particulasEm(
    double px,
    double py,
    Color cor, {
    int quantidade = 15,
  }) {
    for (int i = 0; i < quantidade; i++) {
      final angulo = random.nextDouble() * math.pi * 2;
      final forca = 70 + random.nextDouble() * 200;

      particulas.add(
        _Particula(
          px,
          py,
          math.cos(angulo) * forca,
          math.sin(angulo) * forca,
          cor,
        ),
      );
    }
  }

  void iniciar() {
    setState(() {
      iniciou = true;
      terminou = false;
      venceu = false;
      pausado = false;
      direita = true;
      noChao = true;

      vidas = 3;
      pontos = 0;
      combo = 0;
      moedasColetadas = 0;
      selosOrango = 0;
      saltos = 0;
      blocosAtingidos = 0;
      inimigosDerrotados = 0;
      cursosDescobertos.clear();

      x = 90;
      y = chao - alturaHeroi;
      vx = 0;
      vy = 0;
      camera = 0;
      tempo = 100;
      animacao = 0;
      invencivel = 0;
      dashAtivo = 0;
      dashRecarga = 0;
      coyote = 0;
      tremor = 0;
      tempoMensagem = 0;
      renascimento = 90;

      solicitarPulo = false;
      solicitarDash = false;

      teclas.clear();
      particulas.clear();

      for (final moeda in moedas) {
        moeda.coletada = false;
      }

      for (final bloco in blocos) {
        bloco.usado = false;
        bloco.impacto = 0;
      }

      for (final inimigo in inimigos) {
        inimigo.x = inimigo.inicio;
        inimigo.direcao = 1;
        inimigo.derrotado = false;
      }

      avisar('CORRA E DESCUBRA OPORTUNIDADES NO ORANGO!');
    });

    foco.requestFocus();
  }

  void pular() {
    if (!iniciou || terminou || pausado) return;
    solicitarPulo = true;
    foco.requestFocus();
  }

  void dash() {
    if (!iniciou || terminou || pausado) return;
    solicitarDash = true;
    foco.requestFocus();
  }

  KeyEventResult teclado(FocusNode node, KeyEvent evento) {
    final tecla = evento.logicalKey;

    if (evento is KeyUpEvent) {
      teclas.remove(tecla);
      return KeyEventResult.handled;
    }

    if (evento is! KeyDownEvent) {
      return KeyEventResult.handled;
    }

    if (tecla == LogicalKeyboardKey.escape) {
      widget.voltar();
      return KeyEventResult.handled;
    }

    if (!iniciou) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space) {
        iniciar();
      }
      return KeyEventResult.handled;
    }

    if (tecla == LogicalKeyboardKey.keyP) {
      setState(() => pausado = !pausado);
      return KeyEventResult.handled;
    }

    if (terminou || pausado) return KeyEventResult.handled;

    teclas.add(tecla);

    if (tecla == LogicalKeyboardKey.space ||
        tecla == LogicalKeyboardKey.keyW ||
        tecla == LogicalKeyboardKey.arrowUp) {
      pular();
    }

    if (tecla == LogicalKeyboardKey.shiftLeft ||
        tecla == LogicalKeyboardKey.shiftRight) {
      dash();
    }

    return KeyEventResult.handled;
  }

  void perderVida() {
    if (invencivel > 0 || terminou) return;

    vidas--;
    combo = 0;
    tremor = 13;

    particulasEm(
      x + larguraHeroi / 2,
      y + alturaHeroi / 2,
      const Color(0xFFFF718F),
      quantidade: 22,
    );

    if (vidas <= 0) {
      finalizar(false);
      return;
    }

    x = renascimento;
    y = chao - alturaHeroi;
    vx = 0;
    vy = 0;
    saltos = 0;
    dashAtivo = 0;
    invencivel = 1.7;

    avisar('TENTE DE NOVO! O ORANGO TE ESPERA!');
  }

  void ganharCurso(String origem) {
    if (cursosDescobertos.length >= catalogoCursos.length) {
      pontos += 120;
      avisar('MAIS XP PARA SUA JORNADA!');
      return;
    }

    final curso = catalogoCursos[cursosDescobertos.length];
    cursosDescobertos.add(curso);
    pontos += 180;

    avisar('CURSO DESCOBERTO: $curso');
    particulasEm(
      x + 18,
      y + 18,
      const Color(0xFF7EF0C0),
      quantidade: 26,
    );
  }

  void darRecompensaPorBloco(_Bloco bloco) {
    blocosAtingidos++;
    pontos += bloco.especial ? 120 : 70;
    selosOrango += bloco.especial ? 2 : 1;

    if (bloco.especial) {
      ganharCurso('bloco');
    } else {
      avisar('SELO ORANGO COLETADO!');
    }
  }

  void darRecompensaPorInimigo(_Inimigo inimigo) {
    inimigosDerrotados++;
    pontos += inimigo.especial ? 140 : 90;
    selosOrango += inimigo.especial ? 2 : 1;

    if (inimigo.especial || inimigosDerrotados % 2 == 0) {
      ganharCurso('inimigo');
    } else {
      avisar('VOCE GANHOU XP NO ORANGO!');
    }
  }

  void finalizar(bool sucesso) {
    if (terminou) return;

    terminou = true;
    venceu = sucesso;
    teclas.clear();

    if (sucesso) {
      pontos += 400;
      pontos += tempo.ceil() * 5;
      pontos += selosOrango * 30;

      particulasEm(
        portalX,
        490,
        const Color(0xFFFFD166),
        quantidade: 60,
      );

      avisar('PARABENS! VOCE CHEGOU AO PORTAL ORANGO!');
    } else {
      avisar('FIM DA AVENTURA!');
    }
  }

  void ativarBloco(_Bloco bloco) {
    bloco.impacto = 1;

    particulasEm(
      bloco.area.center.dx,
      bloco.area.top,
      bloco.especial ? const Color(0xFF7EF0C0) : const Color(0xFFFFD166),
      quantidade: 18,
    );

    if (!bloco.usado) {
      bloco.usado = true;
      darRecompensaPorBloco(bloco);
    }
  }

  void atualizar(Duration decorrido) {
    final anterior = ultimoFrame;
    ultimoFrame = decorrido;

    if (!mounted || anterior == null) return;

    final dt = ((decorrido - anterior).inMicroseconds / 1000000)
        .clamp(0.0, 0.033)
        .toDouble();

    if (!iniciou || terminou || pausado || dt <= 0) return;

    setState(() {
      animacao += dt;
      tempo = math.max(0.0, tempo - dt);
      invencivel = math.max(0.0, invencivel - dt);
      dashAtivo = math.max(0.0, dashAtivo - dt);
      dashRecarga = math.max(0.0, dashRecarga - dt);
      tremor = math.max(0.0, tremor - dt * 28);
      tempoMensagem = math.max(0.0, tempoMensagem - dt);

      for (final bloco in blocos) {
        bloco.impacto = math.max(0.0, bloco.impacto - dt * 4);
      }

      double direcao = 0;

      if (teclas.contains(LogicalKeyboardKey.keyA) ||
          teclas.contains(LogicalKeyboardKey.arrowLeft)) {
        direcao--;
      }
      if (teclas.contains(LogicalKeyboardKey.keyD) ||
          teclas.contains(LogicalKeyboardKey.arrowRight)) {
        direcao++;
      }

      if (direcao > 0) direita = true;
      if (direcao < 0) direita = false;

      if (solicitarPulo) {
        solicitarPulo = false;

        if (noChao || coyote > 0 || saltos < 2) {
          final primeiro = noChao || coyote > 0;

          vy = primeiro ? -795 : -720;
          saltos = primeiro ? 1 : 2;

          noChao = false;
          coyote = 0;

          particulasEm(
            x + 22,
            y + alturaHeroi,
            const Color(0xFF9DEEFF),
            quantidade: 10,
          );

          if (!primeiro) {
            avisar('PULO DUPLO!');
          }
        }
      }

      if (solicitarDash) {
        solicitarDash = false;

        if (dashRecarga <= 0) {
          dashAtivo = 0.19;
          dashRecarga = 1.4;
          tremor = 3;

          particulasEm(
            x + 22,
            y + 30,
            const Color(0xFFFFD166),
            quantidade: 16,
          );
        }
      }

      final velocidadeAlvo =
          dashAtivo > 0 ? (direita ? 920.0 : -920.0) : direcao * 350;

      final suavidade = 1 - math.exp(-16 * dt);
      vx += (velocidadeAlvo - vx) * suavidade;

      if (dashAtivo > 0) {
        vx = velocidadeAlvo;
      }

      x = (x + vx * dt).clamp(0.0, larguraMundo - larguraHeroi).toDouble();

      final yAntes = y;
      if (dashAtivo <= 0) {
        vy += 2050 * dt;
      }

      double novoY = y + vy * dt;

      final todasPlataformas = <Rect>[
        for (final p in plataformas) p.posicao(animacao),
        for (final bloco in blocos) bloco.area,
      ];

      if (vy < 0) {
        for (final bloco in blocos) {
          final area = bloco.area;

          final atingiu = yAntes >= area.bottom - 5 &&
              novoY <= area.bottom &&
              x + larguraHeroi > area.left + 5 &&
              x < area.right - 5;

          if (atingiu) {
            novoY = area.bottom;
            vy = 105;
            ativarBloco(bloco);
            break;
          }
        }
      }

      bool pousou = false;

      if (vy >= 0) {
        for (final plataforma in todasPlataformas) {
          final atravessou = yAntes + alturaHeroi <= plataforma.top + 8 &&
              novoY + alturaHeroi >= plataforma.top;

          final horizontal =
              x + larguraHeroi > plataforma.left + 4 && x < plataforma.right - 4;

          if (atravessou && horizontal) {
            novoY = plataforma.top - alturaHeroi;
            vy = 0;
            pousou = true;
            break;
          }
        }

        if (!pousou && novoY + alturaHeroi >= chao) {
          novoY = chao - alturaHeroi;
          vy = 0;
          pousou = true;
        }
      }

      if (novoY < 75) {
        novoY = 75;
        vy = math.max(0.0, vy);
      }

      y = novoY;

      if (pousou) {
        noChao = true;
        coyote = 0.11;
        saltos = 0;
      } else {
        if (noChao) {
          coyote = 0.11;
        } else {
          coyote = math.max(0.0, coyote - dt);
        }
        noChao = false;
      }

      final jogador = Rect.fromLTWH(
        x + 6,
        y + 7,
        larguraHeroi - 12,
        alturaHeroi - 9,
      );

      for (final perigo in espinhos) {
        if (jogador.overlaps(perigo)) {
          perderVida();
          break;
        }
      }

      if (!terminou) {
        for (final inimigo in inimigos) {
          if (inimigo.derrotado) continue;

          inimigo.x += inimigo.direcao * inimigo.velocidade * dt;

          if (inimigo.x >= inimigo.inicio + inimigo.alcance) {
            inimigo.direcao = -1;
          }
          if (inimigo.x <= inimigo.inicio) {
            inimigo.direcao = 1;
          }

          final areaInimigo = Rect.fromLTWH(
            inimigo.x,
            chao - 43,
            44,
            43,
          );

          if (!jogador.overlaps(areaInimigo)) continue;

          final pisou = vy > 0 && yAntes + alturaHeroi <= areaInimigo.top + 18;

          if (pisou || dashAtivo > 0) {
            inimigo.derrotado = true;
            vy = -560;
            saltos = 1;
            combo++;

            particulasEm(
              inimigo.x + 22,
              areaInimigo.top + 15,
              inimigo.especial
                  ? const Color(0xFF7EF0C0)
                  : const Color(0xFFFF90A8),
              quantidade: 20,
            );

            darRecompensaPorInimigo(inimigo);
          } else {
            perderVida();
          }
        }
      }

      if (!terminou) {
        final centroJogador = Offset(x + larguraHeroi / 2, y + alturaHeroi / 2);

        for (final moeda in moedas) {
          if (moeda.coletada) continue;

          if ((centroJogador - moeda.posicao).distance < 34) {
            moeda.coletada = true;
            moedasColetadas++;
            pontos += 25;
            combo++;

            particulasEm(
              moeda.posicao.dx,
              moeda.posicao.dy,
              const Color(0xFFFFD166),
              quantidade: 9,
            );
          }
        }

        for (int i = 0; i < checkpoints.length; i++) {
          final ponto = checkpoints[i];
          if (x >= ponto && renascimento < ponto) {
            renascimento = ponto + 30;
            pontos += 75;
            avisar('CHECKPOINT ALCANCADO!');
            particulasEm(
              ponto,
              chao - 120,
              const Color(0xFF7EF0C0),
              quantidade: 25,
            );
          }
        }

        if (x >= portalX - 55) {
          finalizar(true);
        }
      }

      if (dashAtivo > 0 && (animacao * 30).floor().isEven) {
        particulas.add(
          _Particula(
            x + 22,
            y + 30,
            direita ? -120 : 120,
            0,
            const Color(0xFF88ECFF),
          ),
        );
      }

      for (final particula in particulas) {
        particula.x += particula.vx * dt;
        particula.y += particula.vy * dt;
        particula.vy += 170 * dt;
        particula.vida -= dt * 1.6;
      }

      particulas.removeWhere((particula) => particula.vida <= 0);

      final maxCamera = math.max(0.0, larguraMundo - larguraVisivel);
      final alvo = (x - larguraVisivel * 0.34).clamp(0.0, maxCamera).toDouble();
      camera += (alvo - camera) * (1 - math.exp(-7 * dt));

      if (tempo <= 0 && !terminou) {
        finalizar(false);
      }
    });
  }

  Future<void> abrirOrango() async {
    try {
      final abriu = await launchUrl(
        Uri.parse(urlOrango),
        mode: LaunchMode.externalApplication,
      );

      if (!abriu) throw Exception('Nao foi possivel abrir');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesse: https://orango.senac.br/'),
        ),
      );
    }
  }

  Widget indicador(
    IconData icone,
    String valor,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xDD172B46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 18),
          const SizedBox(width: 5),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget botaoMovimento(
    IconData icone,
    LogicalKeyboardKey tecla,
  ) {
    return GestureDetector(
      onTapDown: (_) => teclas.add(tecla),
      onTapUp: (_) => teclas.remove(tecla),
      onTapCancel: () => teclas.remove(tecla),
      child: Container(
        width: 52,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xD52C3D68),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white38),
        ),
        child: Icon(
          icone,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget painelInicial() {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xE80B1730),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF385B78),
                    Color(0xFF292448),
                    Color(0xFF15243E),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFFFC566),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 35,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: Color(0xFFFFD166),
                    size: 58,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ORANGO ADVENTURE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ATRAVESSE A CIDADE E ENCONTRE O PORTAL ORANGO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD166),
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Corra, pule, derrote desafios e bata em blocos especiais para descobrir cursos gratuitos do Orango.\n\n'
                    'Quanto mais voce joga, mais XP, selos e cursos voce conquista.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3650),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x667EF0C0),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'CONTROLES',
                          style: TextStyle(
                            color: Color(0xFF93F3B6),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'A / D ou setas: andar\nEspaco: pular\nShift: dash\nP: pausar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: iniciar,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'COMECAR AVENTURA',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB957),
                        foregroundColor: const Color(0xFF1B2A43),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: widget.voltar,
                    child: const Text(
                      'VOLTAR A CIDADE',
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

Widget painelFinal() {
  return Positioned.fill(
    child: ColoredBox(
      color: const Color(0xE80B1730),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF334E73),
                  Color(0xFF25224B),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFC566),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFFFD166),
                  size: 58,
                ),
                const SizedBox(height: 14),
                const Text(
                  'RESGATE SUA RECOMPENSA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$pontos XP',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  venceu
                      ? 'Você concluiu a aventura e desbloqueou sua recompensa no Orango.'
                      : 'Você já conquistou progresso. Agora continue no Orango.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3651),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7EF0C0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'RESGATE NO ORANGO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF93F3B6),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escaneie o QR Code e descubra cursos gratuitos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: urlOrango,
                          size: 170,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'orango.senac.br',
                        style: TextStyle(
                          color: Color(0xFFFFD166),
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: abrirOrango,
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text(
                            'RESGATAR NO ORANGO',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF89E7A9),
                            foregroundColor: const Color(0xFF17324A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => widget.aoConcluir(pontos),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text(
                      'RECEBER XP E VOLTAR',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB957),
                      foregroundColor: const Color(0xFF1B2A43),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: widget.voltar,
                  child: const Text(
                    'VOLTAR À CIDADE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
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
    return Material(
      color: const Color(0xFF172942),
      child: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: teclado,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final escala = constraints.maxHeight / alturaMundo;
            larguraVisivel = constraints.maxWidth / escala;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: pular,
                    child: CustomPaint(
                      painter: _PintorOrangoAdventure(
                        camera: camera,
                        x: x,
                        y: y,
                        vx: vx,
                        animacao: animacao,
                        invencivel: invencivel,
                        dashAtivo: dashAtivo,
                        tremor: tremor,
                        direita: direita,
                        noChao: noChao,
                        moedas: moedas,
                        blocos: blocos,
                        inimigos: inimigos,
                        plataformas: plataformas,
                        particulas: particulas,
                        espinhos: espinhos,
                        paineis: paineis,
                        roupa: PersonagensOrango.escolhido.roupa,
                        pele: PersonagensOrango.escolhido.pele,
                        cabelo: PersonagensOrango.escolhido.cabelo,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                            'ORANGO ADVENTURE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 21,
                            ),
                          ),
                          const Spacer(),
                          indicador(
                            Icons.timer_rounded,
                            '${tempo.ceil()}s',
                            const Color(0xFFFFD166),
                          ),
                          const SizedBox(width: 7),
                          indicador(
                            Icons.favorite_rounded,
                            '$vidas',
                            const Color(0xFFFF87A2),
                          ),
                          const SizedBox(width: 7),
                          indicador(
                            Icons.workspace_premium_rounded,
                            '$selosOrango',
                            const Color(0xFFFFE89A),
                          ),
                          const SizedBox(width: 7),
                          indicador(
                            Icons.bolt_rounded,
                            '$pontos XP',
                            const Color(0xFF9ED9FF),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => pausado = !pausado);
                            },
                            icon: Icon(
                              pausado
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (iniciou && !terminou && !pausado && tempoMensagem > 0)
                  Positioned(
                    top: 84,
                    left: 15,
                    right: 15,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xEA1B2E4A),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: const Color(0x77FFD166),
                          ),
                        ),
                        child: Text(
                          mensagem,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD166),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (iniciou && !terminou && !pausado)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          botaoMovimento(
                            Icons.arrow_back_rounded,
                            LogicalKeyboardKey.arrowLeft,
                          ),
                          const SizedBox(width: 8),
                          botaoMovimento(
                            Icons.arrow_forward_rounded,
                            LogicalKeyboardKey.arrowRight,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: pular,
                            icon: const Icon(Icons.keyboard_arrow_up_rounded),
                            label: const Text('PULAR'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFA7DDFF),
                              foregroundColor: const Color(0xFF182A44),
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: dashRecarga <= 0 ? dash : null,
                            icon: const Icon(Icons.bolt_rounded),
                            label: const Text('DASH'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC66D),
                              foregroundColor: const Color(0xFF182A44),
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (pausado && iniciou && !terminou)
                  Positioned.fill(
                    child: ColoredBox(
                      color: const Color(0xC90C172E),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pause_circle_rounded,
                              size: 65,
                              color: Color(0xFFFFD166),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'JOGO PAUSADO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 19),
                            FilledButton(
                              onPressed: () {
                                setState(() => pausado = false);
                                foco.requestFocus();
                              },
                              child: const Text('CONTINUAR'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!iniciou) painelInicial(),
                if (terminou)
                  _RecompensaMinigame(
                    jogo: 'ORANGO ADVENTURE',
                    pontos: pontos,
                    aoConcluir: widget.aoConcluir,
                    voltar: widget.voltar,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PintorOrangoAdventure extends CustomPainter {
  final double camera;
  final double x;
  final double y;
  final double vx;
  final double animacao;
  final double invencivel;
  final double dashAtivo;
  final double tremor;

  final bool direita;
  final bool noChao;

  final List<_Moeda> moedas;
  final List<_Bloco> blocos;
  final List<_Inimigo> inimigos;
  final List<_Plataforma> plataformas;
  final List<_Particula> particulas;
  final List<Rect> espinhos;
  final List<_PainelMundo> paineis;

  final Color roupa;
  final Color pele;
  final Color cabelo;

  _PintorOrangoAdventure({
    required this.camera,
    required this.x,
    required this.y,
    required this.vx,
    required this.animacao,
    required this.invencivel,
    required this.dashAtivo,
    required this.tremor,
    required this.direita,
    required this.noChao,
    required this.moedas,
    required this.blocos,
    required this.inimigos,
    required this.plataformas,
    required this.particulas,
    required this.espinhos,
    required this.paineis,
    required this.roupa,
    required this.pele,
    required this.cabelo,
  });

  void caixa(
    Canvas canvas,
    Rect rect,
    Color cor, {
    double raio = 8,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(raio),
      ),
      Paint()..color = cor,
    );
  }

  void texto(
    Canvas canvas,
    String valor,
    Offset centro,
    double tamanho,
    Color cor,
  ) {
    final p = TextPainter(
      text: TextSpan(
        text: valor,
        style: TextStyle(
          color: cor,
          fontSize: tamanho,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Colors.black54,
              blurRadius: 7,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    p.paint(
      canvas,
      centro - Offset(p.width / 2, p.height / 2),
    );
  }

  void iconeNoCanvas(
    Canvas canvas,
    IconData icon,
    Offset centro,
    double tamanho,
    Color cor,
  ) {
    final p = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: tamanho,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: cor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    p.paint(
      canvas,
      Offset(centro.dx - p.width / 2, centro.dy - p.height / 2),
    );
  }

  void desenharCidade(Canvas canvas, double largura) {
    final fundo = Rect.fromLTWH(0, 0, largura, 720);

    canvas.drawRect(
      fundo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF392B70),
            Color(0xFF4976A4),
            Color(0xFF54B5B8),
          ],
        ).createShader(fundo),
    );

    canvas.drawCircle(
      Offset(largura * 0.77, 142),
      92,
      Paint()
        ..color = const Color(0xFFFFD499).withValues(alpha: 0.16),
    );

    canvas.drawCircle(
      Offset(largura * 0.77, 142),
      51,
      Paint()..color = const Color(0xFFFFD99F),
    );

    final random = math.Random(36);

    for (int i = 0; i < 65; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * largura,
          random.nextDouble() * 280,
        ),
        1.1 + i % 3,
        Paint()..color = Colors.white.withValues(alpha: 0.42),
      );
    }

    for (int camada = 0; camada < 3; camada++) {
      final deslocamento = (camera * (0.10 + camada * 0.14)) % 188;
      final base = 402.0 + camada * 55;

      final cor = [
        const Color(0xFF34487A),
        const Color(0xFF37688B),
        const Color(0xFF2F7B89),
      ][camada];

      for (int i = -1; i < largura / 188 + 2; i++) {
        final px = i * 188.0 - deslocamento;
        final h = 115.0 + ((i + 35) % 5) * 33;

        caixa(
          canvas,
          Rect.fromLTWH(px, base - h, 134, h),
          cor,
        );

        for (int coluna = 0; coluna < 3; coluna++) {
          for (int linha = 0; linha < 4; linha++) {
            caixa(
              canvas,
              Rect.fromLTWH(
                px + 17 + coluna * 36,
                base - h + 23 + linha * 36,
                15,
                19,
              ),
              const Color(0xFFFFD999),
              raio: 3,
            );
          }
        }
      }
    }
  }

  void desenharPlataforma(
    Canvas canvas,
    Rect area,
    bool movel,
  ) {
    caixa(
      canvas,
      area.shift(const Offset(0, 9)),
      const Color(0xFF183752),
    );

    caixa(
      canvas,
      area,
      movel ? const Color(0xFF55BCE9) : const Color(0xFF61C796),
    );

    caixa(
      canvas,
      Rect.fromLTWH(area.left, area.top, area.width, 8),
      const Color(0xFFB7FFDC),
      raio: 4,
    );

    if (movel) {
      texto(
        canvas,
        '↔',
        area.center,
        18,
        Colors.white,
      );
    }
  }

  void desenharPortal(Canvas canvas) {
    const centro = Offset(5030, 515);

    final pulso = (math.sin(animacao * 4) + 1) / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 174 + pulso * 14,
        height: 230 + pulso * 14,
      ),
      Paint()
        ..color = const Color(0xFFFFCC72).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          30,
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 158,
        height: 222,
      ),
      Paint()..color = const Color(0xFF172943),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 140,
        height: 204,
      ),
      Paint()..color = const Color(0xFFFFB95F),
    );

    final interior = Rect.fromCenter(
      center: centro,
      width: 113,
      height: 183,
    );

    canvas.drawOval(
      interior,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFB5FFDC),
            Color(0xFF81CFF0),
            Color(0xFF8266CA),
            Color(0xFF24204E),
          ],
        ).createShader(interior),
    );

    for (int i = 0; i < 5; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: centro,
          radius: 20 + i * 12.0,
        ),
        animacao * (i.isEven ? 1 : -1) + i,
        math.pi * 1.35,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = 2.3
          ..style = PaintingStyle.stroke,
      );
    }

    texto(
      canvas,
      'PORTAL',
      centro + const Offset(0, -145),
      25,
      const Color(0xFFFFE6A8),
    );

    texto(
      canvas,
      'ORANGO',
      centro + const Offset(0, 133),
      15,
      const Color(0xFFFFE6A8),
    );
  }

  void desenharPersonagem(Canvas canvas) {
    if (invencivel > 0 && (invencivel * 12).floor().isOdd) {
      return;
    }

    final passo =
        noChao ? math.sin(animacao * 18) * math.min(5.5, vx.abs() / 60) : 0.0;

    canvas.drawOval(
      Rect.fromLTWH(x - 4, 624, 53, 10),
      Paint()..color = Colors.black26,
    );

    if (dashAtivo > 0) {
      for (int i = 1; i <= 3; i++) {
        caixa(
          canvas,
          Rect.fromLTWH(
            x + (direita ? -i * 16 : i * 16),
            y + 21,
            35,
            29,
          ),
          roupa.withValues(alpha: 0.13),
          raio: 12,
        );
      }
    }

    caixa(
      canvas,
      Rect.fromLTWH(x + 5, y + 42 + passo, 13, 17),
      const Color(0xFF243653),
      raio: 4,
    );

    caixa(
      canvas,
      Rect.fromLTWH(x + 25, y + 42 - passo, 13, 17),
      const Color(0xFF243653),
      raio: 4,
    );

    caixa(
      canvas,
      Rect.fromLTWH(x + 3, y + 25, 38, 28),
      roupa,
      raio: 11,
    );

    canvas.drawCircle(
      Offset(x + 22, y + 20),
      20,
      Paint()..color = pele,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(x + 22, y + 17), radius: 20),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = cabelo
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      Offset(x + (direita ? 31 : 14), y + 21),
      3,
      Paint()..color = const Color(0xFF22253D),
    );

    caixa(
      canvas,
      Rect.fromLTWH(x + 16, y + 35, 13, 7),
      const Color(0xFFFFD166),
      raio: 3,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.height / 720;
    final larguraVisivel = size.width / escala;

    canvas.save();
    canvas.scale(escala);

    desenharCidade(canvas, larguraVisivel);

    canvas.translate(
      -camera + math.sin(animacao * 53) * tremor,
      math.cos(animacao * 46) * tremor * 0.4,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(0, 625, 5200, 95),
      const Color(0xFF1D3853),
      raio: 0,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(0, 617, 5200, 12),
      const Color(0xFF79E5B2),
      raio: 0,
    );

    for (double px = 0; px < 5200; px += 95) {
      caixa(
        canvas,
        Rect.fromLTWH(px, 675, 59, 7),
        const Color(0xFFB8D5E3),
        raio: 3,
      );
    }

    for (final painel in paineis) {
      caixa(
        canvas,
        painel.area.shift(const Offset(0, 6)),
        const Color(0xFF132B44),
        raio: 18,
      );
      caixa(
        canvas,
        painel.area,
        painel.cor,
        raio: 18,
      );
      iconeNoCanvas(
        canvas,
        painel.icone,
        Offset(painel.x + 34, painel.y + painel.altura / 2),
        30,
        const Color(0xFFFFD166),
      );
      texto(
        canvas,
        painel.texto,
        Offset(painel.x + painel.largura / 2 + 16, painel.y + painel.altura / 2),
        26,
        Colors.white,
      );
    }

    for (final plataforma in plataformas) {
      desenharPlataforma(
        canvas,
        plataforma.posicao(animacao),
        plataforma.movel,
      );
    }

    for (final bloco in blocos) {
      final area = bloco.area.shift(
        Offset(0, -math.sin(bloco.impacto * math.pi) * 9),
      );

      caixa(
        canvas,
        area.shift(const Offset(0, 5)),
        const Color(0xFF1A344C),
      );

      caixa(
        canvas,
        area,
        bloco.usado
            ? const Color(0xFF687586)
            : (bloco.especial
                ? const Color(0xFF79E7B3)
                : const Color(0xFFFFC45E)),
      );

      caixa(
        canvas,
        Rect.fromLTWH(area.left + 6, area.top + 5, area.width - 12, 7),
        bloco.especial
            ? const Color(0xFFCEFFE5)
            : const Color(0xFFFFE1A0),
        raio: 3,
      );

      texto(
        canvas,
        bloco.usado ? '✓' : (bloco.especial ? '★' : '?'),
        area.center,
        30,
        const Color(0xFF25344C),
      );
    }

    for (final perigo in espinhos) {
      for (double px = perigo.left; px < perigo.right; px += 18) {
        final caminho = Path()
          ..moveTo(px, perigo.bottom)
          ..lineTo(px + 9, perigo.top)
          ..lineTo(px + 18, perigo.bottom)
          ..close();

        canvas.drawPath(
          caminho,
          Paint()..color = const Color(0xFFFF718C),
        );
      }
    }

    for (final moeda in moedas) {
      if (moeda.coletada) continue;

      final pos = moeda.posicao + Offset(0, math.sin(animacao * 4 + moeda.posicao.dx) * 4);

      final larguraMoeda =
          8 + math.cos(animacao * 5 + moeda.posicao.dx).abs() * 9;

      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: larguraMoeda * 2,
          height: 26,
        ),
        Paint()..color = const Color(0xFFFFD166),
      );

      texto(
        canvas,
        '✦',
        pos,
        15,
        const Color(0xFFFFFFFF),
      );
    }

    for (final inimigo in inimigos) {
      if (inimigo.derrotado) continue;

      final flutuar = math.sin(animacao * 6 + inimigo.x) * 2;

      caixa(
        canvas,
        Rect.fromLTWH(inimigo.x, 580 + flutuar, 44, 42),
        inimigo.especial
            ? const Color(0xFF74DDB0)
            : const Color(0xFFE87092),
        raio: 13,
      );

      caixa(
        canvas,
        Rect.fromLTWH(inimigo.x + 8, 591 + flutuar, 29, 12),
        const Color(0xFFFFCBD8),
      );

      canvas.drawCircle(
        Offset(inimigo.x + 16, 596 + flutuar),
        3,
        Paint()..color = const Color(0xFF23334D),
      );

      caixa(
        canvas,
        Rect.fromLTWH(inimigo.x + 9, 615 + flutuar, 11, 8),
        const Color(0xFF263753),
      );

      caixa(
        canvas,
        Rect.fromLTWH(inimigo.x + 26, 615 + flutuar, 11, 8),
        const Color(0xFF263753),
      );
    }

    for (final checkpointX in const [1240.0, 2520.0, 3880.0]) {
      caixa(
        canvas,
        Rect.fromLTWH(checkpointX, 511, 8, 112),
        const Color(0xFF203954),
        raio: 3,
      );

      caixa(
        canvas,
        Rect.fromLTWH(checkpointX + 8, 515, 86, 44),
        const Color(0xFFFFC874),
      );

      texto(
        canvas,
        'CHECK',
        Offset(checkpointX + 50, 536),
        13,
        const Color(0xFF21344C),
      );
    }

    desenharPortal(canvas);

    for (final particula in particulas) {
      canvas.drawCircle(
        Offset(particula.x, particula.y),
        4.8 * particula.vida.clamp(0.0, 1.0),
        Paint()
          ..color = particula.cor.withValues(
            alpha: particula.vida.clamp(0.0, 1.0).toDouble(),
          ),
      );
    }

    desenharPersonagem(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorOrangoAdventure oldDelegate) {
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
