
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../componentes/personagem.dart';
import '../dados/personagens.dart';
import 'tela_cidade.dart';

class SelecaoPersonagem extends StatefulWidget {
  const SelecaoPersonagem({super.key});

  @override
  State<SelecaoPersonagem> createState() =>
      _SelecaoPersonagemState();
}

class _SelecaoPersonagemState extends State<SelecaoPersonagem>
    with SingleTickerProviderStateMixin {
  final FocusNode foco = FocusNode();
  final FocusNode focoApelido = FocusNode();
  final TextEditingController apelido = TextEditingController();

  late final AnimationController animacao;

  int selecionado = 0;

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    selecionado = PersonagensOrango.opcoes.indexOf(
      PersonagensOrango.escolhido,
    );

    if (selecionado < 0) {
      selecionado = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) foco.requestFocus();
    });
  }

  @override
  void dispose() {
    animacao.dispose();
    foco.dispose();
    focoApelido.dispose();
    apelido.dispose();
    super.dispose();
  }

  void selecionar(int indice) {
    if (indice < 0 ||
        indice >= PersonagensOrango.opcoes.length) {
      return;
    }

    setState(() {
      selecionado = indice;
    });

    foco.requestFocus();
  }

  void iniciar() {
    PersonagensOrango.escolhido =
        PersonagensOrango.opcoes[selecionado];

    final nome = apelido.text.trim();

    PersonagensOrango.apelido =
        nome.isEmpty ? 'JOGADOR' : nome;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        pageBuilder: (_, animation, secondary) {
          return const TelaCidade();
        },
        transitionsBuilder: (_, animation, secondary, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  KeyEventResult teclado(
    FocusNode node,
    KeyEvent evento,
  ) {
    if (evento is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (focoApelido.hasFocus) {
      if (evento.logicalKey == LogicalKeyboardKey.escape) {
        foco.requestFocus();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    if (evento.logicalKey == LogicalKeyboardKey.arrowLeft ||
        evento.logicalKey == LogicalKeyboardKey.keyA) {
      selecionar(
        (selecionado - 1 + PersonagensOrango.opcoes.length) %
            PersonagensOrango.opcoes.length,
      );

      return KeyEventResult.handled;
    }

    if (evento.logicalKey == LogicalKeyboardKey.arrowRight ||
        evento.logicalKey == LogicalKeyboardKey.keyD) {
      selecionar(
        (selecionado + 1) %
            PersonagensOrango.opcoes.length,
      );

      return KeyEventResult.handled;
    }

    if (evento.logicalKey == LogicalKeyboardKey.enter) {
      iniciar();
      return KeyEventResult.handled;
    }

    if (evento.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget cartao(int indice) {
    final personagem = PersonagensOrango.opcoes[indice];
    final ativo = selecionado == indice;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => selecionar(indice),
        child: AnimatedScale(
          scale: ativo ? 1.045 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 210,
            height: 285,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: ativo
                    ? [
                        Color.lerp(
                          personagem.roupa,
                          const Color(0xFF1D2944),
                          0.55,
                        )!,
                        const Color(0xFF18243E),
                      ]
                    : [
                        const Color(0xFF25334C),
                        const Color(0xFF15213A),
                      ],
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: ativo
                    ? personagem.detalhe
                    : Colors.white24,
                width: ativo ? 3 : 1.5,
              ),
              boxShadow: ativo
                  ? [
                      BoxShadow(
                        color: personagem.roupa
                            .withValues(alpha: 0.45),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Colors.black38,
                        blurRadius: 15,
                      ),
                    ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      personagem.simbolo,
                      color: personagem.detalhe,
                      size: 24,
                    ),
                    const Spacer(),
                    if (ativo)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFFFD56C),
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: animacao,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            ativo
                                ? -animacao.value * 5
                                : 0,
                          ),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 130,
                        height: 155,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Personagem(
                            modelo: personagem,
                            andando: false,
                            passoAlternado: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  personagem.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  personagem.titulo,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: ativo
                        ? personagem.detalhe
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atual = PersonagensOrango.opcoes[selecionado];

    return Scaffold(
      backgroundColor: const Color(0xFF101B32),
      body: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: teclado,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: animacao,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FundoSelecao(
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
                      Color(0x770B1429),
                      Color(0xCC0B1429),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 25,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 29,
                              ),
                            ),
                            const Spacer(),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sports_esports_rounded,
                                  color: Color(0xFFFFD166),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ORANGO CITY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'ESCOLHA SEU PERSONAGEM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF202046),
                                blurRadius: 15,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'SELECIONE SEU HERÓI E EXPLORE A CIDADE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 22,
                          children: [
                            for (int i = 0;
                                i < PersonagensOrango.opcoes.length;
                                i++)
                              cartao(i),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 470,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xD91C2B45),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: atual.detalhe
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'SEU APELIDO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: apelido,
                                focusNode: focoApelido,
                                textAlign: TextAlign.center,
                                maxLength: 14,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Digite um apelido (opcional)',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFF111F35),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: atual.detalhe,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => iniciar(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 470,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: FilledButton.icon(
                              onPressed: iniciar,
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 30,
                              ),
                              label: const Text(
                                'ENTRAR NA CIDADE',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFFAB3C),
                                foregroundColor:
                                    const Color(0xFF242038),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '← → ESCOLHER     •     ENTER CONFIRMAR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundoSelecao extends CustomPainter {
  final double brilho;

  _FundoSelecao({
    required this.brilho,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF31275B),
            Color(0xFF6C467F),
            Color(0xFF263D59),
            Color(0xFF102337),
          ],
        ).createShader(area),
    );

    final centro = Offset(
      size.width * 0.5,
      size.height * 0.38,
    );

    canvas.drawCircle(
      centro,
      size.width * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(
              255,
              165,
              75,
              0.16 + brilho * 0.10,
            ),
            const Color(0x00FFA54B),
          ],
        ).createShader(
          Rect.fromCircle(
            center: centro,
            radius: size.width * 0.35,
          ),
        ),
    );

    final random = math.Random(33);

    for (int i = 0; i < 85; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      canvas.drawCircle(
        Offset(x, y),
        1.2 + random.nextDouble() * 1.7,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.25 + brilho * 0.35,
          ),
      );
    }

    final piso = Path()
      ..moveTo(0, size.height * 0.82)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      piso,
      Paint()..color = const Color(0xFF15243B),
    );

    for (double y = size.height * 0.82;
        y < size.height;
        y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0x3356A4D6)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FundoSelecao old) {
    return old.brilho != brilho;
  }
}
