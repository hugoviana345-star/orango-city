
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PortalOrangoCidade extends StatelessWidget {
  final Animation<double> animacao;
  final int emblemas;
  final bool proximo;

  const PortalOrangoCidade({
    super.key,
    required this.animacao,
    required this.emblemas,
    required this.proximo,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 250,
        height: 230,
        child: CustomPaint(
          painter: _DesenhoPortalCidade(
            animacao,
            emblemas.clamp(0, 4),
            proximo,
          ),
        ),
      ),
    );
  }
}

class _DesenhoPortalCidade extends CustomPainter {
  final Animation<double> animacao;
  final int emblemas;
  final bool proximo;

  _DesenhoPortalCidade(
    this.animacao,
    this.emblemas,
    this.proximo,
  ) : super(repaint: animacao);

  @override
  void paint(Canvas canvas, Size size) {
    final tempo = animacao.value * math.pi * 2;
    final pulso = (math.sin(tempo) + 1) / 2;

    final centro = Offset(
      size.width / 2,
      size.height * 0.56,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro + const Offset(0, 69),
        width: 160,
        height: 25,
      ),
      Paint()..color = Colors.black38,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 155 + pulso * 8,
        height: 174 + pulso * 8,
      ),
      Paint()
        ..color = const Color(0xFFFFD166)
            .withValues(alpha: 0.25 + pulso * 0.20)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          20,
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 145,
        height: 177,
      ),
      Paint()..color = const Color(0xFF162744),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: centro,
        width: 128,
        height: 157,
      ),
      Paint()..color = const Color(0xFFFFB34F),
    );

    final interior = Rect.fromCenter(
      center: centro,
      width: 109,
      height: 137,
    );

    canvas.drawOval(
      interior,
      Paint()
        ..shader = RadialGradient(
          colors: [
            emblemas == 4
                ? const Color(0xFFB5FFE1)
                : const Color(0xFF78DDEA),
            const Color(0xFF7855BD),
            const Color(0xFF24204E),
          ],
        ).createShader(interior),
    );

    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: centro,
          radius: 18 + i * 11,
        ),
        tempo * (i.isEven ? 1 : -1) + i,
        math.pi * 1.3,
        false,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.25 + emblemas * 0.13,
          )
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );
    }

    const cores = [
      Color(0xFFFF964B),
      Color(0xFF70DDEA),
      Color(0xFFD39BFF),
      Color(0xFFFFD166),
    ];

    for (int i = 0; i < 4; i++) {
      final angulo = i * math.pi / 2 - math.pi / 4;

      final pos = Offset(
        centro.dx + math.cos(angulo) * 79,
        centro.dy + math.sin(angulo) * 79,
      );

      canvas.drawCircle(
        pos,
        13,
        Paint()..color = const Color(0xFF182A46),
      );

      canvas.drawCircle(
        pos,
        9,
        Paint()
          ..color = i < emblemas
              ? cores[i]
              : const Color(0xFF62718A),
      );
    }

    _texto(
      canvas,
      'PORTAL ORANGO',
      Offset(size.width / 2, 17),
      17,
      const Color(0xFFFFE3A1),
    );

    if (proximo) {
      final faixa = Rect.fromCenter(
        center: Offset(size.width / 2, 218),
        width: 174,
        height: 23,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          faixa,
          const Radius.circular(9),
        ),
        Paint()..color = const Color(0xEE172943),
      );

      _texto(
        canvas,
        'E • CONHECER ORANGO',
        Offset(size.width / 2, 217),
        11,
        Colors.white,
      );
    }
  }

  void _texto(
    Canvas canvas,
    String texto,
    Offset pos,
    double tamanho,
    Color cor,
  ) {
    final p = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: cor,
          fontSize: tamanho,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 5),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    p.paint(
      canvas,
      pos - Offset(p.width / 2, p.height / 2),
    );
  }

  @override
  bool shouldRepaint(
    covariant _DesenhoPortalCidade antigo,
  ) {
    return antigo.emblemas != emblemas ||
        antigo.proximo != proximo;
  }
}

class TelaPortalOrango extends StatefulWidget {
  final int pontos;
  final List<int> melhoresMinigames;
  final int? destaqueMissao;
  final VoidCallback fechar;
  final VoidCallback finalizar;

  const TelaPortalOrango({
    super.key,
    required this.pontos,
    required this.melhoresMinigames,
    required this.fechar,
    required this.finalizar,
    this.destaqueMissao,
  });

  @override
  State<TelaPortalOrango> createState() =>
      _TelaPortalOrangoState();
}

