
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dados/trilhas.dart';
import 'personagem.dart';

class MapaCidade extends StatelessWidget {
  static const double largura = 1600;
  static const double altura = 1000;

  static const List<Offset> estrelas = [
    Offset(380, 178),
    Offset(575, 420),
    Offset(345, 570),
    Offset(700, 580),
    Offset(1030, 300),
    Offset(1390, 305),
    Offset(1090, 550),
    Offset(1420, 580),
    Offset(920, 790),
    Offset(625, 850),
  ];

  final Offset jogador;
  final bool andando;
  final bool passoAlternado;
  final String direcao;
  final Trilha? proxima;
  final int pontos;
  final Set<int> coletadas;

  const MapaCidade({
    super.key,
    required this.jogador,
    required this.andando,
    required this.passoAlternado,
    required this.proxima,
    required this.pontos,
    this.direcao = 'baixo',
    this.coletadas = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CidadePainter(),
              ),
            ),
          ),
          for (int i = 0; i < estrelas.length; i++)
            if (!coletadas.contains(i))
              Positioned(
                left: estrelas[i].dx - 18,
                top: estrelas[i].dy - 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x88FFC247),
                    border: Border.all(
                      color: const Color(0xFFFFE9A5),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xAAFFCC55),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
          Positioned(
            left: jogador.dx - 24,
            top: jogador.dy - 57,
            child: Personagem(
              andando: andando,
              passoAlternado: passoAlternado,
              direcao: direcao,
            ),
          ),
          if (proxima != null)
            Positioned(
              left: proxima!.posicao.center.dx - 65,
              top: proxima!.posicao.bottom + 12,
              child: Container(
                width: 130,
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEE14253F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: proxima!.cor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: proxima!.cor.withValues(alpha: 0.35),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'E • JOGAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CidadePainter extends CustomPainter {
  const _CidadePainter();

  void caixa(
    Canvas canvas,
    Rect r,
    Color cor, {
    double raio = 0,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        r,
        Radius.circular(raio),
      ),
      Paint()..color = cor,
    );
  }

  void escrever(
    Canvas canvas,
    String texto,
    Offset centro,
    double tamanho,
    Color cor, {
    double largura = 230,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: cor,
          fontSize: tamanho,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Colors.black54,
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: largura);

    p.paint(
      canvas,
      Offset(
        centro.dx - p.width / 2,
        centro.dy - p.height / 2,
      ),
    );
  }

  void desenharGrama(Canvas canvas) {
    final r = const Rect.fromLTWH(0, 0, 1600, 1000);

    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF397B56),
            Color(0xFF25684B),
            Color(0xFF1F5946),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(r),
    );

    final random = math.Random(12);

    for (int i = 0; i < 950; i++) {
      final x = random.nextDouble() * 1600;
      final y = random.nextDouble() * 1000;

      caixa(
        canvas,
        Rect.fromLTWH(
          x,
          y,
          2 + random.nextDouble() * 4,
          2 + random.nextDouble() * 3,
        ),
        i % 3 == 0
            ? const Color(0xFF56A56A)
            : const Color(0xFF2E7952),
      );
    }
  }

  void desenharCaminhos(Canvas canvas) {
    final caminhos = [
      const Rect.fromLTWH(0, 257, 1600, 100),
      const Rect.fromLTWH(425, 0, 110, 1000),
      const Rect.fromLTWH(0, 665, 1600, 90),
      const Rect.fromLTWH(1135, 120, 115, 730),
    ];

    for (final r in caminhos) {
      caixa(
        canvas,
        r.inflate(5),
        const Color(0xFF947D6A),
      );

      caixa(
        canvas,
        r,
        const Color(0xFFD6C19C),
      );

      canvas.save();
      canvas.clipRect(r);

      for (double y = r.top; y < r.bottom; y += 26) {
        final alternado =
            ((y - r.top) ~/ 26).isEven ? 0.0 : 22.0;

        for (double x = r.left - 45;
            x < r.right + 45;
            x += 45) {
          caixa(
            canvas,
            Rect.fromLTWH(
              x + alternado + 2,
              y + 3,
              41,
              20,
            ),
            const Color(0xFFE3D1AD),
            raio: 2,
          );
        }
      }

      canvas.restore();
    }

    caixa(
      canvas,
      const Rect.fromLTWH(380, 215, 200, 180),
      const Color(0xFFE7D3AA),
      raio: 24,
    );
  }

  void arvore(
    Canvas canvas,
    double x,
    double y,
    double escala,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(escala);

    canvas.drawOval(
      const Rect.fromLTWH(-33, 29, 68, 17),
      Paint()..color = const Color(0x55000000),
    );

    caixa(
      canvas,
      const Rect.fromLTWH(-6, 5, 12, 38),
      const Color(0xFF73513C),
    );

    for (final p in [
      const Offset(-20, -10),
      const Offset(18, -12),
      const Offset(0, -28),
      const Offset(0, 5),
    ]) {
      canvas.drawCircle(
        p,
        24,
        Paint()..color = const Color(0xFF165B41),
      );
    }

    for (final p in [
      const Offset(-22, -20),
      const Offset(12, -26),
      const Offset(20, -5),
      const Offset(-2, -4),
    ]) {
      canvas.drawCircle(
        p,
        18,
        Paint()..color = const Color(0xFF309A5E),
      );
    }

    for (final p in [
      const Offset(-22, -29),
      const Offset(0, -39),
      const Offset(20, -18),
    ]) {
      canvas.drawCircle(
        p,
        10,
        Paint()..color = const Color(0xFF60CA7E),
      );
    }

    canvas.restore();
  }

  void poste(Canvas canvas, double x, double y) {
    canvas.drawCircle(
      Offset(x, y - 60),
      39,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x88FFE39E),
            const Color(0x00FFE39E),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(x, y - 60),
            radius: 39,
          ),
        ),
    );

    caixa(
      canvas,
      Rect.fromLTWH(x - 3, y - 53, 6, 60),
      const Color(0xFF233C50),
    );

    caixa(
      canvas,
      Rect.fromLTWH(x - 11, y - 79, 22, 30),
      const Color(0xFF203047),
      raio: 4,
    );

    caixa(
      canvas,
      Rect.fromLTWH(x - 7, y - 75, 14, 22),
      const Color(0xFFFFD58A),
      raio: 3,
    );

    caixa(
      canvas,
      Rect.fromLTWH(x - 13, y - 83, 26, 5),
      const Color(0xFF17283F),
      raio: 2,
    );
  }

  void banco(Canvas canvas, double x, double y) {
    canvas.drawOval(
      Rect.fromLTWH(x, y + 17, 58, 11),
      Paint()..color = Colors.black26,
    );

    for (int i = 0; i < 3; i++) {
      caixa(
        canvas,
        Rect.fromLTWH(x, y + i * 6.0, 57, 5),
        const Color(0xFFA66A43),
        raio: 2,
      );
    }

    caixa(
      canvas,
      Rect.fromLTWH(x + 7, y + 17, 5, 10),
      const Color(0xFF283C4C),
    );

    caixa(
      canvas,
      Rect.fromLTWH(x + 45, y + 17, 5, 10),
      const Color(0xFF283C4C),
    );
  }

  void predio(Canvas canvas, Trilha trilha) {
    final r = trilha.posicao;

    caixa(
      canvas,
      r.shift(const Offset(8, 12)),
      const Color(0x66000000),
      raio: 12,
    );

    caixa(
      canvas,
      r,
      const Color(0xFFD7C9B5),
      raio: 10,
    );

    caixa(
      canvas,
      Rect.fromLTWH(
        r.left + 8,
        r.top + 36,
        r.width - 16,
        r.height - 40,
      ),
      const Color(0xFFB9CBD0),
      raio: 6,
    );

    for (final wx in [
      r.left + 22,
      r.right - 67,
    ]) {
      caixa(
        canvas,
        Rect.fromLTWH(
          wx,
          r.top + 65,
          45,
          44,
        ),
        const Color(0xFF3F5A82),
        raio: 3,
      );

      caixa(
        canvas,
        Rect.fromLTWH(
          wx + 4,
          r.top + 69,
          37,
          36,
        ),
        const Color(0xFF7DCAEB),
        raio: 2,
      );

      caixa(
        canvas,
        Rect.fromLTWH(
          wx + 19,
          r.top + 69,
          3,
          36,
        ),
        const Color(0xFFDBF7FF),
      );
    }

    caixa(
      canvas,
      Rect.fromLTWH(
        r.center.dx - 24,
        r.bottom - 43,
        48,
        43,
      ),
      const Color(0xFF47384C),
      raio: 3,
    );

    caixa(
      canvas,
      Rect.fromLTWH(
        r.center.dx - 20,
        r.bottom - 38,
        40,
        38,
      ),
      const Color(0xFF9C6846),
      raio: 2,
    );

    caixa(
      canvas,
      Rect.fromLTWH(
        r.center.dx - 2,
        r.bottom - 38,
        4,
        38,
      ),
      const Color(0xFF533A42),
    );

    final teto = Path()
      ..moveTo(r.left - 9, r.top + 42)
      ..lineTo(r.left + 8, r.top - 10)
      ..lineTo(r.right - 8, r.top - 10)
      ..lineTo(r.right + 9, r.top + 42)
      ..close();

    canvas.drawPath(
      teto,
      Paint()
        ..color = Color.lerp(
          trilha.cor,
          const Color(0xFF13254E),
          0.35,
        )!,
    );

    caixa(
      canvas,
      Rect.fromLTWH(
        r.left + 16,
        r.top - 5,
        r.width - 32,
        47,
      ),
      const Color(0xFF162A4C),
      raio: 6,
    );

    caixa(
      canvas,
      Rect.fromLTWH(
        r.left + 20,
        r.top - 1,
        r.width - 40,
        39,
      ),
      trilha.cor,
      raio: 4,
    );

    escrever(
      canvas,
      trilha.nome,
      Offset(r.center.dx, r.top + 19),
      trilha.nome.length > 16 ? 13 : 18,
      Colors.white,
      largura: r.width - 46,
    );
  }

  void fonte(Canvas canvas) {
    const centro = Offset(480, 300);

    canvas.drawOval(
      const Rect.fromLTWH(425, 346, 110, 18),
      Paint()..color = Colors.black26,
    );

    canvas.drawCircle(
      centro,
      54,
      Paint()..color = const Color(0xFF536F87),
    );

    canvas.drawCircle(
      centro,
      48,
      Paint()..color = const Color(0xFFE8E8DA),
    );

    canvas.drawCircle(
      centro,
      39,
      Paint()..color = const Color(0xFF358BC1),
    );

    canvas.drawCircle(
      centro,
      30,
      Paint()..color = const Color(0xFF73D6ED),
    );

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        centro,
        15 + i * 8.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    caixa(
      canvas,
      const Rect.fromLTWH(477, 269, 6, 30),
      const Color(0xFFE9FAFF),
      raio: 3,
    );
  }

  void parque(Canvas canvas) {
    escrever(
      canvas,
      'JARDIM DAS IDEIAS',
      const Offset(1360, 155),
      26,
      const Color(0xFFFFE7A3),
      largura: 320,
    );

    caixa(
      canvas,
      const Rect.fromLTWH(1010, 390, 490, 120),
      const Color(0xFF3A875D),
      raio: 30,
    );

    for (int i = 0; i < 9; i++) {
      final x = 1030.0 + i * 51;

      canvas.drawCircle(
        Offset(x, 450),
        14,
        Paint()
          ..color = i.isEven
              ? const Color(0xFF62BF7A)
              : const Color(0xFF3B9D68),
      );

      canvas.drawCircle(
        Offset(x + 5, 444),
        4,
        Paint()
          ..color = const Color(0xFFFFD47B),
      );
    }

    escrever(
      canvas,
      'PARQUE ORANGO',
      const Offset(1280, 925),
      27,
      const Color(0xFFFFE7A3),
      largura: 300,
    );

    final lago = Rect.fromCenter(
      center: const Offset(1280, 850),
      width: 230,
      height: 145,
    );

    canvas.drawOval(
      lago.inflate(12),
      Paint()..color = const Color(0xFFB6A47B),
    );

    canvas.drawOval(
      lago,
      Paint()..color = const Color(0xFF358FC1),
    );

    canvas.drawOval(
      lago.deflate(13),
      Paint()..color = const Color(0xFF5BC4DD),
    );

    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(1230 + i * 30.0, 850),
          width: 33,
          height: 20,
        ),
        0,
        math.pi,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void vegetacao(Canvas canvas) {
    final posicoes = <Offset>[
      const Offset(40, 90),
      const Offset(350, 105),
      const Offset(570, 105),
      const Offset(915, 90),
      const Offset(40, 415),
      const Offset(350, 420),
      const Offset(570, 420),
      const Offset(915, 425),
      const Offset(45, 560),
      const Offset(190, 570),
      const Offset(820, 570),
      const Offset(935, 555),
      const Offset(75, 840),
      const Offset(190, 890),
      const Offset(340, 900),
      const Offset(720, 900),
      const Offset(840, 900),
      const Offset(990, 880),
      const Offset(1080, 900),
      const Offset(1470, 900),
      const Offset(1540, 810),
      const Offset(1030, 160),
      const Offset(1100, 170),
      const Offset(1310, 90),
      const Offset(1450, 105),
      const Offset(1550, 185),
      const Offset(1550, 430),
      const Offset(1030, 430),
      const Offset(1080, 620),
      const Offset(1500, 610),
    ];

    for (int i = 0; i < posicoes.length; i++) {
      arvore(
        canvas,
        posicoes[i].dx,
        posicoes[i].dy,
        i % 4 == 0 ? 1.15 : 0.85,
      );
    }

    for (final p in [
      const Offset(365, 245),
      const Offset(570, 245),
      const Offset(365, 387),
      const Offset(570, 387),
      const Offset(1070, 260),
      const Offset(1470, 260),
      const Offset(1080, 660),
      const Offset(1470, 660),
    ]) {
      poste(canvas, p.dx, p.dy);
    }

    for (final p in [
      const Offset(330, 235),
      const Offset(560, 225),
      const Offset(330, 380),
      const Offset(560, 380),
      const Offset(1010, 530),
      const Offset(1420, 530),
      const Offset(910, 785),
      const Offset(1050, 800),
    ]) {
      banco(canvas, p.dx, p.dy);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    desenharGrama(canvas);
    desenharCaminhos(canvas);
    parque(canvas);

    for (final trilha in trilhasOrango) {
      predio(canvas, trilha);
    }

    fonte(canvas);
    vegetacao(canvas);

    escrever(
      canvas,
      'ORANGO CITY',
      const Offset(790, 70),
      34,
      const Color(0xFFFFD47B),
      largura: 390,
    );

    escrever(
      canvas,
      'PRAÇA DO CONHECIMENTO',
      const Offset(480, 570),
      18,
      Colors.white,
      largura: 350,
    );
  }

  @override
  bool shouldRepaint(covariant _CidadePainter old) {
    return false;
  }
}
