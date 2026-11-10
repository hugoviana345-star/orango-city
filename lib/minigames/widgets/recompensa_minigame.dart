
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class RecompensaMinigame extends StatelessWidget {
  final String jogo;
  final int pontos;
  final ValueChanged<int> aoConcluir;
  final VoidCallback voltar;

  const RecompensaMinigame({
    super.key,
    required this.jogo,
    required this.pontos,
    required this.aoConcluir,
    required this.voltar,
  });

  static const String site = 'https://orango.senac.br/';

  Future<void> abrirOrango(BuildContext context) async {
    try {
      final abriu = await launchUrl(
        Uri.parse(site),
        mode: LaunchMode.externalApplication,
      );

      if (!abriu) {
        throw Exception('Nao foi possivel abrir');
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acesse https://orango.senac.br/',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xF20C162C),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.5),
                  radius: 1.3,
                  colors: [
                    Color(0xFF354669),
                    Color(0xFF15243F),
                    Color(0xFF0D172B),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF344E70),
                            Color(0xFF242242),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFFFFC365),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFFFD166),
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'DESAFIO FINALIZADO!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            jogo.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFBFD0E8),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$pontos XP',
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 19),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3651),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF83EABB),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  color: Color(0xFF95F2C0),
                                  size: 35,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'RESGATE SUA RECOMPENSA NO ORANGO!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF95F2C0),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                const Text(
                                  'Sua próxima aventura é descobrir cursos gratuitos!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 17),
                                Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(15),
                                  ),
                                  child: QrImageView(
                                    data: site,
                                    version: QrVersions.auto,
                                    size: 174,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'orango.senac.br',
                                  style: TextStyle(
                                    color: Color(0xFFFFD166),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 51,
                                  child: FilledButton.icon(
                                    onPressed: () => abrirOrango(context),
                                    icon: const Icon(
                                      Icons.open_in_new_rounded,
                                    ),
                                    label: const Text(
                                      'CONHECER CURSOS GRATUITOS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF91EABB),
                                      foregroundColor:
                                          const Color(0xFF183149),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: FilledButton.icon(
                              onPressed: () => aoConcluir(pontos),
                              icon: const Icon(
                                Icons.check_circle_rounded,
                              ),
                              label: const Text(
                                'RECEBER XP E VOLTAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFFB957),
                                foregroundColor:
                                    const Color(0xFF1B2A43),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextButton(
                            onPressed: voltar,
                            child: const Text(
                              'VOLTAR À CIDADE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