class _TelaPortalOrangoState extends State<TelaPortalOrango>
    with SingleTickerProviderStateMixin {
  static const site = 'https://orango.senac.br/';

  late final AnimationController animacao;

  static const nomes = [
    'ACESSO GRATUITO',
    'APRENDIZAGEM ONLINE',
    'NO SEU RITMO',
    'CERTIFICADO SENAC',
  ];

  static const jogos = [
    'ORANGO RUSH',
    'ORANGO CONNECT',
    'ORANGO MIX',
    'ORANGO PORTAL',
  ];

  static const descricoes = [
    'Descubra cursos gratuitos na plataforma Orango.',
    'Aprenda pela internet, usando seus dispositivos.',
    'Explore seus interesses e escolha quando estudar.',
    'Conheça a certificação oferecida após concluir cursos.',
  ];

  static const icones = [
    Icons.card_giftcard_rounded,
    Icons.devices_rounded,
    Icons.schedule_rounded,
    Icons.workspace_premium_rounded,
  ];

  static const cores = [
    Color(0xFFFFA657),
    Color(0xFF70CDEA),
    Color(0xFFD59BFA),
    Color(0xFFFFD166),
  ];

  int get completas {
    return widget.melhoresMinigames
        .where((xp) => xp > 0)
        .length;
  }

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    animacao.dispose();
    super.dispose();
  }

  Future<void> acessarOrango() async {
    try {
      final abriu = await launchUrl(
        Uri.parse(site),
        mode: LaunchMode.externalApplication,
      );

      if (!abriu) {
        throw Exception('Falha ao abrir');
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acesse: https://orango.senac.br/',
          ),
        ),
      );
    }
  }

  Widget medalha(int indice) {
    final completa = indice <
            widget.melhoresMinigames.length &&
        widget.melhoresMinigames[indice] > 0;

    final destaque = widget.destaqueMissao == indice;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: destaque
            ? cores[indice].withValues(alpha: 0.18)
            : const Color(0xFF203552),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: completa
              ? cores[indice]
              : Colors.white12,
          width: destaque ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icones[indice],
            color: cores[indice],
            size: 29,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomes[indice],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricoes[indice],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  jogos[indice],
                  style: TextStyle(
                    color: cores[indice],
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            completa
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            color: completa
                ? const Color(0xFF88EFC0)
                : Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget painelMissoes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xEE14263F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENERGIA DO PORTAL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completas/4 MISSÕES • ${widget.pontos} XP',
            style: const TextStyle(
              color: Color(0xFFFFD166),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: completas / 4,
            ),
            duration: const Duration(milliseconds: 900),
            builder: (context, valor, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: valor,
                  minHeight: 14,
                  backgroundColor: const Color(0xFF334866),
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFFFFC564),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 4; i++) medalha(i),
        ],
      ),
    );
  }

  Widget painelAcesso() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xEE18314E),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFFFD166),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.school_rounded,
            color: Color(0xFFFFD166),
            size: 44,
          ),
          const SizedBox(height: 12),
          const Text(
            'CONHEÇA O ORANGO!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'O Orango por Senac é uma plataforma de '
            'aprendizagem com cursos online gratuitos. '
            'Sua próxima aventura pode começar por lá!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: QrImageView(
              data: site,
              version: QrVersions.auto,
              size: 190,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'orango.senac.br',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            '1. Acesse a plataforma\n'
            '2. Clique em Cadastre-se\n'
            '3. Explore os conteúdos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: acessarOrango,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text(
                'ACESSAR ORANGO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFB64C),
                foregroundColor: const Color(0xFF1B2741),
                padding: const EdgeInsets.all(17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF40C162C),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.3,
                colors: [
                  Color(0xFF314A71),
                  Color(0xFF0C162C),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFFFD166),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'ORANGO CITY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.fechar,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        completas == 4
                            ? 'PORTAL ORANGO ATIVADO!'
                            : 'DESPERTE O PORTAL ORANGO!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Conquiste os quatro emblemas e '
                        'descubra a plataforma Orango por Senac.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 19),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final grande =
                              constraints.maxWidth >= 800;

                          if (grande) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      PortalOrangoCidade(
                                        animacao: animacao,
                                        emblemas: completas,
                                        proximo: false,
                                      ),
                                      const SizedBox(height: 14),
                                      painelMissoes(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 18),
                                SizedBox(
                                  width: 355,
                                  child: painelAcesso(),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              PortalOrangoCidade(
                                animacao: animacao,
                                emblemas: completas,
                                proximo: false,
                              ),
                              painelMissoes(),
                              const SizedBox(height: 18),
                              painelAcesso(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 23),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: widget.fechar,
                            icon: const Icon(
                              Icons.sports_esports_rounded,
                            ),
                            label: const Text(
                              'CONTINUAR JOGANDO',
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: widget.finalizar,
                            icon: const Icon(
                              Icons.flag_rounded,
                            ),
                            label: const Text(
                              'FINALIZAR PARTIDA',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFFB64C),
                              foregroundColor:
                                  const Color(0xFF17243D),
                            ),
                          ),
                        ],
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
