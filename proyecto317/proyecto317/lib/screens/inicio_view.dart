import 'package:flutter/material.dart';
import '../services/equipos_service.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final SupabaseService _supabaseService = SupabaseService();
  int operativos = 0;
  int conFalla = 0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    try {
      final resumen = await _supabaseService.getResumenEquipos();
      setState(() {
        operativos = resumen['operativos'] ?? 0;
        conFalla = resumen['conFalla'] ?? 0;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('$operativos', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                          const Text('PCs Operativos'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('$conFalla', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                          const Text('Con Falla'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15438C),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // Acción de nuevo reporte
              },
              child: const Text('+ Nuevo Reporte', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {},
              child: const Text('Escanear QR Equipo'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}