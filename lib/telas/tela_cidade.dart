import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import '../componentes/mapa.dart';
import '../componentes/animacoes_orango.dart';

import '../dados/personagens.dart';
import '../dados/ranking.dart';
import '../dados/trilhas.dart';

import '../minigames/vibe_tech.dart';
import '../minigames/lab_fashion.dart';
import '../minigames/bora_empreender.dart';
import '../minigames/exploradores_sabor.dart';

import 'painel_curso.dart';
import 'tela_descoberta_cursos.dart';
import 'tela_portal_orango.dart';
import 'tela_final_orango.dart';

class TelaCidade extends StatefulWidget {
  const TelaCidade({super.key});

  @override
  State<TelaCidade> createState() => _TelaCidadeState();
}

class _TelaCidadeState extends State<TelaCidade>
    with SingleTickerProviderStateMixin {
  static const Offset centroPortal = Offset(850, 712);

  final FocusNode foco = FocusNode();
  final Set<LogicalKeyboardKey> teclas = {};

  final Set<int> coletadas = {};
  final List<int> melhoresMinigames = List.filled(4, 0);

  late final Timer atualizador;
  late final Timer cronometro;
  late final AnimationController animacao;

  Timer? avisoTimer;

  Offset jogador = const Offset(480, 440);
  Offset cameraAtual = Offset.zero;

  Size tamanhoTela = const Size(1280, 720);

  String direcao = 'baixo';

  Trilha? painel;
  int? minigameAtivo;
  int? destaqueMissao;

  int pontos = 0;
  int tempo = 300;
  int contador = 0;
  int avisoQuantidade = 0;
  int avisoEvento = 0;

  bool andando = false;
  bool passo = false;
  bool finalizando = false;
  bool confirmando = false;
  bool portalAberto = false;
  bool cameraIniciada = false;
  bool tempoEsgotado = false;

  @override
  void initState() {
    super.initState();

    animacao = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    atualizador = Timer.periodic(
      const Duration(milliseconds: 33),
      (_) => atualizar(),
    );

    cronometro = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted ||
            finalizando ||
            confirmando ||
            tempoEsgotado) {
          return;
        }

        if (tempo <= 1) {
          setState(() {
            tempo = 0;
            tempoEsgotado = true;
          });

          verificarFimAutomatico();
        } else {
          setState(() => tempo--);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) foco.requestFocus();
    });
  }

  @override
  void dispose() {
    cronometro.cancel();
    atualizador.cancel();
    avisoTimer?.cancel();
    animacao.dispose();
    foco.dispose();
    super.dispose();
  }

  int get missoesCompletas {
    return melhoresMinigames.where((p) => p > 0).length;
  }

  bool get pertoPortal {
    return (jogador - centroPortal).distance <= 110;
  }

  Trilha? get proxima {
    for (final trilha in trilhasOrango) {
      final area = trilha.posicao;

      final maisPerto = Offset(
        jogador.dx.clamp(
          area.left,
          area.right,
        ).toDouble(),
        jogador.dy.clamp(
          area.top,
          area.bottom,
        ).toDouble(),
      );

      if ((jogador - maisPerto).distance <= 77) {
        return trilha;
      }
    }

    return null;
  }

  bool podeAndar(Offset nova) {
    if (nova.dx < 23 ||
        nova.dx > MapaCidade.largura - 23 ||
        nova.dy < 65 ||
        nova.dy > MapaCidade.altura - 25) {
      return false;
    }

    final areaJogador = Rect.fromCenter(
      center: Offset(nova.dx, nova.dy - 12),
      width: 27,
      height: 22,
    );

    for (final trilha in trilhasOrango) {
      if (areaJogador.overlaps(
        trilha.posicao.inflate(5),
      )) {
        return false;
      }
    }

    if ((nova - const Offset(480, 300)).distance < 66) {
      return false;
    }

    final lagoX = (nova.dx - 1280) / 127;
    final lagoY = (nova.dy - 850) / 84;

    if (lagoX * lagoX + lagoY * lagoY < 1) {
      return false;
    }

    if ((nova - centroPortal).distance < 44) {
      return false;
    }

    return true;
  }

  double get escala {
    return math.max(
      0.62,
      math.max(
        tamanhoTela.width / 1180,
        tamanhoTela.height / 740,
      ),
    );
  }

  Offset destinoCamera() {
    final larguraVisivel = tamanhoTela.width / escala;
    final alturaVisivel = tamanhoTela.height / escala;

    final maxX = math.max(
      0.0,
      MapaCidade.largura - larguraVisivel,
    );

    final maxY = math.max(
      0.0,
      MapaCidade.altura - alturaVisivel,
    );

    return Offset(
      (jogador.dx - larguraVisivel * 0.43)
          .clamp(0.0, maxX)
          .toDouble(),
      (jogador.dy - alturaVisivel * 0.70)
          .clamp(0.0, maxY)
          .toDouble(),
    );
  }

  void atualizarCamera() {
    final destino = destinoCamera();

    cameraAtual = Offset.lerp(
      cameraAtual,
      destino,
      0.16,
    )!;

    if ((cameraAtual - destino).distance < 0.35) {
      cameraAtual = destino;
    }
  }

  void recuperarFoco() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !portalAberto) {
        foco.requestFocus();
      }
    });
  }

  void mostrarXp(int valor) {
    if (valor <= 0) return;

    avisoTimer?.cancel();

    avisoQuantidade = valor;
    avisoEvento++;

    avisoTimer = Timer(
      const Duration(milliseconds: 1400),
      () {
        if (!mounted) return;

        setState(() {
          avisoQuantidade = 0;
        });
      },
    );
  }

  void verificarColecionaveis() {
    int ganho = 0;

    for (int i = 0; i < MapaCidade.estrelas.length; i++) {
      if (coletadas.contains(i)) continue;

      if ((jogador - MapaCidade.estrelas[i]).distance < 38) {
        coletadas.add(i);
        ganho += 40;
      }
    }

    if (ganho > 0) {
      pontos += ganho;
      mostrarXp(ganho);
    }
  }

  void atualizar() {
    if (!mounted ||
        painel != null ||
        minigameAtivo != null ||
        portalAberto ||
        finalizando ||
        confirmando ||
        tempoEsgotado) {
      return;
    }

    double dx = 0;
    double dy = 0;

    if (teclas.contains(LogicalKeyboardKey.keyA) ||
        teclas.contains(LogicalKeyboardKey.arrowLeft)) {
      dx--;
    }

    if (teclas.contains(LogicalKeyboardKey.keyD) ||
        teclas.contains(LogicalKeyboardKey.arrowRight)) {
      dx++;
    }

    if (teclas.contains(LogicalKeyboardKey.keyW) ||
        teclas.contains(LogicalKeyboardKey.arrowUp)) {
      dy--;
    }

    if (teclas.contains(LogicalKeyboardKey.keyS) ||
        teclas.contains(LogicalKeyboardKey.arrowDown)) {
      dy++;
    }

    if (dx == 0 && dy == 0) {
      final faltandoCamera =
          (cameraAtual - destinoCamera()).distance > 0.35;

      if (andando || faltandoCamera) {
        setState(() {
          andando = false;
          atualizarCamera();
        });
      }

      return;
    }

    if (dx.abs() > dy.abs()) {
      direcao = dx > 0 ? 'direita' : 'esquerda';
    } else {
      direcao = dy > 0 ? 'baixo' : 'cima';
    }

    final diagonal =
        dx != 0 && dy != 0 ? 0.70710678 : 1.0;

    const velocidade = 6.0;

    var nova = jogador;

    final tentativaX = Offset(
      nova.dx + dx * velocidade * diagonal,
      nova.dy,
    );

    if (podeAndar(tentativaX)) {
      nova = tentativaX;
    }

    final tentativaY = Offset(
      nova.dx,
      nova.dy + dy * velocidade * diagonal,
    );

    if (podeAndar(tentativaY)) {
      nova = tentativaY;
    }

    setState(() {
      jogador = nova;
      andando = true;

      contador++;

      if (contador % 5 == 0) {
        passo = !passo;
      }

      verificarColecionaveis();
      atualizarCamera();
    });
  }

  void abrirPortal({int? destaque}) {
    if (finalizando || confirmando) return;

    teclas.clear();

    setState(() {
      portalAberto = true;
      destaqueMissao = destaque;
      andando = false;
    });
  }

  void fecharPortal() {
    teclas.clear();

    setState(() {
      portalAberto = false;
      destaqueMissao = null;
    });

    recuperarFoco();
    verificarFimAutomatico();
  }

  void iniciarDesafio(Trilha trilha) {
    if (finalizando || tempoEsgotado) return;

    final indice = trilhasOrango.indexOf(trilha);

    if (indice < 0) return;

    teclas.clear();

    setState(() {
      painel = null;
      minigameAtivo = indice;
      andando = false;
    });
  }

  void finalizarDesafio(int xp) {
    if (finalizando) return;

    final indice = minigameAtivo;
    int ganho = 0;
    bool novoEmblema = false;

    teclas.clear();

    setState(() {
      if (indice != null && indice >= 0 && indice < 4) {
        final resultado = math.max(0, xp);
        final anterior = melhoresMinigames[indice];

        if (resultado > anterior) {
          ganho = resultado - anterior;

          pontos += ganho;
          melhoresMinigames[indice] = resultado;

          novoEmblema = anterior == 0 && resultado > 0;
        }
      }

      minigameAtivo = null;
      andando = false;
    });

    if (ganho > 0) {
      mostrarXp(ganho);
    }

    if (novoEmblema && indice != null) {
      abrirPortal(destaque: indice);
    } else {
      recuperarFoco();
      verificarFimAutomatico();
    }
  }

  void cancelarDesafio() {
    teclas.clear();

    setState(() {
      minigameAtivo = null;
      andando = false;
    });

    recuperarFoco();
    verificarFimAutomatico();
  }

  void fecharPainel() {
    teclas.clear();

    setState(() {
      painel = null;
      andando = false;
    });

    recuperarFoco();
    verificarFimAutomatico();
  }

  void verificarFimAutomatico() {
    if (!mounted ||
        !tempoEsgotado ||
        finalizando ||
        confirmando ||
        portalAberto ||
        painel != null ||
        minigameAtivo != null) {
      return;
    }

    finalizarPartida(automatico: true);
  }

  Future<void> voltarMenu() async {
    if (finalizando ||
        confirmando ||
        portalAberto ||
        minigameAtivo != null ||
        painel != null) {
      return;
    }

    setState(() => confirmando = true);

    final sair = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2C47),
          title: const Text(
            'SAIR DA AVENTURA?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Se sair agora, os pontos desta partida '
            'não serão registrados no ranking.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CONTINUAR JOGANDO'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('SAIR'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    setState(() => confirmando = false);

    if (sair == true) {
      Navigator.of(context).pop();
    } else {
      recuperarFoco();
      verificarFimAutomatico();
    }
  }

  Future<void> finalizarPartida({
    bool automatico = false,
  }) async {
    if (!mounted || finalizando || confirmando) return;

    if (!automatico) {
      setState(() => confirmando = true);

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1B2D47),
            title: const Text(
              'FINALIZAR SUA AVENTURA?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              'Você conquistou $pontos XP e energizou '
              '$missoesCompletas de 4 emblemas.\n\n'
              'Deseja registrar seus pontos e conhecer '
              'a plataforma Orango?',
              style: const TextStyle(
                color: Colors.white,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CONTINUAR'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('FINALIZAR'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      setState(() => confirmando = false);

      if (confirmar != true) {
        recuperarFoco();
        verificarFimAutomatico();
        return;
      }
    }

    setState(() {
      finalizando = true;
      portalAberto = false;
      painel = null;
      minigameAtivo = null;
      andando = false;
    });

    teclas.clear();

    final agora = DateTime.now().millisecondsSinceEpoch;

    final resultado = ResultadoRanking(
      id: '${agora}_${PersonagensOrango.apelido}',
      apelido: PersonagensOrango.apelido,
      personagemId: PersonagensOrango.escolhido.id,
      pontos: pontos,
      trilhas: missoesCompletas,
      data: agora,
    );

    try {
      await RankingOrango().registrar(resultado);

      if (!mounted) return;

      cronometro.cancel();
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => TelaFinalOrango(
      pontos: pontos,
      desafiosConcluidos: melhoresMinigames
          .where((xp) => xp > 0)
          .length,
    ),
  ),
);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        finalizando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar o resultado. '
            'Tente finalizar novamente.',
          ),
        ),
      );
    }
  }

  KeyEventResult tratarTecla(
    FocusNode node,
    KeyEvent evento,
  ) {
    final tecla = evento.logicalKey;

    if (evento is KeyUpEvent) {
      teclas.remove(tecla);
      return KeyEventResult.handled;
    }

    if (evento is! KeyDownEvent &&
        evento is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (finalizando || confirmando) {
      return KeyEventResult.ignored;
    }

    if (portalAberto) {
      if (tecla == LogicalKeyboardKey.escape &&
          evento is KeyDownEvent) {
        fecharPortal();
      }

      return KeyEventResult.ignored;
    }

    if (minigameAtivo != null) {
      return KeyEventResult.ignored;
    }

    if (painel != null) {
      if (tecla == LogicalKeyboardKey.escape &&
          evento is KeyDownEvent) {
        fecharPainel();
      }

      return KeyEventResult.handled;
    }

    if (tempoEsgotado) {
      return KeyEventResult.handled;
    }

    teclas.add(tecla);

    if (tecla == LogicalKeyboardKey.escape &&
        evento is KeyDownEvent) {
      teclas.clear();
      voltarMenu();
      return KeyEventResult.handled;
    }

    if (tecla == LogicalKeyboardKey.keyP &&
        evento is KeyDownEvent) {
      abrirPortal();
      return KeyEventResult.handled;
    }

    if ((tecla == LogicalKeyboardKey.keyE ||
            tecla == LogicalKeyboardKey.enter) &&
        evento is KeyDownEvent) {
      if (pertoPortal) {
        abrirPortal();
        return KeyEventResult.handled;
      }

      final trilha = proxima;

      if (trilha != null) {
        teclas.clear();

        setState(() {
          painel = trilha;
          andando = false;
        });
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  Widget construirMinigame(int indice) {
    switch (indice) {
      case 0:
        return VibeTech(
          aoConcluir: finalizarDesafio,
          voltar: cancelarDesafio,
        );

      case 1:
        return LabFashion(
          aoConcluir: finalizarDesafio,
          voltar: cancelarDesafio,
        );

      case 2:
        return BoraEmpreender(
          aoConcluir: finalizarDesafio,
          voltar: cancelarDesafio,
        );

      case 3:
        return ExploradoresSabor(
          aoConcluir: finalizarDesafio,
          voltar: cancelarDesafio,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String get regiao {
    if (pertoPortal) {
      return 'PORTAL DO CONHECIMENTO';
    }

    if (jogador.dy > 630) {
      return 'PARQUE ORANGO';
    }

    if (jogador.dx > 980) {
      return 'JARDIM DAS IDEIAS';
    }

    return 'PRAÇA DO CONHECIMENTO';
  }

  String get tempoFormatado {
    final minutos =
        (tempo ~/ 60).toString().padLeft(2, '0');

    final segundos =
        (tempo % 60).toString().padLeft(2, '0');

    return '$minutos:$segundos';
  }

  BoxDecoration decoracaoHud() {
    return BoxDecoration(
      color: const Color(0xE912253D),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: Colors.white24,
      ),
    );
  }

  Widget hud() {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 1070;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: decoracaoHud(),
                  child: IconButton(
                    tooltip: 'Voltar ao menu',
                    onPressed: voltarMenu,
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!compacto) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: decoracaoHud(),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            PersonagensOrango.apelido.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            regiao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: decoracaoHud(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: tempo <= 30
                            ? const Color(0xFFFF849B)
                            : const Color(0xFF87EBDC),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tempoFormatado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: decoracaoHud(),
                  child: Text(
                    '⚡ $pontos XP',
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => abrirPortal(),
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                  ),
                  label: Text(
                    compacto
                        ? '$missoesCompletas/4'
                        : 'PORTAL $missoesCompletas/4',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF7753BC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: finalizando
                      ? null
                      : () => finalizarPartida(),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFAD48),
                    foregroundColor:
                        const Color(0xFF23223D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                  ),
                  child: compacto
                      ? const Icon(
                          Icons.flag_rounded,
                        )
                      : const Text(
                          'FINALIZAR',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget minimapa() {
    return Positioned(
      right: 15,
      bottom: 15,
      child: IgnorePointer(
        child: Container(
          width: 174,
          height: 125,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xE9112635),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF73D7C2),
              width: 1.5,
            ),
          ),
          child: CustomPaint(
            painter: _MinimapaOrango(
              jogador: jogador,
              portal: centroPortal,
              emblemas: missoesCompletas,
            ),
          ),
        ),
      ),
    );
  }

  Widget mundo(double largura, double altura) {
    tamanhoTela = Size(largura, altura);

    if (!cameraIniciada) {
      cameraAtual = destinoCamera();
      cameraIniciada = true;
    }

    final zoom = escala;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -cameraAtual.dx * zoom,
            top: -cameraAtual.dy * zoom,
            child: Transform.scale(
              scale: zoom,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: MapaCidade.largura,
                height: MapaCidade.altura,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MapaCidade(
                      jogador: jogador,
                      andando: andando,
                      passoAlternado: passo,
                      direcao: direcao,
                      proxima: proxima,
                      pontos: pontos,
                      coletadas: coletadas,
                    ),
                    BrilhosCidade(
                      animacao: animacao,
                      estrelas: MapaCidade.estrelas,
                      coletadas: coletadas,
                      predioProximo: proxima?.posicao,
                    ),
                    Positioned(
                      left: centroPortal.dx - 125,
                      top: centroPortal.dy - 130,
                      child: PortalOrangoCidade(
                        animacao: animacao,
                        emblemas: missoesCompletas,
                        proximo: pertoPortal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selecionada = painel;

    return Scaffold(
      backgroundColor: const Color(0xFF112638),
      body: Focus(
        focusNode: foco,
        autofocus: true,
        onKeyEvent: tratarTecla,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: recuperarFoco,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return mundo(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: hud(),
                ),
                minimapa(),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AvisoXp(
                      quantidade: avisoQuantidade,
                      evento: avisoEvento,
                    ),
                  ),
                ),
                if (selecionada != null)
                  Positioned.fill(
                    child: PainelCurso(
                      trilha: selecionada,
                      fechar: fecharPainel,
                      iniciarDesafio: () =>
                          iniciarDesafio(selecionada),
                    ),
                  ),
                if (minigameAtivo != null)
                  Positioned.fill(
                    child: construirMinigame(minigameAtivo!),
                  ),
                if (portalAberto)
                  Positioned.fill(
                    child: TelaPortalOrango(
                      pontos: pontos,
                      melhoresMinigames:
                          List<int>.from(melhoresMinigames),
                      destaqueMissao: destaqueMissao,
                      fechar: fecharPortal,
                      finalizar: () {
                        setState(() {
                          portalAberto = false;
                        });

                        finalizarPartida(
                          automatico: tempoEsgotado,
                        );
                      },
                    ),
                  ),
                if (finalizando)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0xE9101B30),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFFFD166),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'SALVANDO SUA AVENTURA...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimapaOrango extends CustomPainter {
  final Offset jogador;
  final Offset portal;
  final int emblemas;

  _MinimapaOrango({
    required this.jogador,
    required this.portal,
    required this.emblemas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / MapaCidade.largura;
    final sy = size.height / MapaCidade.altura;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF285D4B),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        257 * sy,
        size.width,
        100 * sy,
      ),
      Paint()..color = const Color(0xFFD9C49E),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        425 * sx,
        0,
        110 * sx,
        size.height,
      ),
      Paint()..color = const Color(0xFFD9C49E),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        665 * sy,
        size.width,
        90 * sy,
      ),
      Paint()..color = const Color(0xFFD9C49E),
    );

    for (final trilha in trilhasOrango) {
      final r = trilha.posicao;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            r.left * sx,
            r.top * sy,
            r.width * sx,
            r.height * sy,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = trilha.cor,
      );
    }

    final posicaoPortal = Offset(
      portal.dx * sx,
      portal.dy * sy,
    );

    canvas.drawCircle(
      posicaoPortal,
      8,
      Paint()
        ..color = const Color(0xFFFFC664)
            .withValues(alpha: 0.30),
    );

    canvas.drawCircle(
      posicaoPortal,
      4 + emblemas.toDouble() * 0.4,
      Paint()..color = const Color(0xFFFFDB81),
    );

    final posicaoJogador = Offset(
      jogador.dx * sx,
      jogador.dy * sy,
    );

    canvas.drawCircle(
      posicaoJogador,
      6,
      Paint()..color = Colors.white70,
    );

    canvas.drawCircle(
      posicaoJogador,
      3.5,
      Paint()..color = const Color(0xFFFF8E44),
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapaOrango antigo) {
    return antigo.jogador != jogador ||
        antigo.emblemas != emblemas;
  }
}