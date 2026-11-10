
import 'package:flutter/material.dart';
import '../dados/personagens.dart';

class Personagem extends StatelessWidget {
  final bool andando;
  final bool passoAlternado;
  final String direcao;
  final PersonagemModelo? modelo;

  const Personagem({
    super.key,
    required this.andando,
    required this.passoAlternado,
    this.direcao = 'baixo',
    this.modelo,
  });

  @override
  Widget build(BuildContext context) {
    final atual = modelo ?? PersonagensOrango.escolhido;

    return SizedBox(
      width: 48,
      height: 62,
      child: CustomPaint(
        painter: _PersonagemPainter(
          personagem: atual,
          andando: andando,
          passo: passoAlternado,
          direcao: direcao,
        ),
      ),
    );
  }
}

class _PersonagemPainter extends CustomPainter {
  final PersonagemModelo personagem;
  final bool andando;
  final bool passo;
  final String direcao;

  const _PersonagemPainter({
    required this.personagem,
    required this.andando,
    required this.passo,
    required this.direcao,
  });

  void bloco(
    Canvas canvas,
    double x,
    double y,
    double largura,
    double altura,
    Color cor, {
    double raio = 2,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, largura, altura),
        Radius.circular(raio),
      ),
      Paint()..color = cor,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(
      size.width / 48,
      size.height / 62,
    );

    final p = personagem;
    final passoAtual =
        andando ? (passo ? 3.0 : -3.0) : 0.0;

    canvas.drawOval(
      const Rect.fromLTWH(5, 52, 38, 9),
      Paint()..color = const Color(0x66000000),
    );

    bloco(
      canvas, 10, 39 + passoAtual, 11, 15,
      p.calca,
    );

    bloco(
      canvas, 27, 39 - passoAtual, 11, 15,
      p.calca,
    );

    bloco(
      canvas, 8, 51 + passoAtual, 15, 6,
      const Color(0xFF182037),
    );

    bloco(
      canvas, 25, 51 - passoAtual, 15, 6,
      const Color(0xFF182037),
    );

    bloco(
      canvas, 5, 27 - passoAtual, 10, 17,
      p.roupa,
    );

    bloco(
      canvas, 33, 27 + passoAtual, 10, 17,
      p.roupa,
    );

    bloco(
      canvas, 6, 39 - passoAtual, 9, 5,
      p.pele,
    );

    bloco(
      canvas, 33, 39 + passoAtual, 9, 5,
      p.pele,
    );

    bloco(
      canvas, 8, 23, 32, 23,
      Color.lerp(p.roupa, Colors.black, 0.32)!,
    );

    bloco(
      canvas, 10, 24, 28, 20,
      p.roupa,
    );

    bloco(
      canvas, 22, 25, 4, 18,
      p.detalhe,
    );

    bloco(
      canvas, 11, 30, 7, 8,
      p.detalhe.withValues(alpha: 0.7),
    );

    bloco(
      canvas, 30, 30, 7, 8,
      p.detalhe.withValues(alpha: 0.7),
    );

    bloco(
      canvas, 19, 21, 10, 7,
      p.pele,
    );

    bloco(
      canvas, 8, 7, 32, 25,
      p.cabelo,
    );

    bloco(
      canvas, 10, 9, 28, 21,
      p.pele,
    );

    if (direcao == 'cima') {
      bloco(
        canvas, 8, 6, 32, 23,
        p.cabelo,
      );

      bloco(
        canvas, 14, 25, 20, 5,
        Color.lerp(p.cabelo, Colors.black, 0.2)!,
      );
    } else {
      if (direcao == 'baixo') {
        bloco(
          canvas, 16, 18, 4, 5,
          const Color(0xFF25213A),
        );

        bloco(
          canvas, 29, 18, 4, 5,
          const Color(0xFF25213A),
        );

        bloco(
          canvas, 20, 27, 9, 2,
          const Color(0xFFA65954),
        );
      } else if (direcao == 'esquerda') {
        bloco(
          canvas, 12, 18, 5, 5,
          const Color(0xFF25213A),
        );
      } else {
        bloco(
          canvas, 31, 18, 5, 5,
          const Color(0xFF25213A),
        );
      }

      if (p.estiloCabelo == 0) {
        bloco(
          canvas, 8, 2, 32, 12,
          p.cabelo,
        );

        bloco(
          canvas, 7, 9, 8, 12,
          p.cabelo,
        );

        bloco(
          canvas, 28, 4, 12, 11,
          p.cabelo,
        );
      } else if (p.estiloCabelo == 1) {
        bloco(
          canvas, 9, 5, 30, 9,
          p.cabelo,
        );

        bloco(
          canvas, 15, 1, 11, 7,
          p.cabelo,
        );

        bloco(
          canvas, 27, 3, 10, 8,
          p.cabelo,
        );
      } else if (p.estiloCabelo == 2) {
        bloco(
          canvas, 5, 6, 38, 16,
          p.cabelo,
        );

        for (final c in [
          const Offset(9, 8),
          const Offset(17, 5),
          const Offset(27, 4),
          const Offset(36, 8),
        ]) {
          canvas.drawCircle(
            c,
            7,
            Paint()..color = p.cabelo,
          );
        }
      } else {
        bloco(
          canvas, 8, 6, 32, 10,
          p.cabelo,
        );

        bloco(
          canvas, 12, 0, 7, 12,
          p.cabelo,
        );

        bloco(
          canvas, 22, 2, 8, 9,
          p.cabelo,
        );

        bloco(
          canvas, 32, 4, 8, 10,
          p.cabelo,
        );
      }
    }

    if (p.id == 'pixel') {
      bloco(
        canvas, 5, 16, 6, 16,
        p.acessorio,
      );

      bloco(
        canvas, 37, 16, 6, 16,
        p.acessorio,
      );

      bloco(
        canvas, 8, 8, 5, 8,
        p.acessorio,
      );

      bloco(
        canvas, 35, 8, 5, 8,
        p.acessorio,
      );
    } else if (p.id == 'faisca') {
      bloco(
        canvas, 8, 5, 32, 8,
        p.acessorio,
      );

      bloco(
        canvas, 24, 12, 19, 5,
        p.acessorio,
      );
    } else if (p.id == 'brisa') {
      canvas.drawCircle(
        const Offset(35, 10),
        6,
        Paint()..color = p.acessorio,
      );

      canvas.drawCircle(
        const Offset(35, 10),
        2,
        Paint()..color = Colors.white,
      );
    } else if (p.id == 'turbo') {
      bloco(
        canvas, 10, 16, 28, 7,
        p.acessorio.withValues(alpha: 0.80),
        raio: 3,
      );

      bloco(
        canvas, 12, 17, 24, 3,
        const Color(0xFFA8ECFF),
      );
    }

    bloco(
      canvas, 12, 46, 7, 2,
      p.detalhe.withValues(alpha: 0.8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PersonagemPainter antigo) {
    return personagem != antigo.personagem ||
        andando != antigo.andando ||
        passo != antigo.passo ||
        direcao != antigo.direcao;
  }
}
