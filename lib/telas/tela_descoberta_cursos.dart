
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../componentes/personagem.dart';
import '../dados/personagens.dart';
import 'tela_ranking.dart';

class TelaDescobertaCursos extends StatefulWidget {
  final int pontos;
  final List<int> melhoresMinigames;
  final String destaqueId;

  const TelaDescobertaCursos({
    super.key,
    required this.pontos,
    required this.melhoresMinigames,
    required this.destaqueId,
  });

  @override
  State<TelaDescobertaCursos> createState() =>
      _TelaDescobertaCursosState();
}

class _TelaDescobertaCursosState
    extends State<TelaDescobertaCursos>
    with SingleTickerProviderStateMixin {
  static const String siteOrango =
      'https://orango.senac.br/';

  static const Color laranja = Color(0xFFFFAA3E);
  static const Color amarelo = Color(0xFFFFD56D);

  late final AnimationController animacao;

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    animacao.dispose();
    super.dispose();
  }

  int get desafiosPontuados {
    return widget.melhoresMinigames
        .where((pontos) => pontos > 0)
        .length;
  }

  Future<void> abrirOrango() async {
    try {
      final uri = Uri.parse(siteOrango);

      final abriu = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abriu) {
        throw Exception('Não foi possível abrir.');
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o Orango. Acesse orango.senac.br',
          ),
        ),
      );
    }
  }

  void abrirRanking() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TelaRanking(
          destaqueId: widget.destaqueId,
        ),
      ),
    );
  }

  Widget beneficio(
    IconData icone,
    String titulo,
    String descricao,
    Color cor,
  ) {
    return Container(
      width: 214,
      height: 94,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3554),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: cor.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 27,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget seloArea(
    IconData icone,
    String titulo,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: cor.withValues(alpha: 0.48),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            color: cor,
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget painelApresentacao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF263C60),
            Color(0xFF152943),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFF526B95),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: laranja.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: laranja.withValues(alpha: 0.50),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: amarelo,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'MISSÃO CONCLUÍDA!',
                  style: TextStyle(
                    color: amarelo,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          const Text(
            'O JOGO TERMINOU.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const Text(
            'A DESCOBERTA CONTINUA!',
            style: TextStyle(
              color: laranja,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Conheça o Orango por Senac: uma plataforma para descobrir novas habilidades, explorar seus interesses e aprender do seu jeito.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'O QUE VOCÊ ENCONTRA NO ORANGO?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              beneficio(
                Icons.card_giftcard_rounded,
                '100% GRATUITO',
                'Sem mensalidade',
                const Color(0xFF75E8AE),
              ),
              beneficio(
                Icons.devices_rounded,
                'CURSOS ONLINE',
                'Estude pela internet',
                const Color(0xFF79C9FF),
              ),
              beneficio(
                Icons.workspace_premium_rounded,
                'CERTIFICADO',
                'Certificação Senac',
                amarelo,
              ),
              beneficio(
                Icons.schedule_rounded,
                'NO SEU RITMO',
                'Aprenda quando quiser',
                const Color(0xFFDE9CFF),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'UM MUNDO DE POSSIBILIDADES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: [
              seloArea(
                Icons.computer_rounded,
                'Tecnologia',
                const Color(0xFF69BFFF),
              ),
              seloArea(
                Icons.palette_rounded,
                'Criatividade',
                const Color(0xFFDE9CFF),
              ),
              seloArea(
                Icons.storefront_rounded,
                'Negócios',
                const Color(0xFF77E5B2),
              ),
              seloArea(
                Icons.restaurant_menu_rounded,
                'Gastronomia',
                const Color(0xFFFFB765),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'E muitas outras áreas para você descobrir!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget painelAcesso() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF233B59),
            Color(0xFF13243D),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: laranja,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: laranja.withValues(alpha: 0.13),
            blurRadius: 35,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: amarelo,
            size: 35,
          ),
          const SizedBox(height: 9),
          const Text(
            'CONHEÇA O ORANGO!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Acesse a plataforma pelo celular',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: QrImageView(
              data: siteOrango,
              version: QrVersions.auto,
              size: 211,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'orango.senac.br',
            style: TextStyle(
              color: amarelo,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ESCANEIE E EXPLORE!',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.icon(
              onPressed: abrirOrango,
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 23,
              ),
              label: const Text(
                'ACESSAR ORANGO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: laranja,
                foregroundColor: const Color(0xFF27213A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Entre no site • Escolha o que aprender • Comece!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget painelJogador() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF182B47),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 15,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: 47,
            height: 65,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Personagem(
                andando: false,
                passoAlternado: false,
                modelo: PersonagensOrango.escolhido,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PersonagensOrango.apelido.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$desafiosPontuados de 4 desafios pontuados',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.bolt_rounded,
            color: amarelo,
            size: 28,
          ),
          Text(
            '${widget.pontos} XP',
            style: const TextStyle(
              color: amarelo,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1429),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.35,
                colors: [
                  Color(0xFF314368),
                  Color(0xFF142440),
                  Color(0xFF091425),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: animacao,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ParticulasOrango(
                      animacao.value,
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0.75,
                          end: 1,
                        ),
                        duration: const Duration(
                          milliseconds: 750,
                        ),
                        curve: Curves.elasticOut,
                        builder: (context, valor, child) {
                          return Transform.scale(
                            scale: valor,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 57,
                          color: amarelo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ORANGO CITY',
                        style: TextStyle(
                          color: laranja,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const Text(
                        'VOCÊ COMPLETOU SUA AVENTURA!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 19),
                      painelJogador(),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 850) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: painelApresentacao(),
                                ),
                                const SizedBox(width: 19),
                                SizedBox(
                                  width: 338,
                                  child: painelAcesso(),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              painelApresentacao(),
                              const SizedBox(height: 18),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 390,
                                ),
                                child: painelAcesso(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 340,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: abrirRanking,
                            icon: const Icon(
                              Icons.emoji_events_rounded,
                            ),
                            label: const Text(
                              'VER RANKING DO EVENTO',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: amarelo,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        'ORANGO POR SENAC • APRENDER DO SEU JEITO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
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
    );
  }
}

class _ParticulasOrango extends CustomPainter {
  final double progresso;

  _ParticulasOrango(this.progresso);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 32; i++) {
      final x = (i * 137.0 + 45) % size.width;
      final y = (i * 91.0 + 24) % size.height;

      final pulso = (
        math.sin(progresso * math.pi * 2 + i) + 1
      ) / 2;

      canvas.drawCircle(
        Offset(x, y),
        1.8 + pulso * 1.9,
        Paint()
          ..color = Color.fromRGBO(
            255,
            207,
            108,
            0.20 + pulso * 0.50,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ParticulasOrango antigo,
  ) {
    return progresso != antigo.progresso;
  }
}
