
import 'package:flutter/material.dart';

import '../componentes/animacoes_orango.dart';
import '../componentes/personagem.dart';
import '../dados/personagens.dart';
import '../dados/ranking.dart';

class TelaRanking extends StatefulWidget {
  final String? destaqueId;

  const TelaRanking({
    super.key,
    this.destaqueId,
  });

  @override
  State<TelaRanking> createState() => _TelaRankingState();
}

class _TelaRankingState extends State<TelaRanking> {
  final RankingOrango repositorio = RankingOrango();

  List<ResultadoRanking> resultados = [];

  bool carregando = true;
  bool apagando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await repositorio.carregar();

      if (!mounted) return;

      setState(() {
        resultados = dados;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro ao carregar o ranking.';
      });
    }
  }

  PersonagemModelo encontrarPersonagem(String id) {
    for (final p in PersonagensOrango.opcoes) {
      if (p.id == id) return p;
    }

    return PersonagensOrango.opcoes.first;
  }

  Color corPosicao(int posicao) {
    switch (posicao) {
      case 1:
        return const Color(0xFFFFD166);
      case 2:
        return const Color(0xFFD5E2F3);
      case 3:
        return const Color(0xFFFFAC7D);
      default:
        return const Color(0xFF70C9EF);
    }
  }

  Widget avatar(
    ResultadoRanking resultado, {
    double altura = 75,
  }) {
    return SizedBox(
      width: altura * 0.8,
      height: altura,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Personagem(
          andando: false,
          passoAlternado: false,
          modelo: encontrarPersonagem(resultado.personagemId),
        ),
      ),
    );
  }

  Widget podio(int posicao) {
    final temResultado = resultados.length >= posicao;
    final resultado = temResultado
        ? resultados[posicao - 1]
        : null;

    final cor = corPosicao(posicao);
    final primeiro = posicao == 1;

    return Expanded(
      child: Container(
        height: primeiro ? 235 : 205,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cor.withValues(alpha: 0.27),
              const Color(0xFF182B49),
            ],
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: cor,
            width: primeiro ? 2.5 : 1.5,
          ),
          boxShadow: primeiro
              ? [
                  BoxShadow(
                    color: cor.withValues(alpha: 0.24),
                    blurRadius: 30,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              primeiro
                  ? Icons.emoji_events_rounded
                  : Icons.workspace_premium_rounded,
              color: cor,
              size: primeiro ? 39 : 30,
            ),
            Text(
              '$posicaoº LUGAR',
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            if (resultado != null)
              avatar(
                resultado,
                altura: primeiro ? 83 : 65,
              )
            else
              const Expanded(
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white30,
                  size: 45,
                ),
              ),
            const Spacer(),
            Text(
              resultado?.apelido.toUpperCase() ?? '---',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${resultado?.pontos ?? 0} XP',
              style: TextStyle(
                color: cor,
                fontSize: primeiro ? 21 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget linha(int indice) {
    final resultado = resultados[indice];
    final posicao = indice + 1;
    final destaque = resultado.id == widget.destaqueId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: destaque
            ? const Color(0xFF365777)
            : const Color(0xFF1B304B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: destaque
              ? const Color(0xFFFFD166)
              : Colors.white12,
          width: destaque ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$posicao',
              style: TextStyle(
                color: corPosicao(posicao),
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
          avatar(resultado, altura: 45),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultado.apelido.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${resultado.trilhas} trilhas pontuadas',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${resultado.pontos} XP',
            style: const TextStyle(
              color: Color(0xFFFFD166),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> limparRanking() async {
    if (apagando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2B46),
          title: const Text(
            'ZERAR RANKING?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Todos os resultados salvos neste navegador serão apagados.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC94E64),
              ),
              child: const Text('APAGAR'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() => apagando = true);

    try {
      await repositorio.limpar();
      if (mounted) await carregar();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível limpar o ranking.'),
        ),
      );
    } finally {
      if (mounted) setState(() => apagando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1427),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.35,
                colors: [
                  Color(0xFF27365F),
                  Color(0xFF0B1427),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'ORANGO CITY',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.65,
                            end: 1,
                          ),
                          duration: const Duration(
                            milliseconds: 850,
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
                            color: Color(0xFFFFD166),
                            size: 57,
                          ),
                        ),
                        const Text(
                          'RANKING TOP 10',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'OS MELHORES EXPLORADORES',
                          style: TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 19),
                        Expanded(
                          child: carregando
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : erro != null
                                  ? Center(
                                      child: Text(erro!),
                                    )
                                  : resultados.isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.stars_rounded,
                                                size: 70,
                                                color:
                                                    Color(0xFFFFD166),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'O PÓDIO ESTÁ VAZIO!',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ListView(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                podio(2),
                                                podio(1),
                                                podio(3),
                                              ],
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              child: Divider(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            for (int i = 0;
                                                i < resultados.length;
                                                i++)
                                              linha(i),
                                          ],
                                        ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  apagando ? null : limparRanking,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                              ),
                              label: const Text('Zerar ranking'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white54,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () =>
                                  Navigator.pop(context),
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('VOLTAR'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFFA63D),
                                foregroundColor:
                                    const Color(0xFF252039),
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
          ),
          if (widget.destaqueId != null)
            const Positioned.fill(
              child: ChuvaConfetes(),
            ),
        ],
      ),
    );
  }
}
