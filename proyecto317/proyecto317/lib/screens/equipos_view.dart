import 'package:flutter/material.dart';
import '../models/equpo_model.dart';
import '../services/equipos_service.dart';

class EquiposView extends StatefulWidget {
  const EquiposView({super.key});

  @override
  State<EquiposView> createState() => _EquiposViewState();
}

class _EquiposViewState extends State<EquiposView> {
  final SupabaseService _supabaseService = SupabaseService();

  void _abrirFormularioReporte(Equipo equipo) {
    final controller = TextEditingController(text: equipo.observacion);
    bool estadoActual = equipo.estado;

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
                    'Reportar Estado',
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
                      'Equipo seleccionado: PC-${equipo.codigo}',
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
                            backgroundColor: estadoActual ? Colors.green.shade100 : Colors.transparent,
                            side: BorderSide(color: estadoActual ? Colors.green : Colors.grey),
                          ),
                          onPressed: () => setModalState(() => estadoActual = true),
                          child: Text(
                            'OPERATIVO',
                            style: TextStyle(color: estadoActual ? Colors.green.shade900 : Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !estadoActual ? Colors.red.shade100 : Colors.transparent,
                            side: BorderSide(color: !estadoActual ? Colors.red : Colors.grey),
                          ),
                          onPressed: () => setModalState(() => estadoActual = false),
                          child: Text(
                            'CON FALLA',
                            style: TextStyle(color: !estadoActual ? Colors.red.shade900 : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detalle o Novedad:',
                      hintText: 'Describe el problema del equipo si aplica...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      try {
                        await _supabaseService.actualizarEquipo(
                          id: equipo.id,
                          estado: estadoActual,
                          observacion: controller.text,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Estado actualizado correctamente')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'GUARDAR EN SUPABASE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        backgroundColor: const Color(0xFF15438C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Equipo>>(
        future: _supabaseService.getEquipos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }

          final listaEquipos = snapshot.data ?? [];

          if (listaEquipos.isEmpty) {
            return const Center(child: Text('No hay equipos registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: listaEquipos.length,
            itemBuilder: (context, index) {
              final equipo = listaEquipos[index];
              final bool esOperativo = equipo.estado;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: esOperativo ? Colors.green.shade300 : Colors.red.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 6,
                    backgroundColor: esOperativo ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    'PC-${equipo.codigo}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    equipo.observacion.isEmpty ? 'Sin novedad' : equipo.observacion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: esOperativo ? Colors.grey.shade600 : Colors.red.shade700,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: esOperativo ? Colors.green.shade800 : Colors.red.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      esOperativo ? 'BIEN' : 'MAL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _abrirFormularioReporte(equipo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}