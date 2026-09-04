import 'package:flutter/material.dart';
import '../models/equpo_model.dart';
import '../services/equipos_service.dart';
import 'qr_scanner_view.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final SupabaseService _supabaseService = SupabaseService();
  int operativos = 0;
  int conFalla = 0;

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
      });
    } catch (_) {}
  }

  // Despliega el formulario de reporte directo para un equipo
  void _mostrarFormularioReporte(Equipo equipo) {
    final controller = TextEditingController(text: equipo.observacion);
    bool estadoSeleccionado = equipo.estado;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reportar Estado del Equipo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Código de equipo: ${equipo.codigo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15438C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Condición actual:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: estadoSeleccionado ? Colors.green.shade100 : Colors.transparent,
                            side: BorderSide(color: estadoSeleccionado ? Colors.green : Colors.grey),
                          ),
                          onPressed: () => setModalState(() => estadoSeleccionado = true),
                          child: Text('OPERATIVO', style: TextStyle(color: estadoSeleccionado ? Colors.green.shade900 : Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !estadoSeleccionado ? Colors.red.shade100 : Colors.transparent,
                            side: BorderSide(color: !estadoSeleccionado ? Colors.red : Colors.grey),
                          ),
                          onPressed: () => setModalState(() => estadoSeleccionado = false),
                          child: Text('CON FALLA', style: TextStyle(color: !estadoSeleccionado ? Colors.red.shade900 : Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detalle o Novedad (Observación):',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      try {
                        await _supabaseService.actualizarEquipo(
                          id: equipo.id,
                          estado: estadoSeleccionado,
                          codigo: equipo.codigo,
                          observacion: controller.text,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          _cargarResumen();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte guardado exitosamente')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('GUARDAR EN SUPABASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Lógica QR
  Future<void> _escanearQR() async {
    final String? resultadoQr = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );

    if (resultadoQr != null && resultadoQr.isNotEmpty) {
      final equipo = await _supabaseService.getEquipoPorCodigo(resultadoQr);
      if (mounted) {
        if (equipo != null) {
          _mostrarFormularioReporte(equipo);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontró ningún equipo con el código: $resultadoQr')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido al gestor de equipos'),
        backgroundColor: const Color(0xFF15438C),
        foregroundColor: Colors.white,
      ),
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
              onPressed: _escanearQR,
              child: const Text('+ Nuevo Reporte', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}