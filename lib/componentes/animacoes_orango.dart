
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BrilhosCidade extends StatelessWidget {
  final Animation<double> animacao;
  final List<Offset> estrelas;
  final Set<int> coletadas;
  final Rect? predioProximo;

  const BrilhosCidade({
    super.key,
    required this.animacao,
    required this.estrelas,
    required this.coletadas,
    required this.predioProximo,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PintorBrilhos(
          animacao: animacao,
          estrelas: estrelas,
          coletadas: coletadas,
          predio: predioProximo,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PintorBrilhos extends CustomPainter {
  final Animation<double> animacao;
  final List<Offset> estrelas;
  final Set<int> coletadas;
  final Rect? predio;

  _PintorBrilhos({
    required this.animacao,
    required this.estrelas,
    required this.coletadas,
    required this.predio,
  }) : super(repaint: animacao);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animacao.value * math.pi * 2;

    for (int i = 0; i < estrelas.length; i++) {
      if (coletadas.contains(i)) continue;

      final posicao = estrelas[i];
      final pulso = (math.sin(t + i * 0.7) + 1) / 2;
      final raio = 21.0 + pulso * 13;

      canvas.drawCircle(
        posicao,
        raio,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.fromRGBO(
                255,
                220,
                105,
                0.28 + pulso * 0.15,
              ),
              const Color(0x00FFD166),
            ],
          ).createShader(
            Rect.fromCircle(
              center: posicao,
              radius: raio,
            ),
          ),
      );

      canvas.drawCircle(
        posicao,
        15 + pulso * 4,
        Paint()
          ..color = const Color(0xFFFFE29B)
              .withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      for (int j = 0; j < 4; j++) {
        final angulo = t * 0.25 + j * math.pi / 2;

        final p = posicao +
            Offset(
              math.cos(angulo) * (24 + pulso * 5),
              math.sin(angulo) * (24 + pulso * 5),
            );

        canvas.drawCircle(
          p,
          2.0 + pulso,
          Paint()
            ..color = const Color(0xFFFFE9AE)
                .withValues(alpha: 0.85),
        );
      }
    }

    if (predio != null) {
      final pulso = (math.sin(t) + 1) / 2;
      final area = predio!.inflate(7 + pulso * 5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          area,
          const Radius.circular(18),
        ),
        Paint()
          ..color = Color.fromRGBO(
            255,
            224,
            115,
            0.40 + pulso * 0.45,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      final centro = Offset(
        predio!.center.dx,
        predio!.bottom + 13,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: centro,
          width: 58 + pulso * 16,
          height: 14 + pulso * 4,
        ),
        Paint()
          ..color = Color.fromRGBO(
            255,
            220,
            105,
            0.15 + pulso * 0.20,
          ),
      );

      for (int i = 0; i < 5; i++) {
        final x = predio!.left +
            15 +
            (i + 0.5) * (predio!.width - 30) / 5;

        final y = predio!.top -
            12 -
            (math.sin(t + i) + 1) * 10;

        canvas.drawCircle(
          Offset(x, y),
          2.5,
          Paint()
            ..color = const Color(0xFFFFE8AA)
                .withValues(alpha: 0.8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorBrilhos old) {
    return old.predio != predio ||
        old.coletadas != coletadas ||
        old.estrelas != estrelas;
  }
}

class AvisoXp extends StatelessWidget {
  final int quantidade;
  final int evento;

  const AvisoXp({
    super.key,
    required this.quantidade,
    required this.evento,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.45),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            ),
          );
        },
        child: quantidade <= 0
            ? const SizedBox.shrink(
                key: ValueKey('sem_xp'),
              )
            : Container(
                key: ValueKey(evento),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEE152A42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD166),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x77FFC857),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFFFD166),
                      size: 30,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+$quantidade XP',
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ChuvaConfetes extends StatefulWidget {
  const ChuvaConfetes({super.key});

  @override
  State<ChuvaConfetes> createState() =>
      _ChuvaConfetesState();
}

class _ChuvaConfetesState extends State<ChuvaConfetes>
    with SingleTickerProviderStateMixin {
  late final AnimationController animacao;

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
  }

  @override
  void dispose() {
    animacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PintorConfetes(animacao),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PintorConfetes extends CustomPainter {
  final Animation<double> animacao;

  _PintorConfetes(this.animacao)
      : super(repaint: animacao);

  static const cores = [
    Color(0xFFFFD166),
    Color(0xFF55DDB7),
    Color(0xFF69BBFF),
    Color(0xFFED8CFF),
    Color(0xFFFF8C6D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final aleatorio = math.Random(42);
    final tempo = animacao.value;

    for (int i = 0; i < 85; i++) {
      final xInicial =
          aleatorio.nextDouble() * size.width;

      final atraso =
          aleatorio.nextDouble() * 0.50;

      final velocidade =
          0.65 + aleatorio.nextDouble() * 0.65;

      final fase =
          ((tempo - atraso) * velocidade).clamp(0.0, 1.0);

      if (fase <= 0 || fase >= 1) continue;

      final ondulacao = math.sin(
            tempo * 13 + i.toDouble(),
          ) *
          22;

      final x = xInicial + ondulacao;
      final y = -25 + fase * (size.height + 50);

      final largura = 4 + aleatorio.nextDouble() * 7;
      final altura = 7 + aleatorio.nextDouble() * 8;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(tempo * 9 + i);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: largura,
            height: altura,
          ),
          const Radius.circular(2),
        ),
        Paint()
          ..color = cores[i % cores.length]
              .withValues(alpha: 0.90),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorConfetes old) {
    return old.animacao.value != animacao.value;
  }
}
