
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados/personagens.dart';
import 'tela_ranking.dart';

class TelaFinalOrango extends StatefulWidget {
  final int pontos;
  final int desafiosConcluidos;
  final String nomeJogador;
  final VoidCallback? aoSair;

  const TelaFinalOrango({
    super.key,
    required this.pontos,
    required this.desafiosConcluidos,
    this.nomeJogador = 'JOGADOR',
    this.aoSair,
  });

  @override
  State<TelaFinalOrango> createState() => _TelaFinalOrangoState();
}

class _TelaFinalOrangoState extends State<TelaFinalOrango>
    with SingleTickerProviderStateMixin {
  static const String endereco = 'https://orango.senac.br/';

  static const Color fundo = Color(0xFF101A30);
  static const Color cartao = Color(0xFF1C2D49);
  static const Color laranja = Color(0xFFFFB347);
  static const Color amarelo = Color(0xFFFFD166);
  static const Color verde = Color(0xFF91F0BB);

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

  Future<void> acessarOrango() async {
    try {
      final abriu = await launchUrl(
        Uri.parse(endereco),
        mode: LaunchMode.externalApplication,
      );

      if (!abriu) {
        throw Exception('Não foi possível abrir');
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acesse https://orango.senac.br/',
          ),
        ),
      );
    }
  }

  void abrirRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TelaRanking(),
      ),
    );
  }

  void sair() {
    if (widget.aoSair != null) {
      widget.aoSair!();
      return;
    }

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  Widget construirJogador() {
    return Container(
      width: 440,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: cartao,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF536789),
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 65,
            child: CustomPaint(
              painter: _AvatarOrango(
                roupa: PersonagensOrango.escolhido.roupa,
                pele: PersonagensOrango.escolhido.pele,
                cabelo: PersonagensOrango.escolhido.cabelo,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nomeJogador.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.desafiosConcluidos} de 4 desafios concluídos',
                  style: const TextStyle(
                    color: Color(0xFFB4C3DB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.bolt_rounded,
            color: amarelo,
            size: 29,
          ),
          const SizedBox(width: 3),
          Text(
            '${widget.pontos} XP',
            style: const TextStyle(
              color: amarelo,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget construirQRCode() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF263A59),
            Color(0xFF17243E),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: laranja,
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: animacao,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: laranja.withValues(
                    alpha: 0.09 + animacao.value * 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 39,
                  color: amarelo,
                  shadows: [
                    Shadow(
                      color: laranja.withValues(
                        alpha: animacao.value * 0.6,
                      ),
                      blurRadius: 17,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 13),
          const Text(
            'RECEBA SUA RECOMPENSA!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Descubra cursos gratuitos no Orango por Senac!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD1DCEF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 21),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
            ),
            child: QrImageView(
              data: endereco,
              version: QrVersions.auto,
              size: 212,
              gapless: true,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 19),
          const Text(
            'orango.senac.br',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: amarelo,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ESCANEIE E COMECE A APRENDER!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD5DFEF),
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: acessarOrango,
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 22,
              ),
              label: const Text(
                'ACESSAR O ORANGO',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: laranja,
                foregroundColor: const Color(0xFF192941),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirBotoes() {
    return Column(
      children: [
        SizedBox(
          width: 340,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: abrirRanking,
            icon: const Icon(
              Icons.emoji_events_rounded,
              color: amarelo,
            ),
            label: const Text(
              'VER RANKING DO EVENTO',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: amarelo,
                width: 1.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: sair,
          icon: const Icon(
            Icons.home_rounded,
            size: 18,
          ),
          label: const Text(
            'VOLTAR AO MENU',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFAFBED5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.3,
                colors: [
                  Color(0xFF31436C),
                  Color(0xFF17253F),
                  Color(0xFF0D172B),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animacao,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FundoEstrelas(animacao.value),
                );
              },
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0,
                        constraints.maxHeight - 48,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ORANGO CITY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: laranja,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'VOCÊ COMPLETOU SUA AVENTURA!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 21),
                          construirJogador(),
                          const SizedBox(height: 23),
                          construirQRCode(),
                          const SizedBox(height: 21),
                          construirBotoes(),
                          const SizedBox(height: 10),
                          const Text(
                            'ORANGO POR SENAC • APRENDER DO SEU JEITO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8190A9),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarOrango extends CustomPainter {
  final Color roupa;
  final Color pele;
  final Color cabelo;

  const _AvatarOrango({
    required this.roupa,
    required this.pele,
    required this.cabelo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(
      size.width / 58,
      size.height / 65,
    );

    final sombra = Paint()
      ..color = Colors.black.withValues(alpha: 0.30);

    final roupaPaint = Paint()..color = roupa;
    final pelePaint = Paint()..color = pele;
    final cabeloPaint = Paint()..color = cabelo;
    final calcaPaint = Paint()
      ..color = const Color(0xFF263957);

    canvas.drawOval(
      const Rect.fromLTWH(7, 57, 44, 7),
      sombra,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 45, 12, 14),
        const Radius.circular(3),
      ),
      calcaPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(33, 45, 12, 14),
        const Radius.circular(3),
      ),
      calcaPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 27, 43, 26),
        const Radius.circular(8),
      ),
      roupaPaint,
    );

    canvas.drawCircle(
      const Offset(29, 21),
      18,
      pelePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: const Offset(29, 18),
        radius: 18,
      ),
      math.pi,
      math.pi,
      false,
      cabeloPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );

    canvas.drawCircle(
      const Offset(35, 22),
      2.5,
      Paint()..color = const Color(0xFF27334B),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 38, 11, 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFD166),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarOrango antigo) {
    return antigo.roupa != roupa ||
        antigo.pele != pele ||
        antigo.cabelo != cabelo;
  }
}

class _FundoEstrelas extends CustomPainter {
  final double animacao;

  _FundoEstrelas(this.animacao);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    for (int i = 0; i < 48; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final brilho =
          0.13 +
          ((math.sin(animacao * math.pi * 2 + i) + 1) / 2) *
              0.35;

      canvas.drawCircle(
        Offset(x, y),
        1 + i % 3,
        Paint()
          ..color = const Color(0xFFFFD166)
              .withValues(alpha: brilho),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FundoEstrelas antigo) {
    return antigo.animacao != animacao;
  }
}
