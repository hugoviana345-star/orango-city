
import 'package:flutter/material.dart';

import '../dados/trilhas.dart';

class PainelCurso extends StatelessWidget {
  final Trilha trilha;
  final VoidCallback fechar;
  final VoidCallback iniciarDesafio;

  const PainelCurso({
    super.key,
    required this.trilha,
    required this.fechar,
    required this.iniciarDesafio,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE908142A),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 850,
            ),
            child: Container(
              padding: const EdgeInsets.all(27),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF294568),
                    Color(0xFF121F39),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: trilha.cor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: trilha.cor.withValues(alpha: 0.27),
                    blurRadius: 35,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: trilha.cor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          trilha.icone,
                          color: trilha.cor,
                          size: 37,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trilha.area,
                              style: TextStyle(
                                color: trilha.cor,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              trilha.nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: fechar,
                        tooltip: 'Fechar',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    trilha.descricao,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 21),
                  const Text(
                    'O QUE VOCÊ VAI ENCONTRAR',
                    style: TextStyle(
                      color: Color(0xFFFFD166),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final tema in trilha.temas)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: trilha.cor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: trilha.cor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            tema,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132B43),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: Color(0xFFFFD166),
                          size: 27,
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            'Este desafio faz parte do ORANGO CITY, '
                            'uma experiência para apresentar a '
                            'plataforma gratuita de aprendizagem '
                            'Orango por Senac.',
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: fechar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                          ),
                          child: const Text('VOLTAR'),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: iniciarDesafio,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 28,
                          ),
                          label: const Text(
                            'INICIAR MISSÃO',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: trilha.cor,
                            foregroundColor: const Color(0xFF18233D),
                            padding: const EdgeInsets.symmetric(
                              vertical: 19,
                            ),
                          ),
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
    );
  }
}
