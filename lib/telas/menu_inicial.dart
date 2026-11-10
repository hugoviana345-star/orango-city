import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'selecao_personagem.dart';
import 'tela_ranking.dart';

class MenuInicial extends StatefulWidget {
  const MenuInicial({super.key});

  @override
  State<MenuInicial> createState() => _MenuInicialState();
}

class _MenuInicialState extends State<MenuInicial>
    with SingleTickerProviderStateMixin {
  late final AnimationController animacao;

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animacao.dispose();
    super.dispose();
  }

  void iniciarJogo() {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, secondaryAnimation) {
          return const SelecaoPersonagem();
        },
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void abrirRanking() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const TelaRanking(),
      ),
    );
  }

  void abrirInformacoes(bool comoJogar) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF293C61),
                  Color(0xFF111C36),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 30,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    comoJogar
                        ? Icons.sports_esports_rounded
                        : Icons.school_rounded,
                    color: const Color(0xFFFFC869),
                    size: 53,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comoJogar ? 'COMO JOGAR' : 'SOBRE O ORANGO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 19),
                  if (comoJogar) ...[
                    const _LinhaAjuda(
                      Icons.keyboard_rounded,
                      'WASD ou setas',
                      'Movimentar o personagem',
                    ),
                    const _LinhaAjuda(
                      Icons.login_rounded,
                      'Tecla E',
                      'Entrar nos edifícios',
                    ),
                    const _LinhaAjuda(
                      Icons.sports_esports_rounded,
                      'Desafios',
                      'Complete os minigames',
                    ),
                    const _LinhaAjuda(
                      Icons.bolt_rounded,
                      'Ganhe XP',
                      'Acumule pontos nas missões',
                    ),
                  ] else ...[
                    const Text(
                      'O Orango é uma plataforma de cursos online gratuitos do Senac.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Explore a cidade, descubra áreas profissionais e participe de desafios divertidos!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'orango.senac.br',
                      style: TextStyle(
                        fontSize: 19,
                        color: Color(0xFFFFC869),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA63D),
                        foregroundColor: const Color(0xFF292138),
                      ),
                      child: const Text(
                        'ENTENDI',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A38),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;
          final altura = constraints.maxHeight;

          final escala = math
              .min(
                largura / 1050,
                altura / 780,
              )
              .clamp(0.65, 1.20)
              .toDouble();

          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: animacao,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(largura, altura),
                    painter: _CenarioOrango(
                      brilho: animacao.value,
                    ),
                  );
                },
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x180C112B),
                        Color(0x220D1530),
                        Color(0x770D142A),
                      ],
                      stops: [0, 0.52, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 55,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 430 * escala,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: animacao,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  -5 * animacao.value,
                                ),
                                child: child,
                              );
                            },
                            child: _LogoOrango(
                              escala: escala,
                            ),
                          ),
                          SizedBox(height: 20 * escala),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15 * escala,
                              vertical: 12 * escala,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xC9142341),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                            child: Text(
                              'EXPLORE • JOGUE • DESCUBRA\nSEU PRÓXIMO CURSO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15 * escala,
                                height: 1.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          SizedBox(height: 30 * escala),
                          _BotaoMenu(
                            titulo: 'INICIAR JOGO',
                            icone: Icons.play_arrow_rounded,
                            principal: true,
                            escala: escala,
                            acao: iniciarJogo,
                          ),
                          SizedBox(height: 12 * escala),
                          _BotaoMenu(
                            titulo: 'COMO JOGAR',
                            icone: Icons.sports_esports_rounded,
                            escala: escala,
                            acao: () => abrirInformacoes(true),
                          ),
                          SizedBox(height: 12 * escala),
                          _BotaoMenu(
                            titulo: 'SOBRE O ORANGO',
                            icone: Icons.info_rounded,
                            escala: escala,
                            acao: () => abrirInformacoes(false),
                          ),
                          SizedBox(height: 12 * escala),
                          _BotaoMenu(
                            titulo: 'RANKING TOP 10',
                            icone: Icons.emoji_events_rounded,
                            escala: escala,
                            acao: abrirRanking,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'orango',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25 * escala,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Educação gratuita\npara o seu futuro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13 * escala,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoOrango extends StatelessWidget {
  final double escala;

  const _LogoOrango({
    required this.escala,
  });

  Widget textoContornado(
    String texto,
    double tamanho,
    Color cor,
  ) {
    final estilo = TextStyle(
      fontSize: tamanho * escala,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
      height: 1.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          texto,
          style: estilo.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9 * escala
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF292052),
          ),
        ),
        Text(
          texto,
          style: estilo.copyWith(
            color: cor,
            shadows: [
              const Shadow(
                color: Color(0xFF4B285C),
                offset: Offset(3, 5),
                blurRadius: 4,
              ),
              Shadow(
                color: cor.withValues(alpha: 0.35),
                blurRadius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.eco_rounded,
          size: 39 * escala,
          color: const Color(0xFF8EED7E),
          shadows: const [
            Shadow(
              color: Color(0xFF164D38),
              blurRadius: 8,
            ),
          ],
        ),
        textoContornado(
          'ORANGO',
          76,
          const Color(0xFFFFAB3D),
        ),
        Transform.translate(
          offset: Offset(0, -4 * escala),
          child: textoContornado(
            'CITY',
            65,
            Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BotaoMenu extends StatefulWidget {
  final String titulo;
  final IconData icone;
  final VoidCallback acao;
  final bool principal;
  final double escala;

  const _BotaoMenu({
    required this.titulo,
    required this.icone,
    required this.acao,
    required this.escala,
    this.principal = false,
  });

  @override
  State<_BotaoMenu> createState() => _BotaoMenuState();
}

class _BotaoMenuState extends State<_BotaoMenu> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final principal = widget.principal;
    final s = widget.escala;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.045 : 1,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          height: (principal ? 65 : 55) * s,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: principal
                  ? [
                      const Color(0xFFFFDA74),
                      hover
                          ? const Color(0xFFFFBE50)
                          : const Color(0xFFFF9438),
                    ]
                  : [
                      hover
                          ? const Color(0xFF395580)
                          : const Color(0xF025385B),
                      const Color(0xF0131F3C),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: principal
                  ? const Color(0xFFFFF0B1)
                  : hover
                      ? const Color(0xFF8CCAFF)
                      : const Color(0xFF64799E),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: principal
                    ? const Color(0x77FF9E35)
                    : hover
                        ? const Color(0x553B94FF)
                        : Colors.black54,
                blurRadius: hover ? 24 : 13,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.acao,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icone,
                      size: (principal ? 29 : 24) * s,
                      color: principal
                          ? const Color(0xFF29213B)
                          : Colors.white,
                    ),
                    SizedBox(width: 13 * s),
                    Flexible(
                      child: Text(
                        widget.titulo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (principal ? 19 : 16) * s,
                          color: principal
                              ? const Color(0xFF29213B)
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinhaAjuda extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _LinhaAjuda(
    this.icone,
    this.titulo,
    this.descricao,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icone,
            size: 28,
            color: const Color(0xFFFFC869),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenarioOrango extends CustomPainter {
  final double brilho;

  _CenarioOrango({
    required this.brilho,
  });

  void caixa(
    Canvas canvas,
    Rect area,
    Color cor, {
    double raio = 0,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        area,
        Radius.circular(raio),
      ),
      Paint()..color = cor,
    );
  }

  void desenharArvore(
    Canvas canvas,
    double x,
    double y,
    double escala,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(escala);

    canvas.drawOval(
      const Rect.fromLTWH(-48, 25, 96, 20),
      Paint()..color = const Color(0x66000000),
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-9, -10, 18, 55),
      const Color(0xFF574039),
    );

    const folhas = [
      Offset(-32, -37),
      Offset(0, -58),
      Offset(30, -36),
      Offset(-18, -13),
      Offset(18, -13),
    ];

    for (final p in folhas) {
      canvas.drawCircle(
        p,
        34,
        Paint()..color = const Color(0xFF16483F),
      );
    }

    for (final p in const [
      Offset(-29, -47),
      Offset(-2, -69),
      Offset(29, -48),
      Offset(-13, -24),
      Offset(14, -25),
    ]) {
      canvas.drawCircle(
        p,
        26,
        Paint()..color = const Color(0xFF297D5C),
      );
    }

    for (final p in const [
      Offset(-40, -55),
      Offset(-15, -79),
      Offset(20, -68),
      Offset(37, -37),
    ]) {
      canvas.drawCircle(
        p,
        15,
        Paint()..color = const Color(0xFF43A56D),
      );
    }

    canvas.restore();
  }

  void desenharPoste(
    Canvas canvas,
    double x,
    double y,
    double escala,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(escala);

    const centro = Offset(0, -83);

    canvas.drawCircle(
      centro,
      60,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(
              255,
              216,
              125,
              0.35 + brilho * 0.16,
            ),
            const Color(0x00FFD47A),
          ],
        ).createShader(
          Rect.fromCircle(
            center: centro,
            radius: 60,
          ),
        ),
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-4, -68, 8, 69),
      const Color(0xFF1B2940),
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-12, -99, 24, 34),
      const Color(0xFF253047),
      raio: 4,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-8, -94, 16, 25),
      const Color(0xFFFFD888),
      raio: 3,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-15, -103, 30, 6),
      const Color(0xFF17233D),
      raio: 3,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-12, 0, 24, 7),
      const Color(0xFF17233D),
      raio: 3,
    );

    canvas.restore();
  }

  void desenharPredios(Canvas canvas) {
    for (int camada = 0; camada < 2; camada++) {
      for (int i = 0; i < 21; i++) {
        final x = i * 50.0 - 17;
        final altura = 83.0 + ((i * 37 + camada * 29) % 110);
        final y = 345 - altura + camada * 24.0;
        final largura = 38.0 + (i % 3) * 8;

        caixa(
          canvas,
          Rect.fromLTWH(
            x,
            y,
            largura,
            altura + 50,
          ),
          camada == 0
              ? const Color(0xFF51426C)
              : const Color(0xFF303551),
        );

        if (camada == 1) {
          for (double wy = y + 12; wy < 345; wy += 19) {
            for (double wx = x + 8; wx < x + largura - 5; wx += 14) {
              caixa(
                canvas,
                Rect.fromLTWH(wx, wy, 6, 9),
                (i + wx.toInt() + wy.toInt()) % 4 == 0
                    ? const Color(0xFFB2A1AF)
                    : const Color(0xFFFFC88B),
              );
            }
          }
        }
      }
    }
  }

  void desenharCaminho(Canvas canvas) {
    final caminho = Path()
      ..moveTo(370, 337)
      ..lineTo(590, 337)
      ..lineTo(960, 600)
      ..lineTo(0, 600)
      ..close();

    canvas.drawPath(
      caminho,
      Paint()..color = const Color(0xFF705479),
    );

    canvas.save();
    canvas.clipPath(caminho);

    for (double y = 340; y < 625;) {
      final t = ((y - 337) / 263).clamp(0.0, 1.0);

      canvas.drawLine(
        Offset(0, y),
        Offset(960, y),
        Paint()
          ..color = const Color(0x99503D69)
          ..strokeWidth = 2,
      );

      y += 13 + t * 27;
    }

    for (int i = 0; i <= 14; i++) {
      final f = i / 14;

      canvas.drawLine(
        Offset(370 + f * 220, 337),
        Offset(f * 960, 600),
        Paint()
          ..color = const Color(0x77503D69)
          ..strokeWidth = 2,
      );
    }

    canvas.restore();

    for (final linha in const [
      [
        Offset(370, 337),
        Offset(0, 600),
      ],
      [
        Offset(590, 337),
        Offset(960, 600),
      ],
    ]) {
      canvas.drawLine(
        linha[0],
        linha[1],
        Paint()
          ..color = const Color(0xFFC99DA4)
          ..strokeWidth = 5,
      );
    }
  }

  void desenharCena(Canvas canvas) {
    const tamanho = Size(960, 600);
    final area = Offset.zero & tamanho;

    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF231B50),
            Color(0xFF604074),
            Color(0xFFCB6A83),
            Color(0xFFFFB275),
            Color(0xFF38445D),
          ],
          stops: [
            0,
            0.25,
            0.55,
            0.78,
            1,
          ],
        ).createShader(area),
    );

    canvas.drawCircle(
      const Offset(480, 300),
      168,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0x77FFE2A2),
            Color(0x00FFE2A2),
          ],
        ).createShader(
          const Rect.fromLTWH(
            312,
            132,
            336,
            336,
          ),
        ),
    );

    for (int i = 0; i < 48; i++) {
      final x = ((i * 139 + 23) % 960).toDouble();
      final y = ((i * 79 + 17) % 235).toDouble();

      canvas.drawCircle(
        Offset(x, y),
        i.isEven ? 1.4 : 1.9,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.30 + brilho * 0.45,
          ),
      );
    }

    for (int i = 0; i < 8; i++) {
      final x = i * 135.0 - 40;
      final y = 95.0 + (i % 3) * 35;

      canvas.drawOval(
        Rect.fromLTWH(x, y, 145, 29),
        Paint()..color = const Color(0x336A518B),
      );

      canvas.drawOval(
        Rect.fromLTWH(x + 25, y - 11, 92, 33),
        Paint()..color = const Color(0x225A4B85),
      );
    }

    desenharPredios(canvas);

    caixa(
      canvas,
      const Rect.fromLTWH(0, 355, 960, 245),
      const Color(0xFF203D42),
    );

    for (final p in const [
      Offset(10, 420),
      Offset(85, 395),
      Offset(160, 365),
      Offset(795, 365),
      Offset(875, 395),
      Offset(950, 420),
    ]) {
      desenharArvore(
        canvas,
        p.dx,
        p.dy,
        0.75,
      );
    }

    desenharCaminho(canvas);

    for (final p in const [
      Offset(85, 480),
      Offset(185, 420),
      Offset(285, 380),
      Offset(675, 380),
      Offset(775, 420),
      Offset(875, 480),
    ]) {
      desenharPoste(
        canvas,
        p.dx,
        p.dy,
        0.85,
      );
    }

    for (final p in const [
      Offset(8, 590),
      Offset(80, 570),
      Offset(180, 535),
      Offset(950, 590),
      Offset(880, 570),
      Offset(780, 535),
    ]) {
      desenharArvore(
        canvas,
        p.dx,
        p.dy,
        1.20,
      );
    }

    for (int i = 0; i < 26; i++) {
      final x = (i * 183 + 35) % 960;
      final y = 340 + ((i * 47) % 225);

      if (x > 315 && x < 645) continue;

      final alpha = 0.35 + 0.45 * math.sin(brilho * math.pi / 2);

      canvas.drawCircle(
        Offset(
          x.toDouble(),
          y.toDouble(),
        ),
        2.4,
        Paint()
          ..color = const Color(0xFFFFD77C).withValues(
            alpha: alpha,
          ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const larguraBase = 960.0;
    const alturaBase = 600.0;

    final escala = math.max(
      size.width / larguraBase,
      size.height / alturaBase,
    );

    final larguraFinal = larguraBase * escala;
    final alturaFinal = alturaBase * escala;

    final deslocamentoX = (size.width - larguraFinal) / 2;
    final deslocamentoY = (size.height - alturaFinal) / 2;

    canvas.save();

    canvas.translate(
      deslocamentoX,
      deslocamentoY,
    );

    canvas.scale(escala);

    desenharCena(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CenarioOrango oldDelegate) {
    return oldDelegate.brilho != brilho;
  }
}