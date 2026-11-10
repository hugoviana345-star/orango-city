
import 'package:flutter/material.dart';

class ArcadeFrame extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final int tempo;
  final int xp;
  final double progresso;
  final VoidCallback voltar;
  final Widget child;

  const ArcadeFrame({
    super.key,
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.tempo,
    required this.xp,
    required this.progresso,
    required this.voltar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF5091020),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FundoArcade(cor),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1120,
                maxHeight: 820,
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1D304D),
                      Color(0xFF101B31),
                      Color(0xFF17243E),
                    ],
                  ),
                  border: Border.all(
                    color: cor.withValues(alpha: 0.65),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cor.withValues(alpha: 0.20),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          18, 12, 12, 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B162A),
                          border: Border(
                            bottom: BorderSide(
                              color: cor.withValues(alpha: 0.30),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: cor.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: cor.withValues(alpha: 0.60),
                                ),
                              ),
                              child: Icon(
                                icone,
                                color: cor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titulo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Text(
                                    'ORANGO ARCADE',
                                    style: TextStyle(
                                      color: cor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Voltar à cidade',
                              onPressed: voltar,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white10,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18, 12, 18, 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _Indicador(
                                icone: Icons.timer_rounded,
                                titulo: 'TEMPO',
                                valor: '${tempo}s',
                                cor: tempo <= 10
                                    ? const Color(0xFFFF697C)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Indicador(
                                icone: Icons.bolt_rounded,
                                titulo: 'PONTOS',
                                valor: '$xp XP',
                                cor: const Color(0xFFFFD166),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: progresso.clamp(0.0, 1.0),
                            ),
                            duration: const Duration(
                              milliseconds: 450,
                            ),
                            builder: (context, valor, _) {
                              return LinearProgressIndicator(
                                value: valor,
                                minHeight: 10,
                                backgroundColor:
                                    const Color(0xFF34415A),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(cor),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 850,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        color: const Color(0xFF0B162A),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sports_esports_rounded,
                              color: cor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'ORANGO CITY',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Text(
                              'EXPLORE • JOGUE • APRENDA',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

class _Indicador extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final Color cor;

  const _Indicador({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111F35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  valor,
                  maxLines: 1,
                  style: TextStyle(
                    color: cor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
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

class ArcadeEnd extends StatelessWidget {
  final Color cor;
  final int xp;
  final String subtitulo;
  final VoidCallback voltar;

  const ArcadeEnd({
    super.key,
    required this.cor,
    required this.xp,
    required this.subtitulo,
    required this.voltar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, valor, child) {
              return Transform.scale(
                scale: valor,
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cor.withValues(alpha: 0.15),
                border: Border.all(
                  color: cor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cor.withValues(alpha: 0.35),
                    blurRadius: 45,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: cor,
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'MISSÃO FINALIZADA!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: xp),
            duration: const Duration(milliseconds: 900),
            builder: (context, valor, _) {
              return Text(
                '+$valor XP',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 43,
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 27),
          SizedBox(
            width: 300,
            height: 58,
            child: FilledButton.icon(
              onPressed: voltar,
              icon: const Icon(Icons.home_rounded),
              label: const Text(
                'RECEBER XP E VOLTAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FundoArcade extends CustomPainter {
  final Color cor;

  _FundoArcade(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = cor.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        tinta,
      );
    }

    for (double y = 0; y < size.height; y += 42) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        tinta,
      );
    }

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.32,
      Paint()
        ..color = cor.withValues(alpha: 0.035),
    );
  }

  @override
  bool shouldRepaint(covariant _FundoArcade oldDelegate) {
    return cor != oldDelegate.cor;
  }
}
